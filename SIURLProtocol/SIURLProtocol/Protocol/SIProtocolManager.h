//
//  SIProtocolManager.h
//  SIURLProtocol
//
//  Created by 杨晴贺 on 2018/5/22.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIProtocolManager : NSObject

+ (instancetype)manager;

@property (nonatomic, assign) BOOL enable;

@end
