//
//  NSURLSession+ZXHttpProxy.m
//  ZXRequestBlock
//
//  Created by 李兆祥 on 2019/4/10.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXRequestBlock
//  V1.0.3

#import "NSURLSession+ZXHttpProxy.h"
#import "ZXURLProtocol.h"
#import <objc/runtime.h>
static BOOL isDisableHttpProxy = NO;
@implementation NSURLSession (ZXHttpProxy)
+(void)load{
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSURLProtocol registerClass:[ZXURLProtocol class]];
        Class class = [NSURLSession class];
        [self swizzingMethodWithClass:class orgSel:NSSelectorFromString(@"sessionWithConfiguration:") swiSel:NSSelectorFromString(@"zx_sessionWithConfiguration:")];
        [self swizzingMethodWithClass:class orgSel:NSSelectorFromString(@"sessionWithConfiguration:delegate:delegateQueue:") swiSel:NSSelectorFromString(@"zx_sessionWithConfiguration:delegate:delegateQueue:")];
    });
}
+(void)disableHttpProxy{
    isDisableHttpProxy = YES;
}
+(void)enableHttpProxy{
    isDisableHttpProxy = NO;
}
+(NSURLSession *)zx_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration
                                    delegate:(nullable id<NSURLSessionDelegate>)delegate
                               delegateQueue:(nullable NSOperationQueue *)queue{
    if (!configuration){
        configuration = [[NSURLSessionConfiguration alloc] init];
    }
    if(isDisableHttpProxy){
        configuration.connectionProxyDictionary = @{};
    }
    return [self zx_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

+(NSURLSession *)zx_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration{
    if (configuration && isDisableHttpProxy){
        configuration.connectionProxyDictionary = @{};
    }
    return [self zx_sessionWithConfiguration:configuration];
}

+(void)swizzingMethodWithClass:(Class)cls orgSel:(SEL) orgSel swiSel:(SEL) swiSel{
    Method orgMethod = class_getClassMethod(cls, orgSel);
    Method swiMethod = class_getClassMethod(cls, swiSel);
    method_exchangeImplementations(orgMethod, swiMethod);
}

@end

