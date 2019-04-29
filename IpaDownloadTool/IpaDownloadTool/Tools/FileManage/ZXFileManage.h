//
//  ZXFileManage.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum {
    PathAttrFile = 0x00,    // 路径对应的类型为文件
    PathAttrDir = 0x01,    // 路径对应的类型为文件夹
    PathAttrNotExist = 0x02,   // 路径不存在
}PathAttr;
@interface ZXFileManage : NSObject
+(instancetype)shareInstance;
///获取对应路径的文件属性
+(PathAttr)getPathAttrWithPath:(NSString *)path;
///获取对应路径的文件属性
+(PathAttr)getPathAttrWithPathComponent:(NSString *)pathComponent;
///判断对应路径文件是否存在
+(BOOL)isExistWithPath:(NSString *)path;
///判断对应路径文件是否存在
+(BOOL)isExistWithPathComponent:(NSString *)pathComponent;
///将对应路径的文件删除
+(void)delFileWithPath:(NSString *)path;
///将对应路径的文件删除
+(void)delFileWithPathComponent:(NSString *)pathComponent;
///根据路径创建文件夹
+(void)creatDirWithPath:(NSString *)path;
///根据路径创建文件夹
+(void)creatDirWithPathComponent:(NSString *)pathComponent;
///根据路径获取文件大小
+(long long)getFileSizeWithPath:(NSString *)path;
///根据路径获取文件大小
+(long long)getFileSizeWithPathComponent:(NSString *)pathComponent;
///分享对应路径的文件
-(void)shareFileWithPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
