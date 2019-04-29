//
//  ZXLocalIpaDownloadModel.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXLocalIpaDownloadModel : NSObject
///应用名称
@property (copy, nonatomic) NSString *title;
///下载链接
@property (copy, nonatomic) NSString *downloadUrl;
///总字节数
@property (assign, nonatomic) int64_t totalBytesExpectedToWrite;
///已下载字节数
@property (assign, nonatomic) int64_t totalBytesWritten;
///是否下载结束
@property (assign, nonatomic, getter = isFinish) BOOL finish;
///唯一标识
@property (copy, nonatomic) NSString *sign;
///本地存储地址
@property (copy, nonatomic) NSString *localPath;
@end

NS_ASSUME_NONNULL_END
