//
//  NSObject+ZXSafetySet.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZXSafetySet)
-(id)zx_objSafetyReadForKey:(NSString *)key;
-(void)zx_objSaftySetValue:(id)value forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
