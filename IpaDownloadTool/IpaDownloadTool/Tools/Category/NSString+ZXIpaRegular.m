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
    resStr = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSRange urlRange = [resStr rangeOfString:@"url=.*?" options:NSRegularExpressionSearch];
    resStr = [resStr substringWithRange:NSMakeRange(urlRange.location + 4, resStr.length - (urlRange.location + 4))];
    return resStr;
}

@end
