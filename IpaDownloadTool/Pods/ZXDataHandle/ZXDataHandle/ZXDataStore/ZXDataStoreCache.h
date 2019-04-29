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
///#pragma mark 归档存储数据
+(void)arcObj:(id)obj pathComponent:(NSString *)pathComponent;
///读档读取数据
+(id)unArcObjPathComponent:(NSString *)pathComponent;
///清除沙盒数据
+(void)cleanCacheData;
///清除NSUserDefalut数据
+(void)cleanUserDefault;

@end

NS_ASSUME_NONNULL_END
