//
//  NSString+ZXRegular.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSString+ZXRegular.h"

@implementation NSString (ZXRegular)
-(NSString *)regularWithPattern:(NSString *)pattern{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:0
                                  error:&error];
    if (!error) {
        NSTextCheckingResult *match = [regex firstMatchInString:self
                                                        options:0
                                                          range:NSMakeRange(0, [self length])];
        
        return match ? [self substringWithRange:match.range] : nil;
        
    } else {
        return nil;
    }
}
-(NSArray *)regularsWithPattern:(NSString *)pattern{
    NSString *regex = pattern;
    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&error];
    NSArray *matches = [regular matchesInString:self
                                        options:0
                                          range:NSMakeRange(0, self.length)];
    NSMutableArray *resultMuArr = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        NSString *mStr = [self substringWithRange:range];
        [resultMuArr addObject:mStr];
    }
    return resultMuArr;
}
-(NSString *)matchStrWithPre:(NSString *)pre sub:(NSString *)sub{
    return [[self regularWithPattern:[NSString stringWithFormat:@"%@.*?%@",pre,sub]] removeAllElements:@[pre,sub]];
}
-(NSArray *)matchsStrWithPre:(NSString *)pre sub:(NSString *)sub{
    NSArray *arr = [self regularsWithPattern:[NSString stringWithFormat:@"%@.*?%@",pre,sub]];
    NSMutableArray *muArr = [NSMutableArray array];
    for (NSString *matStr in arr) {
        [muArr addObject:[matStr removeAllElements:@[pre,sub]]];
    }
    return muArr;
}
-(NSString *)removeAllElement:(NSString *)element{
    return [self stringByReplacingOccurrencesOfString:element withString:@""];
}
-(NSString *)removeAllElements:(NSArray *)elements{
    NSString *resultStr = self;
    for (NSString *removeStr in elements) {
        resultStr = [resultStr removeAllElement:removeStr];
    }
    return resultStr;
}
@end
