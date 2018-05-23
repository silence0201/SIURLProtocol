//
//  SIURLProtocol.m
//  SIURLProtocol
//
//  Created by Silence on 2018/5/22.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "SIURLProtocol.h"
#import <objc/runtime.h>

@implementation SINetWorkModel
@end

@implementation NSURLSessionConfiguration (_Protocol)

+ (void)load {
    Method method1 = class_getClassMethod([NSURLSessionConfiguration class], @selector(defaultSessionConfiguration));
    Method method2 = class_getClassMethod([NSURLSessionConfiguration class], @selector(SI_defaultSessionConfiguration));
    method_exchangeImplementations(method1, method2);
}

+ (NSURLSessionConfiguration *)SI_defaultSessionConfiguration {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration SI_defaultSessionConfiguration];
    NSMutableArray *protocols = [NSMutableArray arrayWithArray:config.protocolClasses];
    if (![protocols containsObject:[SIURLProtocol class]]) {
        [protocols insertObject:[SIURLProtocol class] atIndex:0];
    }
    config.protocolClasses = protocols;
    return config;
}


@end

static NSString *const SIProtocolIdentifier = @"SIProtocolIdentifier";
static id<SIURLProtocolDelegate> _delegate = nil;
@interface SIURLProtocol() <NSURLSessionTaskDelegate,NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOperationQueue     *sessionDelegateQueue;
@property (nonatomic, strong) NSURLResponse        *response;
@property (nonatomic, strong) NSMutableData        *data;
@property (nonatomic, strong) NSDate               *startDate;
@property (nonatomic, strong) NSError              *error;

@end

@implementation SIURLProtocol

+ (void)setDelegate:(id<SIURLProtocolDelegate>)delegate {
    _delegate = delegate;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] && ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:SIProtocolIdentifier inRequest:request] ) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:SIProtocolIdentifier inRequest:mutableRequest];
    return [mutableRequest copy];
}

- (void)startLoading {
    self.startDate = [NSDate date];
    self.data = [NSMutableData data];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.sessionDelegateQueue = [[NSOperationQueue alloc]init];
    self.sessionDelegateQueue.maxConcurrentOperationCount = 1;
    self.sessionDelegateQueue.name = @"com.silence.queue";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.sessionDelegateQueue];
    self.dataTask = [session dataTaskWithRequest:self.request];
    [self.dataTask resume];
}

- (void)stopLoading {
    [self.dataTask cancel];
    self.dataTask = nil;
    SINetWorkModel *model = [[SINetWorkModel alloc]init];
    model.startDate = self.startDate;
    model.url = self.request.URL;
    model.method = self.request.HTTPMethod;
    model.headerFields = self.request.allHTTPHeaderFields;
    model.mineType = self.response.MIMEType;
    if (self.request.HTTPBody) {
        model.requestBody = [self prettyJSONStringFromData:self.request.HTTPBody];
    } else if (self.request.HTTPBodyStream) {
        NSData* data = [self dataFromInputStream:self.request.HTTPBodyStream];
        model.requestBody = [self prettyJSONStringFromData:data];
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)self.response;
    model.statusCode = [NSString stringWithFormat:@"%d",(int)httpResponse.statusCode];
    model.responseData = self.data;
    model.totalDuration = [NSString stringWithFormat:@"%fs",[[NSDate date] timeIntervalSinceDate:self.startDate]];
    model.error = self.error;
    
    if ([_delegate respondsToSelector:@selector(handleWithNetWorkRequest:)]) {
        [_delegate handleWithNetWorkRequest:model];
    }
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
        
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
    self.dataTask = nil;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.data appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
    self.response = response;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if (response != nil){
        self.response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}


#pragma mark - Primary
- (NSString *)prettyJSONStringFromData:(NSData *)data{
    if ([data length] == 0) {
        return nil;
    }
    NSString *prettyString = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        prettyString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL] encoding:NSUTF8StringEncoding];
        prettyString = [prettyString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    } else {
        prettyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return prettyString;
}

- (NSData *)dataFromInputStream:(NSInputStream *)stream {
    NSMutableData *data = [[NSMutableData alloc] init];
    if (stream.streamStatus != NSStreamStatusOpen) {
        [stream open];
    }
    NSInteger readLength;
    uint8_t buffer[1024];
    while((readLength = [stream read:buffer maxLength:1024]) > 0) {
        [data appendBytes:buffer length:readLength];
    }
    return data;
}

@end
