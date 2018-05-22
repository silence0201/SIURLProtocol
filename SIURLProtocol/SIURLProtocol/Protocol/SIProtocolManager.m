//
//  SIProtocolManager.m
//  SIURLProtocol
//
//  Created by 杨晴贺 on 2018/5/22.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "SIProtocolManager.h"
#import "SIURLProtocol.h"

@implementation SIProtocolManager

+ (instancetype)manager {
    static SIProtocolManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SIProtocolManager alloc]init];
    });
    return manager;
}

- (void)setEnable:(BOOL)enable {
    if (_enable != enable) {
        _enable = enable;
        if (enable) {
            [self registerSIURLProtocol];
        }else {
            [self unregisterSIURLProtocol];
        }
    }
}

#pragma mark -- Private
- (void)registerSIURLProtocol {
    if (![NSURLProtocol registerClass:[SIURLProtocol class]]) {
        NSLog(@"注册SIURLProtocol失败");
    }
}

- (void)unregisterSIURLProtocol {
    [NSURLProtocol unregisterClass:[SIURLProtocol class]];
}

@end
