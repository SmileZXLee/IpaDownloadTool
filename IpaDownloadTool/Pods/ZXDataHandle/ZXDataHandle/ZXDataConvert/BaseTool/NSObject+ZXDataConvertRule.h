//
//  NSObject+ZXDataConvertRule.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DeclarationProtocol <NSObject>
#pragma mark ZXDataConvert相关
+ (void)zx_inArrModelName;
+ (void)zx_replaceProName;
+ (NSString *)zx_replaceProName121:(NSString *)proName;
#pragma mark ZXDataStore相关
+ (NSDictionary *)zx_tbConfig;
@end
@interface NSObject (ZXDataConvertRule)
+(NSDictionary *)getInArrModelNameDic;
+(NSDictionary *)getReplaceProNameDic;
+(NSString *)getReplacedProName:(NSString *)proName;
@end

NS_ASSUME_NONNULL_END
