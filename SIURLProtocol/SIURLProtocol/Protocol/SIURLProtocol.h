//
//  SIURLProtocol.h
//  SIURLProtocol
//
//  Created by Silence on 2018/5/22.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SINetWorkModel : NSObject

@property (nonatomic , copy , nonnull) NSDate *startDate;
@property (nonatomic , copy , nullable) NSURL *url;
@property (nonatomic , copy , nullable) NSString *method;
@property (nonatomic , copy , nullable) NSString *mineType;
@property (nonatomic , copy , nullable) NSString *requestBody;
@property (nonatomic , copy , nonnull) NSString *statusCode;
@property (nonatomic , copy , nullable) NSData *responseData;
@property (nonatomic , copy , nonnull) NSString *totalDuration;
@property (nonatomic , strong , nullable) NSError *error;
@property (nonatomic , copy , nullable) NSDictionary <NSString *,NSString *>*headerFields;

@end

@protocol SIURLProtocolDelegate<NSObject>
- (void)handleWithNetWorkRequest:(SINetWorkModel *)netWorkModel;
@end

@interface SIURLProtocol : NSURLProtocol

+ (void)setDelegate:(id<SIURLProtocolDelegate>)delegate;

@end
