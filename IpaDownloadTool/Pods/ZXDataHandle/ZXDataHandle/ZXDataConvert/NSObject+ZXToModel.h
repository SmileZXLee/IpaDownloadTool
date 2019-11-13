//
//  NSObject+ZXToModel.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  model赋值

#import <Foundation/Foundation.h>

@interface NSObject (ZXToModel)
///字典转模型
+(instancetype)zx_modelWithDic:(NSMutableDictionary *)dic;
///任意类型转模型
+(id)zx_modelWithObj:(id)obj;
@end
