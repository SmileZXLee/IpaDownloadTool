//
//  ZXDataConvert.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>
#import "ZXDataConvertConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZXDataConvert : NSObject
+ (instancetype)shareInstance;
@property(nonatomic,strong)NSMutableDictionary *allPropertyDic;

/**
 字典转模型model赋值前都会走这个回调，可以在赋值之前对其进行修改
 key:属性名
 orgValue:属性名对应的即将被赋值的Value
 owner:属性所属的对象
 */
@property(nonatomic,copy)id(^zx_dataConvertSetterBlock)(NSString *key, id orgValue,id owner);

@property(nonatomic,strong)ZXDataConvertConfig *zx_dataConvertConfig;

/**
 字典转模型时，自动调整赋值的value，使其类型与模型中对应属性类型一致

 @param value 赋值的value
 @param proType 模型中对应属性类型
 */
+ (id)handleValueToMatchModelPropertyTypeWithValue:(id)value type:(NSString *)proType;
@end

NS_ASSUME_NONNULL_END
