//
//  ZXDataConvertConfig.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2020/11/14.
//  Copyright © 2020 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum {
    ZXDataValueAutoConvertModeEmpty = 0x00,// 当json/字典的value类型与model不一致时，model中对应value将被赋值为空，如NSArray，将被赋值为@[]
    ZXDataValueAutoConvertModeNil = 0x01,// 当json/字典的value类型与model不一致时，model中对应value将被赋值为nil
    ZXDataValueAutoConvertModeOrg = 0x02,// 当json/字典的value类型与model不一致时，model中对应value将被赋值为原json/字典的value
    
}ZXDataValueAutoConvertMode;

@interface ZXDataConvertConfig : NSObject
/// 当json/字典的value类型与model不一致时处理模式，默认为ZXDataValueAutoConvertModeEmpty
@property(nonatomic,assign) ZXDataValueAutoConvertMode zx_dataValueAutoConvertMode;
@end

NS_ASSUME_NONNULL_END
