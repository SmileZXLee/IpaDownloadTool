//
//  NSObject+ZXToJson.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSObject+ZXToJson.h"
#import "NSDictionary+ZXDataConvert.h"
#import "NSArray+ZXDataConvert.h"
#import "NSData+ZXDataConvert.h"
#import "ZXDataType.h"
#import "NSObject+ZXToDic.h"
#import "NSDictionary+ZXSafetySet.h"
#import "NSString+ZXRegular.h"
@implementation NSObject (ZXToJson)
-(NSString *)zx_toJsonStr{
    NSString *resJsonStr = nil;
    if([self isKindOfClass:[NSData class]]){
        return [((NSData *)self) zx_dataToJsonStr];
    }
    DataType dataType = [ZXDataType zx_dataType:self];
    if(dataType == DataTypeDic){
        resJsonStr = [((NSDictionary *)self) zx_dicToJsonStr];
    }else if(dataType == DataTypeArr){
        NSMutableArray *dicsArr = [NSMutableArray array];
        for (id subObj in (NSArray *)self) {
            DataType subDataType = [ZXDataType zx_dataType:subObj];
            if(!(subDataType == DataTypeDic)){
                id subDicObj = [subObj zx_toDic];
                [dicsArr addObject:subDicObj];
            }else{
                [dicsArr addObject:subObj];
            }
        }
        resJsonStr = [dicsArr zx_arrToJsonStr];
    }else if(dataType == DataTypeStr){
        resJsonStr = (NSString *)self;
    }else{
        id resDic = [self zx_toDic];
        resJsonStr = [resDic zx_dicToJsonStr];
    }
    return resJsonStr;
}

-(NSString*)zx_kvStr{
    id res = [self zx_toDic];
    
    if([res isKindOfClass:[NSArray class]]){
        NSString *sumStr = @"";
        for (NSDictionary *subDic in res) {
            sumStr = [sumStr stringByAppendingString:[NSString stringWithFormat:@"%@&",[self perKvStrWithDic:subDic]]];
        }
        if(sumStr.length){
            sumStr = [sumStr substringToIndex:sumStr.length - 1];
        }
        return sumStr;
    }
    return [self perKvStrWithDic:(NSDictionary *)res];
}
-(NSString *)perKvStrWithDic:(NSDictionary *)resDic{
    NSArray *sortedKeys = [[resDic allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSString *sumStr = @"";
    for (NSString *key in sortedKeys) {
        NSObject *value = [resDic zx_dicSafetyReadForKey:key];
        if(value){
            NSString *valueStr = [NSString stringWithFormat:@"%@",value];
            valueStr = [valueStr removeAllElements:@[@"\r",@"\n",@"\t",@" "]];
            sumStr = [sumStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,valueStr]];
        }
    }
    sumStr = sumStr.length ? [sumStr substringToIndex:sumStr.length - 1] : sumStr;
    return sumStr;
}
-(NSData *)zx_toJsonData{
    NSData *jsonData;
    if([self isKindOfClass:[NSData class]]){
        return (NSData *)self;
    }
    DataType dataType = [ZXDataType zx_dataType:self];
    if(dataType == DataTypeDic){
        jsonData = [((NSDictionary *)self) zx_dicToJSONData];
    }else if(dataType == DataTypeArr){
        id fObj = ((NSArray *)self).firstObject;
        if(fObj && [fObj isKindOfClass:[NSDictionary class]]){
            jsonData = [((NSArray *)self) zx_arrToJSONData];
        }else{
            jsonData = [[self zx_toJsonStr]dataUsingEncoding:NSUTF8StringEncoding];
        }
    }else if(dataType == DataTypeStr){
        jsonData = [((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        jsonData = [[self zx_toJsonStr]dataUsingEncoding:NSUTF8StringEncoding];
    }
    return jsonData;
}
@end
