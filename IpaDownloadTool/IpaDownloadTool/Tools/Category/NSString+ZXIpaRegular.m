//
//  NSString+ZXIpaRegular.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "NSString+ZXIpaRegular.h"
#import "ZXDataHandle.h"
@implementation NSString (ZXIpaRegular)
-(NSString *)getPlistPathUrlStr{
    NSString *resStr;
    NSString *prefix;
    resStr = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if([resStr containsString:@"itemService="]){
        prefix = @"itemService=";
    }else{
        prefix = @"url=";
    }
    NSRange urlRange = [resStr rangeOfString:[NSString stringWithFormat:@"%@.*?",prefix] options:NSRegularExpressionSearch];
    resStr = [resStr substringWithRange:NSMakeRange(urlRange.location + prefix.length, resStr.length - (urlRange.location + prefix.length))];
   
    return resStr;
}

@end
