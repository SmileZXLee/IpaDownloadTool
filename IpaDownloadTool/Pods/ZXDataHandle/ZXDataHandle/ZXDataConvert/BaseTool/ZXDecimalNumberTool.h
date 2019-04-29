//
//  ZXDecimalNumberTool.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  精度处理

#import <Foundation/Foundation.h>

@interface ZXDecimalNumberTool : NSObject
///利用DecimalNumber将double转为float
+ (float)zx_toFloatWithNumber:(double)num;
///利用DecimalNumber将double转为double
+ (double)zx_toDoubleWithNumber:(double)num;
///利用DecimalNumber将double转为string
+ (NSString *)zx_toStringWithNumber:(double)num;
///利用DecimalNumber将double转为NSDecimalNumber
+ (NSDecimalNumber *)zx_decimalNumber:(double)num;
@end
