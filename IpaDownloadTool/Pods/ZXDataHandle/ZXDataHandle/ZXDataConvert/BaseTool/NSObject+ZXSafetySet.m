//
//  NSObject+ZXSafetySet.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSObject+ZXSafetySet.h"
#import "NSObject+ZXGetProperty.h"
#import "ZXDataHandleLog.h"
@implementation NSObject (ZXSafetySet)
-(id)zx_objSafetyReadForKey:(NSString *)key{
    ///因为模型取值此时不存在找不到key的情况，因此直接返回
    return [self valueForKey:key];
    id returnObj = nil;
    NSArray *proNamesArr = [[self class] getAllPropertyNames];
    if([proNamesArr containsObject:key]){
        returnObj = [self valueForKey:key];
    }else{
        ZXDataHandleLog(@"对象Value获取失败，对象中不包含属性:%@",key);
    }
    return returnObj;
}
-(void)zx_objSaftySetValue:(id)value forKey:(NSString *)key{
    if(![value isKindOfClass:[NSNull class]] && value){
        if([value isKindOfClass:[NSArray class]]){
            if([value count]){
                [self setValue:value forKey:key];
            }
        }else{
            [self setValue:value forKey:key];
        }
    }
    return;
    ///因为模型赋值此时不存在找不到key的情况，因此直接返回
    NSArray *proNamesArr = [[self class] getAllPropertyNames];
    if([proNamesArr containsObject:key]){
        [self setValue:value forKey:key];
    }else{
        ZXDataHandleLog(@"对象Value赋值失败，对象中不包含属性:%@",key);
    }
}

@end
