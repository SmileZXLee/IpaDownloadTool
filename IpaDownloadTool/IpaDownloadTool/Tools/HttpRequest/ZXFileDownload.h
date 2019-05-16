//
//  ZXFileDownload.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^kDownloadEventHandler) (BOOL result, int64_t totalBytesWritten,int64_t totalBytesExpectedToWrite,NSString *path);
@interface ZXFileDownload : NSObject
///大文件下载
-(NSURLSession *)downLoadWithUrlStr:(NSString *)urlStr callBack:(kDownloadEventHandler)_result;
@end

NS_ASSUME_NONNULL_END
