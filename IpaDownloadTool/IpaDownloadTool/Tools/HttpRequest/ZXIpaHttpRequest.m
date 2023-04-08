//
//  ZXIpaHttpRequest.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXIpaHttpRequest.h"

@implementation ZXIpaHttpRequest
+(void)getUrl:(NSString *)urlStr callBack:(kGetDataEventHandler)_result{
    [self baseUrl:urlStr callBack:_result];
}
+(void)getReq:(NSURLRequest *)req callBack:(kGetDataEventHandler)_result{
    [self baseReq:req callBack:_result];
}
#pragma mark - private
+(void)baseUrl:(NSString *)urlStr callBack:(kGetDataEventHandler)_result{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *mr = [NSMutableURLRequest requestWithURL:url];
    mr.HTTPMethod = @"GET";
    mr.timeoutInterval = 10;
    [self baseReq:mr callBack:_result];
}

+(void)baseReq:(NSURLRequest *)req callBack:(kGetDataEventHandler)_result{
    NSMutableURLRequest *mReq = [req mutableCopy];
    mReq.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [mReq addValue:ZXUA forHTTPHeaderField:@"User-Agent"];
    [NSURLConnection sendAsynchronousRequest:mReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            _result(NO,connectionError);
        }else{
            NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _result(YES,dataStr);
        }
    }];
}
+(void)downLoadWithUrlStr:(NSString *)urlStr path:(NSString *)path callBack:(kGetDataEventHandler)_result{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 10;
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    config.HTTPAdditionalHeaders = @{@"User-Agent":ZXUA};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *fileErr;
        NSString *filePath = @"";
        if(location){
            NSString *locationPath = location.absoluteString;
            locationPath = [locationPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            filePath = [NSString stringWithFormat:@"%@/%@",ZXDocPath,path];
            [ZXFileManage delFileWithPathComponent:path];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:&fileErr];
        }
        if(!error && !fileErr){
            _result(YES,filePath);
        }else{
            if(error){
                _result(NO,error);
            }else{
                _result(NO,fileErr);
            }
        }
        
    }];
    [task resume];
}
@end
