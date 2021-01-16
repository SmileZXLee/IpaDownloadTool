//
//  ZXDataStoreSQlite.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "ZXDataStoreSQlite.h"
#import "ZXDataHandleLog.h"
#import <sqlite3.h>
#import "NSString+ZXRegular.h"
#import "NSDictionary+ZXSafetySet.h"
@implementation ZXDataStoreSQlite
static sqlite3 *db;
+ (instancetype)shareInstance{
    static ZXDataStoreSQlite * s_instance_dj_singleton = nil ;
    if (s_instance_dj_singleton == nil) {
        s_instance_dj_singleton = [[ZXDataStoreSQlite alloc] init];
    }
    return (ZXDataStoreSQlite *)s_instance_dj_singleton;
}


+(void)openDb{
    if(db != nil) {
        return;
    }
    int result = sqlite3_open([DbPath UTF8String], &db);
    if (result == SQLITE_OK) {
        
    }else{
        ZXDataHandleLog(@"数据库打开失败");
    }
}
+(void)closeDb{
    if(db){
        sqlite3_close(db);
    }
}
+(BOOL)dropDb{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if([[NSFileManager defaultManager]fileExistsAtPath:DbPath]) {
        BOOL res = [fileManager removeItemAtPath:DbPath error:nil];
        if(res){
            db = nil;
        }
        return res;
    }
    return YES;
}

+(id)getDb{
    [self openDb];
    return (__bridge id)(db);
}

+(SqlResult *)executeSql:(NSString *)sql res:(BOOL)hasRes{
    [self openDb];
    SqlResult *res = [[SqlResult alloc]init];
    char *error = NULL;
    int result = -1;
    sqlite3_stmt *stmt;
    if(!hasRes){
        result = sqlite3_exec(db, [sql UTF8String], nil, nil, &error);
        if (result == SQLITE_OK) {
            res.success = YES;
            sqlite3_free(error);
        }else{
            res.success = NO;
            res.error = error;
            ZXDataHandleLog(@"executeSqlError:%@ sql:%@",[NSString stringWithUTF8String:error],sql);
            sqlite3_free(error);
        }
    }else{
        result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt,NULL);
        if (result == SQLITE_OK) {
            NSMutableArray *datasArr = [NSMutableArray array];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                int colCount = sqlite3_data_count(stmt);
                NSMutableDictionary *perDic = [NSMutableDictionary dictionary];
                for(int i = 0;i < colCount;i++){
                    int colType = sqlite3_column_type(stmt,i);
                    char *charColName = (char *)sqlite3_column_name(stmt, i);
                    NSString *colName = [NSString stringWithUTF8String:charColName];
                    
                    switch (colType) {
                        case SQLITE_INTEGER:{
                            int perRes = sqlite3_column_int(stmt, i);
                            [perDic zx_dicSaftySetValue:[NSNumber numberWithInt:perRes] forKey:colName];
                            break;
                        }
                        case SQLITE_FLOAT:{
                            double perRes = sqlite3_column_double(stmt,i);
                            [perDic zx_dicSaftySetValue:[NSNumber numberWithDouble:perRes] forKey:colName];
                            break;
                        }
                        case SQLITE_TEXT:{
                            char *charPerRes = (char *)sqlite3_column_text(stmt, i);
                            NSString *perRes = [NSString stringWithUTF8String:charPerRes];
                            [perDic zx_dicSaftySetValue:perRes forKey:colName];
                            break;
                        }
                        case SQLITE_BLOB:{
                            
                            break;
                        }
                        case SQLITE_NULL:{
                            
                            break;
                        }
                        default:
                            break;
                    }
                }
                [datasArr addObject:perDic];
            }
            res.success = YES;
            res.resData = datasArr;
        }else{
            res.success = NO;
            res.error = error;
            ZXDataHandleLog(@"executeSqlError,sql:%@",sql);
            sqlite3_free(error);
        }
        sqlite3_finalize(stmt);
    }
    return res;
}
+(SqlResult *)executeSqls:(NSArray *)sqls{
    SqlResult *res = [[SqlResult alloc]init];
    if(!sqls.count){
        return res;
    }
    char *resError = NULL;
    [self openDb];
    BOOL succ = YES;
    @try{
        char *error;
        if (sqlite3_exec(db, "BEGIN", NULL, NULL, &error) == SQLITE_OK){
            sqlite3_free(error);
            sqlite3_stmt *statement;
            for (int i = 0; i < sqls.count; i++){
                if (sqlite3_prepare_v2(db,[[sqls objectAtIndex:i] UTF8String], -1, &statement,NULL) == SQLITE_OK){
                    if (sqlite3_step(statement) != SQLITE_DONE) sqlite3_finalize(statement);
                }
            }
            if (sqlite3_exec(db, "COMMIT", NULL, NULL, &error) == SQLITE_OK){
                
            }else{
                ZXDataHandleLog(@"事务提交失败");
                succ = NO;
                resError = error;
            }
            sqlite3_free(error);
        }
        else {
            sqlite3_free(error);
        }
    }
    @catch(NSException *e)
    {
        char *error;
        if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &error) == SQLITE_OK){
            ZXDataHandleLog(@"事务回滚成功");
        }else{
            ZXDataHandleLog(@"事务回滚失败");
        }
        sqlite3_free(error);
    }
    @finally{
        res.success = succ;
        res.error = resError;
    }
    return res;
}
+(NSString *)getSqlValueTypeWithProType:(NSString *)proType{
    NSString *subT = [proType matchStrWithPre:@"T" sub:@","];
    if(!subT.length){
        return nil;
    }else{
        if([subT hasPrefix:@"@"]){
            if([subT isEqualToString:@"@\"NSString\""]){
                subT = @"NSString";
            }else if([subT isEqualToString:@"@\"NSNumber\""]){
                subT = @"NSNumber";
            }
        }
    }
    if(subT.length == 1){
        subT = [subT lowercaseString];
    }
    NSDictionary *sqlValueMapper = [self sqlValueMapper];
    NSString *sqlValueType = [sqlValueMapper zx_dicSafetyReadForKey:subT];
    
    return sqlValueType;
}
+(NSDictionary *)sqlValueMapper{
    return @{@"i":@"integer",@"s":@"INTEGER",@"f":@"REAL",@"d":@"REAL",@"l":@"INTEGER",@"q":@"INTEGER",@"c":@"INTEGER",@"b":@"INTEGER",@"NSString":@"TEXT",@"NSNumber":@"REAL"};
}

+(NSArray *)sqlSymbolArr{
    return @[@">",@">=",@"<",@"<=",@"=",@"==",@"!=",@"<>",@"!<",@"!>"];
}

-(NSMutableArray *)allJudgedExistTb{
    if(_allJudgedExistTb){
        _allJudgedExistTb = [NSMutableArray array];
    }
    return _allJudgedExistTb;
}
-(NSMutableArray *)allJudgedUpdateTb{
    if(_allJudgedUpdateTb){
        _allJudgedUpdateTb = [NSMutableArray array];
    }
    return _allJudgedUpdateTb;
}
@end
