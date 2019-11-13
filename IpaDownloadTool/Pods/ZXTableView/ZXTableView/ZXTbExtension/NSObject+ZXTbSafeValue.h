//
//  NSObject+ZXTbSafeValue.h
//  ZXTableView
//
//  Created by 李兆祥 on 2019/3/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXTableView

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZXTbSafeValue)
-(id)zx_safeValueForKey:(NSString *)key;
-(void)zx_safeSetValue:(id)value forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
