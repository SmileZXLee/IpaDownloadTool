//
//  ZXDataConvert.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "ZXDataConvert.h"
#import "ZXDecimalNumberTool.h"
#import "ZXDataType.h"
@implementation ZXDataConvert
+ (instancetype)shareInstance{
    static ZXDataConvert * s_instance_dj_singleton = nil ;
    if (s_instance_dj_singleton == nil) {
        s_instance_dj_singleton = [[ZXDataConvert alloc] init];
    }
    return (ZXDataConvert *)s_instance_dj_singleton;
}
- (NSMutableDictionary *)allPropertyDic{
    if(_allPropertyDic){
        _allPropertyDic = [NSMutableDictionary dictionary];
    }
    return _allPropertyDic;
}

+ (id)handleValueToMatchModelPropertyTypeWithValue:(id)value type:(NSString *)proType{
    ZXDataValueAutoConvertMode dataValueAutoConvertMode = [ZXDataConvert shareInstance].zx_dataConvertConfig.zx_dataValueAutoConvertMode;
    if([proType hasPrefix:@"T@\"NSString\""]){
        if([value isKindOfClass:[NSString class]]){
            return value;
        }
        if([value isKindOfClass:[NSNumber class]]){
            return [NSString stringWithFormat:@"%@",value];
        }
        switch (dataValueAutoConvertMode) {
            case ZXDataValueAutoConvertModeEmpty:{
                return @"";
                break;
            }
            case ZXDataValueAutoConvertModeNil:{
                return nil;
                break;
            }
            case ZXDataValueAutoConvertModeOrg:{
                return value;
                break;
            }
            default:
                break;
        }
        return nil;
    }
    if([proType hasPrefix:@"T@\"NSArray\""]){
        if([value isKindOfClass:[NSArray class]]){
            return value;
        }
        switch (dataValueAutoConvertMode) {
            case ZXDataValueAutoConvertModeEmpty:{
                return @[];
                break;
            }
            case ZXDataValueAutoConvertModeNil:{
                return nil;
                break;
            }
            case ZXDataValueAutoConvertModeOrg:{
                return value;
                break;
            }
            default:
                break;
        }
        return nil;
    }
    if([proType hasPrefix:@"T@\"NSMutableArray\""]){
        if([value isKindOfClass:[NSArray class]]){
            return [NSMutableArray arrayWithArray:value];
        }
        switch (dataValueAutoConvertMode) {
            case ZXDataValueAutoConvertModeEmpty:{
                return [NSMutableArray array];
                break;
            }
            case ZXDataValueAutoConvertModeNil:{
                return nil;
                break;
            }
            case ZXDataValueAutoConvertModeOrg:{
                return value;
                break;
            }
            default:
                break;
        }
        return nil;
    }
    if([proType hasPrefix:@"T@"]){
        NSRange typeRange = [proType rangeOfString:@"\".*?\"" options:NSRegularExpressionSearch];
        if(typeRange.location != NSNotFound){
            NSString *resTypeStr = [proType substringWithRange:typeRange];
            resTypeStr = [resTypeStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            Class cls = NSClassFromString(resTypeStr);
            if(cls && [value isKindOfClass:cls]){
                return value;
            }
            switch (dataValueAutoConvertMode) {
                case ZXDataValueAutoConvertModeEmpty:{
                    if(cls){
                        return [cls new];
                    }
                    break;
                }
                case ZXDataValueAutoConvertModeNil:{
                    return nil;
                    break;
                }
                case ZXDataValueAutoConvertModeOrg:{
                    return value;
                    break;
                }
                default:
                    break;
            }
            return nil;
        }
        
    }
    if([value isKindOfClass:[NSString class]]){
        BOOL isNumberType = [ZXDataType isNumberType:value];
        if(isNumberType){
            if(![proType hasPrefix:@"T@"]){
                if([proType hasPrefix:@"TB"]||
                   [proType hasPrefix:@"Tc"]||
                   [proType hasPrefix:@"Tl"]||
                   [proType hasPrefix:@"Tq"]||
                   [proType hasPrefix:@"TC"]||
                   [proType hasPrefix:@"TI"]||
                   [proType hasPrefix:@"TS"]||
                   [proType hasPrefix:@"TL"]||
                   [proType hasPrefix:@"TQ"]||
                   [proType hasPrefix:@"Tf"]||
                   [proType hasPrefix:@"Td"]){
                   return [ZXDecimalNumberTool zx_decimalNumberWithStr:value];
                }
            }
        }
    }
    return value;
}

- (ZXDataConvertConfig *)zx_dataConvertConfig{
    if(!_zx_dataConvertConfig){
        _zx_dataConvertConfig = [[ZXDataConvertConfig alloc]init];
    }
    return _zx_dataConvertConfig;
}

@end
