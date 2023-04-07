//
//  ZXIpaHttpRequest.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^kGetDataEventHandler) (BOOL result, id data);
@interface ZXIpaHttpRequest : NSObject
///通用请求
+(void)baseReq:(NSURLRequest *)req callBack:(kGetDataEventHandler)_result;
///get请求url
+(void)getUrl:(NSString *)urlStr callBack:(kGetDataEventHandler)_result;
///get请求request
+(void)getReq:(NSURLRequest *)req callBack:(kGetDataEventHandler)_result;
///下载小文件
+(void)downLoadWithUrlStr:(NSString *)urlStr path:(NSString *)path callBack:(kGetDataEventHandler)_result;
@end

NS_ASSUME_NONNULL_END
