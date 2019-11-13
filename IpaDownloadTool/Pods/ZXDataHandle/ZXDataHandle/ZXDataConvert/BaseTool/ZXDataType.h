//
//  ZXDataType.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  判断数据类型

#import <Foundation/Foundation.h>
typedef enum {
    DataTypeNormalObj = 0x00,    // 其他对象类型
    DataTypeBool = 0x01,    // 布尔类型
    DataTypeInt = 0x02,    // int类型
    DataTypeLong = 0x03,   // long类型
    DataTypeFloat = 0x04,    // float类型
    DataTypeDouble = 0x05,    // double类型
    DataTypeDic = 0x06,     //字典类型
    DataTypeArr = 0x07,     //数组类型
    DataTypeStr = 0x08,     //字符串类型
    DataTypeUnknown = 0x09,    //未知类型
    
}DataType;
@interface ZXDataType : NSObject
+(DataType)zx_dataType:(id)data;
+(BOOL)isNumberType:(NSString *)str;
+(BOOL)isFoudationClass:(id)obj;
@end
