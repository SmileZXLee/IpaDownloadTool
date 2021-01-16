//
//  NSDictionary+ZXDataConvert.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSDictionary+ZXDataConvert.h"
#import "ZXDataHandleLog.h"
@implementation NSDictionary (ZXDataConvert)
-(NSString *)zx_dicToJsonStr{
    NSData *jsonData = [self zx_dicToJSONData];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSData *)zx_dicToJSONData{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        ZXDataHandleLog(@"字典%@无法转化为Json字符串--error:%@",self,error);
        return nil;
    }
}
@end
