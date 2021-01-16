//
//  NSObject+ZXToJson.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZXToJson)
///任意类型转Json字符串
-(NSString *)zx_toJsonStr;
///任意类型转keyValue的形式：name=123&dec=test
-(NSString*)zx_kvStr;
///任意类型转JsonData
-(NSData *)zx_toJsonData;
@end

NS_ASSUME_NONNULL_END
