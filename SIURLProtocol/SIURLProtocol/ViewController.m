//
//  ViewController.m
//  SIURLProtocol
//
//  Created by Silence on 2018/5/22.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "ViewController.h"
#import "SIProtocolManager.h"
#import <AFNetworking/AFNetworking.h>

@interface ViewController ()<SIURLProtocolDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SIProtocolManager manager] setEnable:YES];
    [SIURLProtocol setDelegate:self];
    
    //Network Request
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.playcode.cc"]];
    [urlRequest setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSLog(@"返回的数据:%@",data);
    }];
    
    // Json Response
    [[AFHTTPSessionManager manager] GET:@"http://www.playcode.cc/feed" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"返回的数据:%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)handleWithNetWorkRequest:(SINetWorkModel *)netWorkModel {
    NSLog(@"url:%@",netWorkModel.url);
    NSLog(@"method:%@",netWorkModel.method);
    NSLog(@"MIMEType:%@",netWorkModel.mineType);
    NSLog(@"response:%@",[[NSString alloc]initWithData:netWorkModel.responseData encoding:NSUTF8StringEncoding]);
}

@end
