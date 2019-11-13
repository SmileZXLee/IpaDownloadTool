//
//  ZXDataType.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "ZXDataType.h"

@implementation ZXDataType
+(DataType)zx_dataType:(id)data{
    if([data isKindOfClass:[NSDictionary class]]){
        return DataTypeDic;
    }
    if([data isKindOfClass:[NSArray class]]){
        return DataTypeArr;
    }
    if([data isKindOfClass:[NSString class]]){
        return DataTypeStr;
    }
    NSNumber *ifNumber = (NSNumber *)data;
    if(![ifNumber isKindOfClass:[NSNumber class]]){
        return DataTypeNormalObj;
    }
    if (strcmp([ifNumber objCType],@encode(BOOL)) == 0) {
        return DataTypeBool;
    }
    if (strcmp([ifNumber objCType],@encode(int)) == 0) {
        return DataTypeInt;
    }
    if (strcmp([ifNumber objCType],@encode(long)) == 0) {
        return DataTypeInt;
    }
    if (strcmp([ifNumber objCType],@encode(float)) == 0) {
        return DataTypeFloat;
    }
    if (strcmp([ifNumber objCType],@encode(double)) == 0) {
        return DataTypeDouble;
    }
    return DataTypeUnknown;
    
}
+(BOOL)isNumberType:(NSString *)str{
    NSScanner* scan = [NSScanner scannerWithString:str];
    int iVal;
    float fVal;
    return ([scan scanInt:&iVal] && [scan isAtEnd]) || ([scan scanFloat:&fVal] && [scan isAtEnd]);
}
+(BOOL)isFoudationClass:(id)obj{
    return [NSBundle bundleForClass:[obj class]] != [NSBundle mainBundle];
}
@end
