//
//  NSDictionary+ZXSafetySet.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>

@interface NSDictionary (ZXSafetySet)
-(id)zx_dicSafetyReadForKey:(NSString *)key;
-(void)zx_dicSaftySetValue:(id)value forKey:(NSString *)key;
@end
