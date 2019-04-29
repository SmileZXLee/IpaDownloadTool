//
//  NSObject+ZXTbSafeValue.m
//  ZXTableView
//
//  Created by 李兆祥 on 2019/3/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXTableView

#import "NSObject+ZXTbSafeValue.h"
@implementation NSObject (ZXTbSafeValue)
-(id)zx_safeValueForKey:(NSString *)key{
    if([self hasKey:key]){
        return [self valueForKey:key];
    }
    return nil;
}

-(void)zx_safeSetValue:(id)value forKey:(NSString *)key{
    if([self hasKey:key]){
        [self setValue:value forKey:key];
    }
}

-(BOOL)hasKey:(NSString *)key{
    return [self respondsToSelector:NSSelectorFromString(key)];
}
@end
