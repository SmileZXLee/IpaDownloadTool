//
//  NSObject+ZXSQliteHandle.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum {
    AlertTypeInsert = 0x00,    // 修改类型：插入数据
    AlertTypeUpdate = 0x01,    // 修改类型：更新数据
}AlertType;

typedef enum {
    ConnTypeAnd = 0x00,    // where语句字典连接词AND
    ConnTypeOr = 0x01,    // where语句字典连接词OR
}ConnType;

typedef enum {
    ReturnTypeBool = 0x00,    // zx_dbAlertWhereArg返回类型Bool
    ReturnTypeArr = 0x01,    // zx_dbAlertWhereArg返回类型Arr
}ReturnType;

@interface NSObject (ZXSQliteHandle)
#pragma mark 以下三个一般由内部自动处理，真正需要的时候再自行调用
///创建与当前类同名的table，字段对应类的属性
+(BOOL)zx_dbCreatTable;
///删除与当前类同名的table
+(BOOL)zx_dbDropTable;
///更新当前表字段
+(BOOL)zx_dbUpdateTableFields;

///将当前对象存储到同名表中
-(BOOL)zx_dbSave;

///删除一条或多条数据，where可以是字典或一段where之后的运算符，nil或空字符串代表所有数据
+(BOOL)zx_dbDropWhere:(id)where;
///删除一条或多条数据，可以传入多个参数，多个参数拼接成where语句，nil或空字符串代表所有数据
+(BOOL)zx_dbDropWhereArg:(NSString *)arg1,...;


///根据当前对象更新一条或多条数据，where可以是字典或一段where之后的运算符，nil或空字符串代表所有数据
-(BOOL)zx_dbUpdateWhere:(id)where;
///根据当前对象更新一条或多条数据，可以传入多个参数，多个参数拼接成where语句，nil或空字符串代表所有数据
-(BOOL)zx_dbUpdateWhereArg:(NSString *)arg1,...;
///根据字典更新一条或多条数据，where可以是字典或一段where之后的运算符，nil或空字符串代表所有数据
+(BOOL)zx_dbUpdateDic:(NSDictionary *)updateDic where:(id)where;
///根据字典更新一条或多条数据，可以传入多个参数，多个参数拼接成where语句，nil或空字符串代表所有数据
+(BOOL)zx_dbUpdateDic:(NSDictionary *)updateDic whereArg:(NSString *)arg1,...;

///从当前表中查询数据并直接返回对象数组，where语句支持字典或sql字符串，字典默认使用AND连接，键值对比较为等号，其他情况请使用zx_dbQuaryWhereArg
+(NSArray *)zx_dbQuaryWhere:(id)where;
///从当前表中查询数据，where语句多参数拼接
+(NSArray *)zx_dbQuaryWhereArg:(NSString *)arg1,...;
///查询当前表中所有数据
+(NSArray *)zx_dbQuaryAll;
@end

NS_ASSUME_NONNULL_END
