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

-(NSString *)getWebFaviconStrWithHostUrl:(NSString *)hostUrl{
    
    return @"";
}

- (NSDictionary *)parseToQuery{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [elements[0] stringByRemovingPercentEncoding];
        NSString *val = [elements[1] stringByRemovingPercentEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (NSString *)replaceKeysWithValuesInDict:(NSDictionary *)dic {
    NSMutableString *result = [self mutableCopy];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [result replaceOccurrencesOfString:key withString:obj options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    }];
    return [result copy];
}


- (BOOL)matchesAnyRegexInArr:(NSArray<NSString *> *)regexArr {
    @try {
        NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:regexArr.count];
        for (NSString *regex in regexArr) {
            NSString *pattern = [regex stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
            pattern = [pattern stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
            pattern = [NSString stringWithFormat:@"^%@$", pattern];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
            [predicates addObject:predicate];
        }
        NSPredicate *orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
        return [orPredicate evaluateWithObject:self];
    }
    @catch (NSException *exception) {
        return NO;
    }
    
}
@end
