//
//  NSArray+ZXDataConvert.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle



#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSArray (ZXDataConvert)
///字典数组转json字符串
-(NSString *)zx_arrToJsonStr;
///字典数组转jsonData
-(NSData *)zx_arrToJSONData;
@end


