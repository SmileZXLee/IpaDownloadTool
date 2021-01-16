//
//  NSObject+ZXToModel.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSObject+ZXToModel.h"
#import "ZXDataType.h"
#import "ZXDataConvert.h"
#import "NSObject+ZXGetProperty.h"
#import "ZXDecimalNumberTool.h"
#import "NSString+ZXDataConvert.h"
#import "NSObject+ZXSafetySet.h"
#import "NSObject+ZXDataConvertRule.h"
#import "NSDictionary+ZXSafetySet.h"
#import "NSString+ZXRegular.h"
#import "NSObject+ZXToJson.h"
#import "NSObject+ZXToDic.h"
@implementation NSObject (ZXToModel)
+(instancetype)zx_modelWithDic:(NSMutableDictionary *)dic{
    if([ZXDataType isFoudationClass:self]){
        return nil;
    }
    Class selfCalss = [self class];
    id modelObj = [[selfCalss alloc]init];
    [self getEnumPropertyNamesCallBack:^(NSString *proName,NSString *proType) {
        NSString *dicKeyProName = [self getReplacedProName:proName];
        id value = [dic zx_dicSafetyReadForKey:dicKeyProName];
        BOOL isinIgnorePros = [[self class] isinIgnorePros:proName];
        if(value != NULL && !isinIgnorePros){
            DataType dataType = [ZXDataType zx_dataType:value];
            if(dataType == DataTypeDic){
                NSArray *proTypeArr = [proType componentsSeparatedByString:@","];
                if(proTypeArr.count > 0){
                    NSString *subClassStr = proTypeArr[0];
                    subClassStr = [subClassStr matchStrWithPre:@"\"" sub:@"\""];
                    Class subClass = NSClassFromString(subClassStr);
                    if(subClass){
                        id subModel = [subClass zx_modelWithDic:value];
                        if(subModel){
                            [modelObj zx_objSaftySetValue:subModel forKey:proName];
                        }else{
                            [modelObj zx_objSaftySetValue:value forKey:proName];
                        }
                    }else{
                        id subModel = nil;
                        NSDictionary *inArrModelNameDic = [self getInArrModelNameDic];
                        if(inArrModelNameDic){
                            NSString *subClassStr = [inArrModelNameDic zx_dicSafetyReadForKey:proName];
                            if(subClassStr.length){
                                if(subClassStr){
                                    Class subClass = NSClassFromString(subClassStr);
                                    if(subClass){
                                        subModel = [[subClass class] zx_modelWithDic:value];
                                        
                                    }
                                }
                            }
                        }
                        [modelObj zx_objSaftySetValue:subModel ? subModel :value forKey:proName];
                    }
                }
            }else if(dataType == DataTypeArr){
                NSMutableArray *subMuArr = [NSMutableArray array];
                for (id subObj in value) {
                    DataType subDataType = [ZXDataType zx_dataType:subObj];
                    if(subDataType == DataTypeDic){
                        NSDictionary *inArrModelNameDic = [self getInArrModelNameDic];
                        if(inArrModelNameDic){
                            NSString *subClassStr = [inArrModelNameDic zx_dicSafetyReadForKey:proName];
                            if(subClassStr.length){
                                id subModel = subObj;
                                if(subClassStr){
                                    Class subClass = NSClassFromString(subClassStr);
                                    if(subClass){
                                        subModel = [[subClass class] zx_modelWithDic:subObj];
                                    }
                                }
                                [subMuArr addObject:subModel];
                            }else{
                                [subMuArr addObject:subObj];
                            }
                        }else{
                            [subMuArr addObject:subObj];
                        }
                        
                    }else if(subDataType == DataTypeArr){
                        id subModel = [[subObj class] zx_modelWithArr:subObj];
                        [subMuArr addObject:subModel];
                    }else{
                        [subMuArr addObject:subObj];
                    }
                    
                }
                [modelObj zx_objSaftySetValue:subMuArr forKey:proName];
            }else{
                if(dataType == DataTypeNormalObj || dataType == DataTypeStr){
                    if([proType hasPrefix:@"T@\"NSNumber\""]){
                        if(dataType == DataTypeStr && [ZXDataType isNumberType:value]){
                            value = [ZXDecimalNumberTool zx_decimalNumber:[value doubleValue]];
                            
                            [modelObj zx_objSaftySetValue:@([value doubleValue]) forKey:proName];
                        }else{
                            [modelObj zx_objSaftySetValue:value forKey:proName];
                        }
                        
                    }else if([proType hasPrefix:@"T@"]){
                        value = [ZXDataConvert handleValueToMatchModelPropertyTypeWithValue:value type:proType];
                        [modelObj zx_objSaftySetValue:value forKey:proName];
                    }else{
                        value = [ZXDecimalNumberTool zx_decimalNumber:[value doubleValue]];
                        [modelObj zx_objSaftySetValue:value forKey:proName];
                    }
                }else{
                    if(dataType == DataTypeFloat || dataType == DataTypeDouble || dataType == DataTypeInt || dataType == DataTypeBool || dataType == DataTypeLong){
                        value = [ZXDecimalNumberTool zx_decimalNumber:[value doubleValue]];
                    }
                    value = [ZXDataConvert handleValueToMatchModelPropertyTypeWithValue:value type:proType];
                    [modelObj zx_objSaftySetValue:value forKey:proName];
                }
            }
        }
    }];
    return modelObj;
}
+(instancetype)zx_modelWithArr:(NSMutableArray *)arr{
    NSMutableArray *resArr = [NSMutableArray array];
    for (id subObj in arr) {
        DataType subDataType = [ZXDataType zx_dataType:subObj];
        id resObj = nil;
        if(subDataType == DataTypeDic){
            resObj = [self zx_modelWithDic:subObj];
        }
        if(subDataType == DataTypeArr){
            resObj = [self zx_modelWithArr:subObj];
        }
        if(resObj){
            [resArr addObject:resObj];
        }
    }
    return resArr;
}
+(id)zx_modelWithObj:(id)obj{
    DataType subDataType = [ZXDataType zx_dataType:obj];
    id resObj = nil;
    if([self isKindOfClass:[NSData class]]){
        NSString *jsonStr = [self zx_toJsonStr];
        return [self zx_modelWithObj:jsonStr];
    }
    if(subDataType == DataTypeStr){
        NSString *jsonStr = (NSString *)obj;
        id dicObj = [jsonStr zx_toDic];
        DataType subJsonDataType = [ZXDataType zx_dataType:dicObj];
        if(subJsonDataType == DataTypeDic){
            resObj = [self zx_modelWithDic:dicObj];
        }
        if(subJsonDataType == DataTypeArr){
            resObj = [self zx_modelWithArr:dicObj];
        }
    }else{
        if(subDataType == DataTypeDic){
            resObj = [self zx_modelWithDic:obj];
        }
        if(subDataType == DataTypeArr){
            resObj = [self zx_modelWithArr:obj];
        }
    }
    return resObj;
}


+(NSDictionary *)zx_inArrModelName{
    return nil;
}

+(NSDictionary *)zx_replaceProName{
    return nil;
}

+(NSString *)zx_replaceProName121:(NSString *)proName{
    return nil;
}

@end
