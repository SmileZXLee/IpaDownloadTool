//
//  NSDictionary+ZXSafetySet.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSDictionary+ZXSafetySet.h"

@implementation NSDictionary (ZXSafetySet)
-(id)zx_dicSafetyReadForKey:(NSString *)key{
    id returnObj = nil;
    if([self.allKeys containsObject:key]){
        returnObj = [self valueForKey:key];
    }else{
        //ZXDataHandleLog(@"字典Value获取失败，对象中不包含属性:%@",key);
    }
    return returnObj;
}
-(void)zx_dicSaftySetValue:(id)value forKey:(NSString *)key{
    [self setValue:value forKey:key];
}

@end
