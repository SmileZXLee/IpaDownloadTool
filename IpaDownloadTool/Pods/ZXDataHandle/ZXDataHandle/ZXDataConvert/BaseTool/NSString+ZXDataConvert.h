//
//  NSString+ZXDataConvert.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ZXDataConvert)
///json转字典
-(id)zx_jsonToDic;
///下划线转驼峰
-(NSString *)strToHump;
///驼峰转下划线
-(NSString *)strToUnderLine;
@end

NS_ASSUME_NONNULL_END
