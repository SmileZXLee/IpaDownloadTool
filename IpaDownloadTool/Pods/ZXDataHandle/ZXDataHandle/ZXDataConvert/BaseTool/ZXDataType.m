//
//  ZXDataType.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "ZXDataType.h"
#import <UIKit/UIKit.h>
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
        return DataTypeLong;
    }
    if (strcmp([ifNumber objCType],@encode(long long)) == 0) {
        return DataTypeLong;
    }
    if (strcmp([ifNumber objCType],@encode(char)) == 0) {
        return DataTypeInt;
    }
    if (strcmp([ifNumber objCType],@encode(short)) == 0) {
        return DataTypeInt;
    }
    if (strcmp([ifNumber objCType],@encode(unsigned char)) == 0) {
        return DataTypeInt;
    }
    if (strcmp([ifNumber objCType],@encode(unsigned int)) == 0) {
        return DataTypeInt;
    }
    if (strcmp([ifNumber objCType],@encode(unsigned short)) == 0) {
        return DataTypeInt;
    }
    if (strcmp([ifNumber objCType],@encode(unsigned long long)) == 0) {
        return DataTypeLong;
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


+ (NSString *)getPropertyDecWithType:(NSString *)typeStr{
    NSDictionary *typeMapperDic = [self getTypeMapperDic];
    if([typeMapperDic.allKeys containsObject:typeStr]){
        return typeMapperDic[typeStr];
    }
    NSRange typeRange = [typeStr rangeOfString:@"\".*?\"" options:NSRegularExpressionSearch];
    if(typeRange.location == NSNotFound){
        typeRange = [typeStr rangeOfString:@"T.*?," options:NSRegularExpressionSearch];
        typeRange = NSMakeRange(typeRange.location + 1, typeRange.length - 2);
    }
    NSString *resTypeStr = [typeStr substringWithRange:typeRange];
    resTypeStr = [resTypeStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    if([typeMapperDic.allKeys containsObject:resTypeStr]){
        return typeMapperDic[resTypeStr];
    }
    return resTypeStr ;
}

+ (NSDictionary *)getTypeMapperDic{
    static NSDictionary *typeMapperDic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeMapperDic = @{[NSString stringWithUTF8String:@encode(char)] : @"char",
                          [NSString stringWithUTF8String:@encode(int)] : @"int",
                          [NSString stringWithUTF8String:@encode(short)] : @"short",
                          [NSString stringWithUTF8String:@encode(long)] : @"long",
                          [NSString stringWithUTF8String:@encode(long long)] : @"long long",
                          [NSString stringWithUTF8String:@encode(unsigned char)] : @"unsigned char",
                          [NSString stringWithUTF8String:@encode(unsigned int)] : @"unsigned int",
                          [NSString stringWithUTF8String:@encode(unsigned short)] : @"unsigned short",
                          [NSString stringWithUTF8String:@encode(unsigned long)] : @"unsigned long",
                          [NSString stringWithUTF8String:@encode(unsigned long long)] : @"unsigned long long",
                          [NSString stringWithUTF8String:@encode(float)] : @"float",
                          [NSString stringWithUTF8String:@encode(double)] : @"double",
                          [NSString stringWithUTF8String:@encode(BOOL)] : @"BOOL",
                          [NSString stringWithUTF8String:@encode(void)] : @"void",
                          [NSString stringWithUTF8String:@encode(char *)] : @"char *",
                          [NSString stringWithUTF8String:@encode(id)] : @"id",
                          [NSString stringWithUTF8String:@encode(Class)] : @"Class",
                          [NSString stringWithUTF8String:@encode(SEL)] : @"SEL",
                          [NSString stringWithUTF8String:@encode(CGRect)] : @"CGRect",
                          [NSString stringWithUTF8String:@encode(CGPoint)] : @"CGPoint",
                          [NSString stringWithUTF8String:@encode(CGSize)] : @"CGSize",
                          [NSString stringWithUTF8String:@encode(CGVector)] : @"CGVector",
                          [NSString stringWithUTF8String:@encode(CGAffineTransform)] : @"CGAffineTransform",
                          [NSString stringWithUTF8String:@encode(UIOffset)] : @"UIOffset",
                          [NSString stringWithUTF8String:@encode(UIEdgeInsets)] : @"UIEdgeInsets",
                          @"@?":@"block"
                          };
    });
    return typeMapperDic;
}
@end
