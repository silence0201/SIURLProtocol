//
//  SIProtocolManager.h
//  SIURLProtocol
//
//  Created by Silence on 2018/5/22.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "SIURLProtocol.h"

@interface SIProtocolManager : NSObject

+ (instancetype)manager;

@property (nonatomic, assign) BOOL enable;

@end
