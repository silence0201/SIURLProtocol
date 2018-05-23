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

@interface ViewController ()<SIURLProtocolDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SIProtocolManager manager] setEnable:YES];
    [SIURLProtocol setDelegate:self];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.playcode.cc"]]];
    self.webView.delegate = self;
    
    //Network Request
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.douban.com/v2/book/1220562"]];
    [urlRequest setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSLog(@"返回的数据:%@",data);
    }];
    
    // Json Response
    [[AFHTTPSessionManager manager] GET:@"https://api.douban.com/v2/loc/list" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"返回的数据:%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)handleWithNetWorkRequest:(SINetWorkModel *)netWorkModel {
    NSLog(@"url:%@",netWorkModel.url);
    NSLog(@"method:%@",netWorkModel.method);
    NSLog(@"HTTPHeader:%@",netWorkModel.requestBody);
    NSLog(@"MIMEType:%@",netWorkModel.mineType);
    NSLog(@"response:%@",[[NSString alloc]initWithData:netWorkModel.responseData encoding:NSUTF8StringEncoding]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
}

@end
