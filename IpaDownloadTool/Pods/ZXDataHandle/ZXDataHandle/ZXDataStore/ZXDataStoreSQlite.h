//
//  ZXDataStoreSQlite.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>
#import "SqlResult.h"
///数据库存储路径

NS_ASSUME_NONNULL_BEGIN
@interface ZXDataStoreSQlite : NSObject
+ (instancetype)shareInstance;
///获取当前db
+(id)getDb;
///删除当前数据库
+(BOOL)dropDb;
///执行一句sql语句，hasRes为是否需要查询结果，执行查询语句时才需要查询结果
+(SqlResult *)executeSql:(NSString *)sql res:(BOOL)hasRes;
///批量执行sql语句
+(SqlResult *)executeSqls:(NSArray *)sqls;
///将对象属性的类型转化为sql字段的类型
+(NSString *)getSqlValueTypeWithProType:(NSString *)proType;
///获取可以识别的运算符数组
+(NSArray *)sqlSymbolArr;
///存储所有已经存在的table名
@property(nonatomic,strong)NSMutableArray *allJudgedExistTb;
///存储所有已判断是否需要更新的table名
@property(nonatomic,strong)NSMutableArray *allJudgedUpdateTb;
@end

NS_ASSUME_NONNULL_END
