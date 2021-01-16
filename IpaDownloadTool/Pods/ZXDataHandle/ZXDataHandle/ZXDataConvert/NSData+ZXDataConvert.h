//
//  NSData+ZXDataConvert.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/2/25.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (ZXDataConvert)
///data转json字符串
-(NSString *)zx_dataToJsonStr;
@end

NS_ASSUME_NONNULL_END
