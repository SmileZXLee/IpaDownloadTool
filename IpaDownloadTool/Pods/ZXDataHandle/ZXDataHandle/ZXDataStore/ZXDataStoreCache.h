//
//  ZXDataStoreCache.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXDataStoreCache : NSObject
///将数据写入用户偏好
+(void)saveObj:(id)obj forKey:(NSString *)key;
///从用户偏好设置中读取数据
+(id)readObjForKey:(NSString *)key;
///将数据(NSUInteger)写入用户偏好
+(void)saveInteger:(NSUInteger)integerValue forKey:(NSString *)key;
///从用户偏好设置中读取数据(NSUInteger)
+(NSUInteger)readIntegerForKey:(NSString *)key;
///将数据(BOOL)写入用户偏好
+(void)saveBool:(BOOL)boolValue forKey:(NSString *)key;
///从用户偏好设置中读取数据(BOOL)
+(BOOL)readBoolForKey:(NSString *)key;
///将数据(Float)写入用户偏好
+(void)saveFloat:(float)floatValue forKey:(NSString *)key;
///从用户偏好设置中读取数据(Float)
+(float)readFloatForKey:(NSString *)key;
///将数据(Double)写入用户偏好
+(void)saveDouble:(double)doubleValue forKey:(NSString *)key;
///从用户偏好设置中读取数据(Double)
+(double)readDoubleForKey:(NSString *)key;
///将数据(NSURL)写入用户偏好
+(void)saveUrl:(NSURL *)urlValue forKey:(NSString *)key;
///从用户偏好设置中读取数据(NSURL)
+(NSURL *)readUrlForKey:(NSString *)key;
///#pragma mark 归档存储数据
+(void)arcObj:(id)obj pathComponent:(NSString *)pathComponent;
///读档读取数据
+(id)unArcObjPathComponent:(NSString *)pathComponent;
///设置用户数据存储的account，若使用了saveUserObj:pathComponent:则此项必须设置，否则saveUserObj:pathComponent:与arcObj:pathComponent:等同
+(void)saveUserAccount:(NSString *)userAccount;
///读取用户数据存储的account
+(NSString *)readUserAccount;
///根据用户将对象存储至沙盒，请注意务必配置saveUserAccount:,否则saveUserObj:pathComponent:与arcObj:pathComponent:等同
+(void)saveUserObj:(id)obj pathComponent:(NSString *)pathComponent;
///根据用户从沙盒中读取数据，请注意务必配置saveUserAccount:,否则readUserObjPathComponent:与unArcObjPathComponent:等同
+(instancetype)readUserObjPathComponent:(NSString *)pathComponent;
///清除沙盒数据
+(void)cleanCacheData;
///清除NSUserDefalut数据
+(void)cleanUserDefault;

@end

NS_ASSUME_NONNULL_END
