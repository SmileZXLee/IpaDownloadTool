//
//  NSString+ZXRegular.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>

@interface NSString (ZXRegular)
-(NSString *)regularWithPattern:(NSString *)pattern;
-(NSArray *)regularsWithPattern:(NSString *)pattern;
-(NSString *)matchStrWithPre:(NSString *)pre sub:(NSString *)sub;
-(NSArray *)matchsStrWithPre:(NSString *)pre sub:(NSString *)sub;
-(NSString *)removeAllElement:(NSString *)element;
-(NSString *)removeAllElements:(NSArray *)elements;
@end
