//
//  NSObject+ZXToDic.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSObject+ZXToDic.h"
#import "ZXDataType.h"
#import "NSObject+ZXGetProperty.h"
#import "NSObject+ZXSafetySet.h"
#import "NSObject+ZXDataConvertRule.h"
#import "NSString+ZXDataConvert.h"
#import "NSObject+ZXToJson.h"
#import "NSDictionary+ZXSafetySet.h"
@implementation NSObject (ZXToDic)
-(id)zx_toDic{
    DataType dataType = [ZXDataType zx_dataType:self];
    if(dataType == DataTypeDic){
        return self;
    }
    if(dataType == DataTypeStr){
        return [((NSString *)self)zx_jsonToDic];
    }
    if(dataType == DataTypeArr){
        NSArray *objArr = [self mutableCopy];
        NSMutableArray *resObjArr = [NSMutableArray array];
        for (id subObj in objArr) {
            id resSubObj = [subObj zx_toDic];
            [resObjArr addObject:resSubObj];
        }
        return resObjArr;
    }else{
        return [self zx_singleObjToDic];
    }
    
}
-(NSDictionary *)zx_singleObjToDic{
    if([self isKindOfClass:[NSData class]]){
        NSString *jsonStr = [self zx_toJsonStr];
        return [jsonStr zx_toDic];
    }
    if([ZXDataType isFoudationClass:self]){
        return @{};
    }
    NSMutableDictionary *resDic = [NSMutableDictionary dictionary];
    [[self class] getEnumPropertyNamesCallBack:^(NSString *proName, NSString *proType) {
        id value = [self zx_objSafetyReadForKey:proName];
        proName = [[self class] getReplacedProName:proName];
        DataType dataType = [ZXDataType zx_dataType:value];
        if(value != NULL){
            if(dataType == DataTypeStr || [value isKindOfClass:[NSNumber class]]){
                
            }else if(dataType == DataTypeArr){
                NSArray *valueArr = (NSArray *)value;
                NSMutableArray *resValueArr = [NSMutableArray array];
                for (id subObj in valueArr) {
                    id resSubObj = [subObj zx_toDic];
                    [resValueArr addObject:resSubObj];
                }
                value = [resValueArr mutableCopy];
            }else{
                value = [value zx_toDic];
            }
            [resDic zx_dicSaftySetValue:value forKey:proName];
        }
    }];
    return resDic;
}

@end
