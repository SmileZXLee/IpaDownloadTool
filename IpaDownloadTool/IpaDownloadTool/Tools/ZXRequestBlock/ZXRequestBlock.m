//
//  ZXRequestBlock.m
//  ZXRequestBlock
//
//  Created by 李兆祥 on 2018/8/25.
//  Copyright © 2018年 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXRequestBlock
//  V1.0.3

#import "ZXRequestBlock.h"
#import <objc/runtime.h>
#import "ZXURLProtocol.h"
#import "ZXHttpIPGet.h"
#import "NSURLSession+ZXHttpProxy.h"
static BOOL isCancelAllReq;
static BOOL isEnableHttpDns;

@implementation ZXRequestBlock
+(void)addRequestBlock{
    [self injectNSURLSessionConfiguration];
    [NSURLProtocol registerClass:[ZXURLProtocol class]];
}
+(void)removeRequestBlock{
    [NSURLProtocol unregisterClass:[ZXURLProtocol class]];
}
+(void)handleRequest:(requestBlock)requestBlock{
    [self handleRequest:requestBlock responseBlock:nil];
}
+(void)handleRequest:(requestBlock)requestBlock responseBlock:(responseBlock)responseBlock{
    ZXURLProtocol *urlProtocol = [ZXURLProtocol sharedInstance];
    NSAssert(!urlProtocol.requestBlock, @"您已添加过handleRequest，再次添加会导致之前代码设置的handleRequest失效，请更改设计策略，在同一个handleRequestBlock作统一处理！");
    [self addRequestBlock];
    urlProtocol.requestBlock = ^NSURLRequest *(NSURLRequest *request) {
        if(isCancelAllReq){
            return nil;
        }
        NSURLRequest *newRequest = requestBlock(request);
        if(isEnableHttpDns){
            NSString *handleUrlStr = request.URL.absoluteString;
            if([self isValidIP:handleUrlStr]){
                return newRequest;
            }
            NSString *ipStr = [ZXHttpIPGet getIPArrFromLocalDnsWithUrlStr:newRequest.URL.host];
            NSMutableURLRequest * mutableReq = [newRequest mutableCopy];
            [mutableReq setValue:ipStr forHTTPHeaderField:@"host"];
            return mutableReq;
        }
        return newRequest;
    };
    urlProtocol.responseBlock = responseBlock;
}
+(void)disableRequestWithUrlStr:(NSString *)urlStr{
    [self handleRequest:^NSURLRequest *(NSURLRequest *request) {
        NSString *handleUrlStr = request.URL.absoluteString;
        if([handleUrlStr.uppercaseString containsString:urlStr.uppercaseString]){
            return nil;
        }else{
            return request;
        }
    }];
}
+(void)cancelAllRequest{
    isCancelAllReq = YES;
    [self blockRequest];
}
+(void)resumeAllRequest{
    isCancelAllReq = NO;
    [self blockRequest];
}
+(void)blockRequest{
    if(![ZXURLProtocol sharedInstance].requestBlock){
        [self handleRequest:^NSURLRequest *(NSURLRequest *request) {
             return isCancelAllReq ? nil : request;
        }];
    }
}
+(id)disableHttpProxy{
    id httpProxy = [self fetchHttpProxy];
    [NSURLSession disableHttpProxy];
    return httpProxy;
}
+(void)enableHttpProxy{
    [NSURLSession enableHttpProxy];
}

+(void)enableHttpDns{
    isEnableHttpDns = YES;
}
+(void)disableHttpDns{
    isEnableHttpDns = NO;
}

#pragma mark - Private
#pragma mark 是否是ip地址
+ (BOOL)isValidIP:(NSString *)ipStr {
    if (nil == ipStr) {
        return NO;
    }
    NSArray *ipArray = [ipStr componentsSeparatedByString:@"."];
    if (ipArray.count == 4) {
        for (NSString *ipnumberStr in ipArray) {
            int ipnumber = [ipnumberStr intValue];
            if (!(ipnumber >= 0 && ipnumber <= 255)) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark 获取网络代理
+(id)fetchHttpProxy{
    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
    const CFStringRef proxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef,
                                                                           (const void*)kCFNetworkProxiesHTTPProxy);
    NSString *proxy = (__bridge NSString *)proxyCFstr;
    return proxy;
}

///来源：https://www.jianshu.com/p/25f2d36eb637 ，感谢！！
+ (void)injectNSURLSessionConfiguration{
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    Method originalMethod = class_getInstanceMethod(cls, @selector(protocolClasses));
    Method stubMethod = class_getInstanceMethod([self class], @selector(protocolClasses));
    if (!originalMethod || !stubMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
    }
    method_exchangeImplementations(originalMethod, stubMethod);
}

- (NSArray *)protocolClasses{
    return @[[ZXURLProtocol class]];
}

@end
