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
#import "ZXDataConvert.h"
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
    if([ZXDataConvert shareInstance].zx_dataConvertSetterBlock){
        id resValue = [ZXDataConvert shareInstance].zx_dataConvertSetterBlock(key,value,self);
        value = resValue;
    }
    if(value && ![value isKindOfClass:[NSNull class]]){
        [self setValue:value forKey:key];
    }
}

@end
