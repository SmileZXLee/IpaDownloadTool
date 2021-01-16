//
//  NSObject+ZXSQliteHandle.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSObject+ZXSQliteHandle.h"
#import "NSObject+ZXToModel.h"
#import "NSDictionary+ZXSafetySet.h"
#import "ZXDataStoreSQlite.h"
#import "ZXDataType.h"
#import "NSString+ZXRegular.h"
#import "ZXDataStoreSQlite.h"
#import "NSMutableArray+ZXSafetySet.h"
#import <sqlite3.h>
#import "NSObject+ZXGetProperty.h"
#import "NSObject+ZXSafetySet.h"
#import "ZXDataHandleLog.h"
#import <objc/message.h>
#define TbName NSStringFromClass([self class])
@implementation NSObject (ZXSQliteHandle)

#pragma mark 存储数据到当前表中（支持批量存储）
-(BOOL)zx_dbSave{
    if([ZXDataType isFoudationClass:self]){
        if([ZXDataType zx_dataType:self] == DataTypeArr){
            if([self isKindOfClass:[NSArray class]]){
                NSArray *objArr = [self mutableCopy];
                if(!objArr.count){
                    return NO;
                }
                NSMutableArray *sqlArr = [NSMutableArray array];
                for (id subObj in objArr) {
                    if([subObj isKindOfClass:[NSArray class]]){
                        [subObj zx_dbSave];
                    }else{
                        if(![ZXDataType isFoudationClass:subObj]){
                            BOOL creatTableSucc = [[subObj class] zx_dbCreatTable];
                            if(creatTableSucc){
                                BOOL updateTableSucc = [[subObj class] zx_dbUpdateTableFields];
                                if(updateTableSucc){
                                    NSString *insertSql = [self getAlertSqlWithObj:subObj alertType:AlertTypeInsert];
                                    [sqlArr addObject:insertSql];
                                }else{
                                    ZXDataHandleLog(@"表字段更新出错，请检查表：%@",NSStringFromClass([subObj class]));
                                }
                            }else{
                                 ZXDataHandleLog(@"表创建失败，表名：%@",NSStringFromClass([subObj class]));
                                return NO;
                            }
                        }
                        
                    }
                }
                SqlResult *res = [ZXDataStoreSQlite executeSqls:sqlArr];
                return res.success;
            }
        }
        return NO;
    }
    BOOL creatTableSucc = [[self class] zx_dbCreatTable];
    if(creatTableSucc){
        BOOL updateTableSucc = [[self class] zx_dbUpdateTableFields];
        if(updateTableSucc){
            NSString* insertSql = [self getAlertSqlWithObj:self alertType:AlertTypeInsert];
            if(insertSql.length){
                SqlResult *res = [ZXDataStoreSQlite executeSql:insertSql res:NO];
                return res.success;
            }
        }else{
            ZXDataHandleLog(@"表字段更新出错，请检查表：%@",NSStringFromClass([self class]));
        }
        
        return NO;
    }else{
        ZXDataHandleLog(@"表创建失败，表名：%@",NSStringFromClass([self class]));
    }
    return NO;
    
}

#pragma mark 从当前表中删除数据，where语句支持字典或sql字符串，字典默认使用AND连接，键值对比较为等号，其他情况请使用zx_dbDropWhereArg
+(BOOL)zx_dbDropWhere:(id)where{
    NSString *whereStr = [[self class] getWhereSqlWithObj:where];
    NSString *whereSql = whereStr.length ? [NSString stringWithFormat:@"WHERE %@",whereStr] : @"";
    NSString *dropSql = [NSString stringWithFormat:@"DELETE FROM %@ %@",TbName,whereSql];
    SqlResult *res = [ZXDataStoreSQlite executeSql:dropSql res:NO];
    return res.success;
}

#pragma mark 从当前表中删除数据，where语句多参数拼接
+(BOOL)zx_dbDropWhereArg:(NSString *)arg1,...{
    va_list args;
    va_start(args,arg1);
    return [[self zx_dbAlertWhereArg:@selector(zx_dbDropWhere:)returnType:ReturnTypeBool owner:self args:args arg1:arg1] boolValue];
}

#pragma mark 从当前表中查询数据并直接返回对象数组，where语句支持字典或sql字符串，字典默认使用AND连接，键值对比较为等号，其他情况请使用zx_dbQuaryWhereArg
+(NSArray *)zx_dbQuaryWhere:(id)where{
    NSString *whereStr = [self getWhereSqlWithObj:where];
    NSString *whereSql = whereStr.length ? [NSString stringWithFormat:@"WHERE %@",whereStr] : @"";
    NSString* quarySql = [NSString stringWithFormat:@"SELECT * FROM %@ %@",TbName,whereSql];
    SqlResult *res = [ZXDataStoreSQlite executeSql:quarySql res:YES];
    if(res.resData.count){
        NSArray *selfModelArr = [self zx_modelWithObj:res.resData];
        return selfModelArr;
    }
    return nil;
}
#pragma mark 从当前表中查询数据，where语句多参数拼接
+(NSArray *)zx_dbQuaryWhereArg:(NSString *)arg1,...{
    va_list args;
    va_start(args,arg1);
    return [self zx_dbAlertWhereArg:@selector(zx_dbQuaryWhere:)returnType:ReturnTypeArr owner:self args:args arg1:arg1];
}
#pragma mark 从当前表中查询所有数据
+(NSArray *)zx_dbQuaryAll{
    return [self zx_dbQuaryWhere:@""];
}

#pragma mark 根据当前对象从当前表中修改数据，where语句支持字典或sql字符串，字典默认使用AND连接，键值对比较为等号，其他情况请使用zx_dbUpdateWhereArg
-(BOOL)zx_dbUpdateWhere:(id)where{
    BOOL updateTableSucc = [[self class] zx_dbUpdateTableFields];
    if(updateTableSucc){
        NSString *whereStr = [[self class] getWhereSqlWithObj:where];
        NSString *whereSql = whereStr.length ? [NSString stringWithFormat:@"WHERE %@",whereStr] : @"";
        NSString *setSql = [self getAlertSqlWithObj:self alertType:AlertTypeUpdate];
        NSString *updateSql = [NSString stringWithFormat:@"%@ %@",setSql,whereSql];
        SqlResult *res = [ZXDataStoreSQlite executeSql:updateSql res:NO];
        return res.success;
    }else{
        ZXDataHandleLog(@"表字段更新出错，请检查表：%@",TbName);
        return NO;
    }
    
}
#pragma mark 根据当前对象从当前表中修改数据，where语句多参数拼接
-(BOOL)zx_dbUpdateWhereArg:(NSString *)arg1,...{
    va_list args;
    va_start(args,arg1);
    return [[[self class] zx_dbAlertWhereArg:@selector(zx_dbUpdateWhere:)returnType:ReturnTypeBool owner:self args:args arg1:arg1] boolValue];
}
#pragma mark 传入一个字典从当前表中修改数据，where语句支持字典或sql字符串，字典默认使用AND连接，键值对比较为等号，其他情况请使用zx_dbUpdateDic:whereArg:
+(BOOL)zx_dbUpdateDic:(NSDictionary *)updateDic where:(id)where{
    BOOL updateTableSucc = [[self class] zx_dbUpdateTableFields];
    if(!updateTableSucc){
        ZXDataHandleLog(@"表字段更新出错，请检查表：%@",TbName);
        return NO;
    }
    NSString *objName = NSStringFromClass(self);
    __block NSString *setStr = @"";
    NSString *alertSql = @"";
    [self getEnumPropertyNamesCallBack:^(NSString *proName, NSString *proType) {
        id valObj = [updateDic zx_dicSafetyReadForKey:proName];
        if(valObj){
            int numValue = -1;
            DataType dataType = [ZXDataType zx_dataType:valObj];
            if(dataType == DataTypeBool || dataType == DataTypeInt || dataType == DataTypeLong || dataType == DataTypeFloat || dataType == DataTypeDouble){
                if(dataType == DataTypeBool || dataType == DataTypeInt || dataType == DataTypeLong){
                    valObj = [NSString stringWithFormat:@"%ld",[valObj longValue]];
                }else{
                    valObj = [NSString stringWithFormat:@"%lf",[valObj doubleValue]];
                }
                numValue = 1;
            }else if(dataType == DataTypeStr){
                numValue = 0;
            }
            if(numValue != -1){
                valObj = [valObj removeAllElement:@" "];
                if([valObj hasPrefix:proName] || [valObj hasPrefix:@"+="] || [valObj hasPrefix:@"-="]){
                    if([valObj hasPrefix:proName]){
                        setStr = [setStr stringByAppendingString:[NSString stringWithFormat:@"%@ = %@,",proName,valObj]];
                    }else if([valObj hasPrefix:@"+="]){
                        NSString *incNum = [valObj removeAllElement:@"+="];
                        setStr = [setStr stringByAppendingString:[NSString stringWithFormat:@"%@ = %@+%@,",proName,proName,incNum]];
                    }else{
                        NSString *incNum = [valObj removeAllElement:@"-="];
                        setStr = [setStr stringByAppendingString:[NSString stringWithFormat:@"%@ = %@-%@,",proName,proName,incNum]];
                    }
                }else{
                    setStr = numValue == 1 ? [setStr stringByAppendingString:[NSString stringWithFormat:@"%@ = %@,",proName,valObj]] : [setStr stringByAppendingString:[NSString stringWithFormat:@"%@ = '%@',",proName,valObj]];
                }
            }
            
        }
    }];
    if(setStr.length){
        setStr = [setStr substringToIndex:setStr.length - 1];
        alertSql = [NSString stringWithFormat:@"UPDATE %@ SET %@",objName,setStr];
        NSString *whereStr = [self getWhereSqlWithObj:where];
        NSString *whereSql = whereStr.length ? [NSString stringWithFormat:@"WHERE %@",whereStr] : @"";
        NSString *updateSql = [NSString stringWithFormat:@"%@ %@",alertSql,whereSql];
        SqlResult *res = [ZXDataStoreSQlite executeSql:updateSql res:NO];
        return res.success;
    }
    return NO;
}

#pragma mark 传入一个字典从当前表中修改数据，where语句多参数拼接
+(BOOL)zx_dbUpdateDic:(NSDictionary *)updateDic whereArg:(NSString *)arg1,...{
    NSString *whereSql = @"";
    va_list args;
    va_start(args,arg1);
    id eachObject;
    if (arg1) {
        whereSql = [whereSql stringByAppendingString:[NSString stringWithFormat:@"%@ ",arg1]];
        while ((eachObject = va_arg(args, id))) {
            whereSql = [whereSql stringByAppendingString:[NSString stringWithFormat:@"%@ ",eachObject]];
        }
        va_end(args);
    }
    if(whereSql.length){
        whereSql = [whereSql substringToIndex:whereSql.length - 1];
    }
    return [self zx_dbUpdateDic:updateDic where:whereSql];
}

#pragma mark 创建当前表
+(BOOL)zx_dbCreatTable{
    if([self zx_dbExistTableWithTbName:TbName]){
        return YES;
    }
    __block NSString *creatTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'(id integer primary key autoincrement,",TbName];
    __block BOOL hasValue = NO;
    [self getEnumPropertyNamesCallBack:^(NSString *proName, NSString *proType) {
        NSString *sqlValueType = [ZXDataStoreSQlite getSqlValueTypeWithProType:proType];
        if(sqlValueType.length){
            NSString *perProStr = [NSString stringWithFormat:@"'%@' %@,",proName,sqlValueType];
            creatTableSql = [creatTableSql stringByAppendingString:perProStr];
            hasValue = YES;
        }
    }];
    if(hasValue){
        creatTableSql = [creatTableSql substringToIndex:creatTableSql.length - 1];
        creatTableSql = [creatTableSql stringByAppendingString:@")"];
        SqlResult *res = [ZXDataStoreSQlite executeSql:creatTableSql res:NO];
        return res.success;
    }
    return NO;
}
#pragma mark 更新当前表中的字段
+(BOOL)zx_dbUpdateTableFields{
    if([[ZXDataStoreSQlite shareInstance].allJudgedUpdateTb containsObject:TbName]){
        return YES;
    }
    NSString *tbNamesSql = [NSString stringWithFormat:@"PRAGMA TABLE_INFO(%@)",TbName];
    SqlResult *res = [ZXDataStoreSQlite executeSql:tbNamesSql res:YES];
    NSMutableArray *fieldsArr = [NSMutableArray array];
    NSMutableDictionary *prosMuDic = [NSMutableDictionary dictionary];
    [self getEnumPropertyNamesCallBack:^(NSString *proName, NSString *proType) {
        NSString *sqlValueType = [ZXDataStoreSQlite getSqlValueTypeWithProType:proType];
        if(sqlValueType.length){
            [prosMuDic zx_dicSaftySetValue:sqlValueType forKey:proName];
        }
    }];
    for (NSDictionary *resDic in res.resData) {
        NSString *fieldStr = [resDic zx_dicSafetyReadForKey:@"name"];
        [fieldsArr addObject:fieldStr];
    }
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", fieldsArr];
    NSMutableArray *proKeysArr = [prosMuDic.allKeys mutableCopy];
    [proKeysArr filterUsingPredicate:thePredicate];
    BOOL allSucc = YES;
    for (NSString *name in proKeysArr) {
        NSString *proType = [prosMuDic zx_dicSafetyReadForKey:name];
        if(proType.length){
            NSString *preSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN ",TbName];
            preSql = [preSql stringByAppendingString:[NSString stringWithFormat:@"%@ %@",name,[prosMuDic zx_dicSafetyReadForKey:name]]];
            BOOL succ = [ZXDataStoreSQlite executeSql:preSql res:NO].success;
            if(!succ){
                allSucc = NO;
            }
        }
        
    }
    if(allSucc){
        [[ZXDataStoreSQlite shareInstance].allJudgedUpdateTb zx_arrSafetyAddObjNORepetition:TbName];
    }
    return allSucc;
}
#pragma mark 删除当前表
+(BOOL)zx_dbDropTable{
    NSString *dropTableSql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",TbName];
    SqlResult *res = [ZXDataStoreSQlite executeSql:dropTableSql res:NO];
    if(res.success){
        [[ZXDataStoreSQlite shareInstance].allJudgedExistTb zx_arrSafetyRemoveObj:TbName];
    }
    return res.success;
}
#pragma mark - Private
#pragma mark 判断当前表是否存在
+(BOOL)zx_dbExistTableWithTbName:(NSString *)tbName{
    if([[ZXDataStoreSQlite shareInstance].allJudgedExistTb containsObject:tbName]){
        return YES;
    }
    NSString *isExistsSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM SQLITE_MASTER WHERE TYPE='table' AND NAME='%@'",tbName];
    SqlResult *res1 = [ZXDataStoreSQlite executeSql:isExistsSql res:YES];
    NSArray *countsArr = res1.resData;
    if(countsArr && countsArr.count){
        NSDictionary *firstDic = countsArr.firstObject;
        int count = [[firstDic zx_dicSafetyReadForKey:@"COUNT(*)"] intValue];
        if(count != 0){
            [[ZXDataStoreSQlite shareInstance].allJudgedExistTb zx_arrSafetyAddObjNORepetition:tbName];
            return YES;
        }
    }
    return NO;
}
#pragma mark 修改表（删和改）where语句多参数的处理
+(id)zx_dbAlertWhereArg:(SEL)sel returnType:(ReturnType)returnType owner:(id)owner args:(va_list)args arg1:(NSString *)arg1,... {
    NSString *whereSql = @"";
    id eachObject;
    if (arg1) {
        whereSql = [whereSql stringByAppendingString:[NSString stringWithFormat:@"%@ ",arg1]];
        while ((eachObject = va_arg(args, id))) {
            whereSql = [whereSql stringByAppendingString:[NSString stringWithFormat:@"%@ ",eachObject]];
        }
        va_end(args);
    }
    if(whereSql.length){
        whereSql = [whereSql substringToIndex:whereSql.length - 1];
    }
    IMP imp = [self methodForSelector:sel];
    if(returnType == ReturnTypeBool){
        BOOL (*func)(id, SEL, NSString*) = (void *)imp;
        BOOL res = func(owner, sel, whereSql);
        return [NSNumber numberWithBool:res];
    }else{
        NSArray* (*func)(id, SEL, NSString*) = (void *)imp;
        return func(owner, sel, whereSql);
    }
}

#pragma mark 通过字典或字符串对象返回where语句
+(NSString *)getWhereSqlWithObj:(id)obj{
    DataType dataType = [ZXDataType zx_dataType:obj];
    if(dataType == DataTypeDic){
        __block NSString *whereSql = @"";
        [obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *symbol = @"=";
            for (NSString *supSymbol in [ZXDataStoreSQlite sqlSymbolArr]) {
                if([obj hasPrefix:supSymbol]){
                    symbol = supSymbol;
                    obj = [obj substringFromIndex:symbol.length];
                }
            }
            if([obj isKindOfClass:[NSString class]]){
                whereSql = [whereSql stringByAppendingString:[NSString stringWithFormat:@"%@ %@ '%@' AND",key,symbol,obj]];
            }else if([obj isKindOfClass:[NSNumber class]]){
                whereSql = [whereSql stringByAppendingString:[NSString stringWithFormat:@"%@ %@ %@ AND",key,symbol,obj]];
            }
        }];
        if(whereSql.length){
            whereSql = [whereSql substringToIndex:whereSql.length - 4];
        }
        return whereSql;
        
    }else if(dataType == DataTypeStr){
        return obj;
    }
    return @"";
}

#pragma mark 修改表（增和改）属性名和value处理并返回对应sql语句
-(NSString *)getAlertSqlWithObj:(id)obj alertType:(AlertType)alertType{
    NSString *objName = NSStringFromClass([obj class]);
    NSArray *proNamesArr = [[obj class]getAllPropertyNames];
    NSString *prosStr = @"";
    NSString *valuesStr = @"";
    NSString *setStr = @"";
    for (NSString *proName in proNamesArr) {
        id value = [obj zx_objSafetyReadForKey:proName];
        int legalValue = -1;
        DataType dataType = [ZXDataType zx_dataType:value];
        if(dataType == DataTypeBool || dataType == DataTypeInt || dataType == DataTypeLong || dataType == DataTypeFloat || dataType == DataTypeDouble){
            if(dataType == DataTypeBool || dataType == DataTypeInt || dataType == DataTypeLong){
                value = [NSString stringWithFormat:@"%ld",[value longValue]];
            }else{
                value = [NSString stringWithFormat:@"%lf",[value doubleValue]];
            }
            legalValue = 0;
            if(alertType == AlertTypeUpdate && [value floatValue] == 0){
                legalValue = -1;
            }
        }else if(dataType == DataTypeStr){
            legalValue = 1;
        }
        if(legalValue != -1){
            if(alertType == AlertTypeInsert){
                valuesStr = legalValue == 0 ? [valuesStr stringByAppendingString:[NSString stringWithFormat:@"%@,",value ? value : @""]] : [valuesStr stringByAppendingString:[NSString stringWithFormat:@"'%@',",value ? value : @""]];
                prosStr = [prosStr stringByAppendingString:[NSString stringWithFormat:@"%@,",proName]];
            }
            if(value && alertType == AlertTypeUpdate){
                setStr = legalValue == 0 ? [setStr stringByAppendingString:[NSString stringWithFormat:@"%@ = %@,",proName,value]] : [setStr stringByAppendingString:[NSString stringWithFormat:@"%@ = '%@',",proName,value]];
            }
        }
    }
    if(prosStr.length || setStr.length){
        NSString* alertSql = @"";
        if(alertType == AlertTypeInsert){
            prosStr = [prosStr substringToIndex:prosStr.length - 1];
            valuesStr = [valuesStr substringToIndex:valuesStr.length - 1];
            alertSql = [NSString stringWithFormat:@"INSERT INTO %@(%@)values(%@)",objName,prosStr,valuesStr];
        }else if (alertType == AlertTypeUpdate){
            setStr = [setStr substringToIndex:setStr.length - 1];
            alertSql = [NSString stringWithFormat:@"UPDATE %@ SET %@",objName,setStr];
        }
        return alertSql;
    }
    return nil;
}
@end
