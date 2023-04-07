//
//  NSURLSession+ZXHttpProxy.h
//  ZXRequestBlock
//
//  Created by 李兆祥 on 2019/4/10.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXRequestBlock
//  V1.0.3

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (ZXHttpProxy)
+(void)disableHttpProxy;
+(void)enableHttpProxy;
@end

NS_ASSUME_NONNULL_END
