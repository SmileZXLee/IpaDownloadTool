//
//  NSObject+ZXGetProperty.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  获取类的属性

#import <Foundation/Foundation.h>
typedef void(^kEnumEventHandler) (NSString *proName,NSString *proType);
@interface NSObject (ZXGetProperty)
+(void)getEnumPropertyNamesCallBack:(kEnumEventHandler)_result;
+(NSMutableArray *)getAllPropertyNames;
@end
