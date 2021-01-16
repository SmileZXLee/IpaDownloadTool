//
//  NSArray+ZXDataConvert.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSArray+ZXDataConvert.h"
#import "ZXDataHandleLog.h"
@implementation NSArray (ZXDataConvert)
-(NSString *)zx_arrToJsonStr{
    NSData *jsonData = [self zx_arrToJSONData];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSData *)zx_arrToJSONData{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        ZXDataHandleLog(@"数组%@无法转化为Json字符串--error:%@",self,error);
        return nil;
    }
}
@end
