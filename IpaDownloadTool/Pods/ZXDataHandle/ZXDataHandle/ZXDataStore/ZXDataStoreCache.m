//
//  ZXDataStoreCache.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "ZXDataStoreCache.h"
#import "NSObject+ZXToDic.h"
#import "ZXDataHandleLog.h"
#import "ZXDataType.h"
#define zx_accountKey @"zx_accountKey"
typedef enum {
    PathAttrFile = 0x00,    // 路径对应的类型为文件
    PathAttrDir = 0x01,    // 路径对应的类型为文件夹
    PathAttrNotExist = 0x02,   // 路径不存在
}PathAttr;

@implementation ZXDataStoreCache
#pragma mark - NSUserDefaults
#pragma mark 将数据(对象)写入用户偏好
+(void)saveObj:(id)obj forKey:(NSString *)key{
    if(![ZXDataType isFoudationClass:obj]){
        obj= [obj zx_toDic];
    }
    if([obj isKindOfClass:[NSArray class]]){
        NSMutableArray *resArr = [NSMutableArray array];
        for (id subObj in obj) {
            if(![ZXDataType isFoudationClass:subObj]){
                [resArr addObject:[subObj zx_toDic]];
            }else{
                [resArr addObject:subObj];
            }
        }
        obj = [resArr mutableCopy];
    }
    [[NSUserDefaults standardUserDefaults]setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark 从用户偏好设置中读取数据(对象)
+(id)readObjForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults]objectForKey:key];
}

#pragma mark 将数据(NSUInteger)写入用户偏好
+(void)saveInteger:(NSUInteger)integerValue forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults]setInteger:integerValue forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark 从用户偏好设置中读取数据(NSUInteger)
+(NSUInteger)readIntegerForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults]integerForKey:key];
}

#pragma mark 将数据(BOOL)写入用户偏好
+(void)saveBool:(BOOL)boolValue forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults]setBool:(BOOL)boolValue forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark 从用户偏好设置中读取数据(BOOL)
+(BOOL)readBoolForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults]boolForKey:key];
}

#pragma mark 将数据(Float)写入用户偏好
+(void)saveFloat:(float)floatValue forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults]setFloat:floatValue forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark 从用户偏好设置中读取数据(Float)
+(float)readFloatForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults]floatForKey:key];
}

#pragma mark 将数据(Double)写入用户偏好
+(void)saveDouble:(double)doubleValue forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults]setDouble:doubleValue forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark 从用户偏好设置中读取数据(Double)
+(double)readDoubleForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults]doubleForKey:key];
}

#pragma mark 将数据(NSURL)写入用户偏好
+(void)saveUrl:(NSURL *)urlValue forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults]setURL:urlValue forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark 从用户偏好设置中读取数据(NSURL)
+(NSURL *)readUrlForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults]URLForKey:key];
}


#pragma mark 归档存储数据
+(void)arcObj:(id)obj pathComponent:(NSString *)pathComponent{
    NSString *absPath = [ZXDocPath stringByAppendingPathComponent:pathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(!obj){
        PathAttr pathAttr = [self getPathAttrWithPathComponent:pathComponent];
        if(pathAttr == PathAttrNotExist){
            ZXDataHandleLog(@"删除失败！路径:%@不存在！",pathComponent);
        }else{
            NSError *error;
            BOOL res = [fileManager removeItemAtPath:absPath error:&error];
            if(!res){
                ZXDataHandleLog(@"删除失败！路径:%@;原因:%@",pathComponent,error.description);
            }
        }
        return;
    }
    if(![ZXDataType isFoudationClass:obj] && obj){
        if(!([obj respondsToSelector:@selector(encodeWithCoder:)] && [obj respondsToSelector:@selector(initWithCoder:)])){
            ZXDataHandleLog(@"归档失败！对象%@未实现encodeWithCoder:或initWithCoder:",obj);
            return;
        }
    }
    if([pathComponent containsString:@"/"]){
        NSString *dirPath = [pathComponent stringByDeletingLastPathComponent];
        PathAttr pathAttr = [self getPathAttrWithPathComponent:dirPath];
        if(pathAttr == PathAttrNotExist){
            [self creatDirWithPathComponent:[ZXDocPath stringByAppendingPathComponent:dirPath]];
        }
    }else if([self getPathAttrWithPathComponent:pathComponent] == PathAttrDir){
        ZXDataHandleLog(@"归档失败！路径:%@已存在同名文件夹！",pathComponent);
        return;
    }
    BOOL res = [NSKeyedArchiver archiveRootObject:obj toFile:absPath];
    if(!res){
        ZXDataHandleLog(@"归档失败！路径:%@",pathComponent);
    }
}

#pragma mark 读档读取数据
+(id)unArcObjPathComponent:(NSString *)pathComponent{
    PathAttr pathAttr = [self getPathAttrWithPathComponent:pathComponent];
    if(pathAttr == PathAttrNotExist){
        ZXDataHandleLog(@"数据读取失败！路径:%@不存在！",pathComponent);
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[ZXDocPath stringByAppendingPathComponent:pathComponent]];
}
#pragma mark - User
#pragma mark 设置用户数据存储的account，若使用了saveUserObj:pathComponent:则此项必须设置，否则saveUserObj:pathComponent:与arcObj:pathComponent:等同
+(void)saveUserAccount:(NSString *)userAccount{
    [self saveObj:userAccount forKey:zx_accountKey];
}
#pragma mark 读取用户数据存储的account
+(NSString *)readUserAccount{
    return [self readObjForKey:zx_accountKey];
}
#pragma mark 根据用户将对象存储至沙盒，请注意务必配置saveUserAccount:,否则saveUserObj:pathComponent:与arcObj:pathComponent:等同
+(void)saveUserObj:(id)obj pathComponent:(NSString *)pathComponent{
    NSString *accountKey = [self readObjForKey:zx_accountKey];
    if(accountKey){
        pathComponent = [accountKey stringByAppendingPathComponent:pathComponent];
    }
    [self arcObj:obj pathComponent:pathComponent];
}
#pragma mark 根据用户从沙盒中读取数据，请注意务必配置saveUserAccount:,否则readUserObjPathComponent:与unArcObjPathComponent:等同
+(instancetype)readUserObjPathComponent:(NSString *)pathComponent{
    NSString *accountKey = [self readObjForKey:zx_accountKey];
    if(accountKey){
        pathComponent = [accountKey stringByAppendingPathComponent:pathComponent];
    }
    return [self unArcObjPathComponent:pathComponent];
}
#pragma mark - Tool
#pragma mark 清除沙盒Doc缓存
+(void)cleanCacheData{
    NSArray *subPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ZXDocPath error:nil];
    NSString *filePath;
    NSError *error;
    for (NSString *subPath in subPathArr){
        filePath = [ZXDocPath stringByAppendingPathComponent:subPath];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            ZXDataHandleLog(@"清除失败！路径:%@",filePath);
        }
    }
}
#pragma mark 清除NSUserDefault数据
+(void)cleanUserDefault{
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
}
#pragma mark - Private
#pragma mark 根据路径创建文件夹
+(void)creatDirWithPathComponent:(NSString *)pathComponent{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    PathAttr pathAttr = [self getPathAttrWithPathComponent:pathComponent];
    
    if(pathAttr == PathAttrNotExist){
        NSError *error;
        NSDictionary *attrDic =[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate];
        BOOL res = [fileManager createDirectoryAtPath:pathComponent withIntermediateDirectories:YES attributes:attrDic error:&error];
        if(!res){
            ZXDataHandleLog(@"归档失败！文件夹创建失败！路径:%@;原因:%@",pathComponent,error.description);
        }
    }
}

#pragma mark 判断路径对应类型
+(PathAttr)getPathAttrWithPathComponent:(NSString *)pathComponent{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL pathExist = [fileManager fileExistsAtPath:[ZXDocPath stringByAppendingPathComponent:pathComponent] isDirectory:&isDir];
    if(!pathExist){
        return PathAttrNotExist;
    }
    if(isDir){
        return PathAttrDir;
    }
    return PathAttrFile;
    
}
@end
