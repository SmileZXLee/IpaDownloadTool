//
//  ZXClassPrint.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "ZXClassPrint.h"
#import "NSObject+ZXToJson.h"
@implementation ZXClassPrint
- (NSString *)description {
    return [self zx_toJsonStr];
}

@end
