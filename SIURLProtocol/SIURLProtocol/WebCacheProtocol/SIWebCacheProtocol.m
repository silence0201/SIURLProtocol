//
//  SIWebCacheProtocol.m
//  SIURLProtocol
//
//  Created by Silence on 2018/5/24.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "SIWebCacheProtocol.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

@implementation NSString (MD5)
- (NSString *)md5String{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, length, bytes);
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < length; i++)
        [mutableString appendFormat:@"%02x", bytes[i]];
    return [NSString stringWithString:mutableString];
}
@end


static NSString *const SIWebCacheProtocolIdentifier = @"SIWebCacheProtocolIdentifier";
@implementation SIWebCacheProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] && ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:SIWebCacheProtocolIdentifier inRequest:request] ) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:SIWebCacheProtocolIdentifier inRequest:mutableRequest];
    return [mutableRequest copy];
}

- (BOOL)useCache{
    BOOL reachable = [[AFNetworkReachabilityManager managerForDomain:self.request.URL.host] isReachable]
    ;
    return !reachable;
    
}

@end
