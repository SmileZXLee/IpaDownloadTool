//
//  NSData+ZXDataConvert.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/2/25.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "NSData+ZXDataConvert.h"

@implementation NSData (ZXDataConvert)
-(NSString *)zx_dataToJsonStr{
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}
@end
