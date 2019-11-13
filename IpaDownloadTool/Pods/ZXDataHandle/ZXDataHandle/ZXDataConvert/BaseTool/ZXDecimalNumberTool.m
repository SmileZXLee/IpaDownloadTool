//
//  ZXDecimalNumberTool.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "ZXDecimalNumberTool.h"

@implementation ZXDecimalNumberTool
+ (float)zx_toFloatWithNumber:(double)num{
    return [[self zx_decimalNumber:num] floatValue];
}

+ (double)zx_toDoubleWithNumber:(double)num {
    return [[self zx_decimalNumber:num] doubleValue];
}

+ (NSString *)zx_toStringWithNumber:(double)num {
    return [[self zx_decimalNumber:num] stringValue];
}

+ (NSDecimalNumber *)zx_decimalNumber:(double)num {
    NSString *numString = [NSString stringWithFormat:@"%lf", num];
    return [NSDecimalNumber decimalNumberWithString:numString];
}
@end
