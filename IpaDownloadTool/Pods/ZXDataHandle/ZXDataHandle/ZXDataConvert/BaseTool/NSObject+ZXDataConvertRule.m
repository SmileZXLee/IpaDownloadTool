//
//  NSObject+ZXDataConvertRule.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSObject+ZXDataConvertRule.h"
#import "NSDictionary+ZXSafetySet.h"
@implementation NSObject (ZXDataConvertRule)
+(NSDictionary *)getInArrModelNameDic{
    if([self respondsToSelector:@selector(zx_inArrModelName)]){
        NSDictionary *inArrModelNameDic = [self performSelector:@selector(zx_inArrModelName)];
        return inArrModelNameDic;
    }
    return nil;
}
+(NSDictionary *)getReplaceProNameDic{
    if([self respondsToSelector:@selector(zx_replaceProName)]){
        NSDictionary *replaceProNameDic = [self performSelector:@selector(zx_replaceProName)];
        return replaceProNameDic;
    }
    return nil;
}
+(NSString *)getReplacedProName:(NSString *)proName{
    NSDictionary *replaceProNameDic = [self getReplaceProNameDic];
    if(replaceProNameDic){
        NSString *repKey = [replaceProNameDic zx_dicSafetyReadForKey:proName];
        if(repKey.length){
            
            return repKey;
        }
    }
    if([self respondsToSelector:@selector(zx_replaceProName121:)]){
        NSString *replacedProStr = [self performSelector:@selector(zx_replaceProName121:) withObject:proName];
        if(replacedProStr.length){
            return replacedProStr;
        }
    }
    return proName;
}
@end
