//
//  ZXFileDownload.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXFileDownload.h"
@interface ZXFileDownload()<NSURLSessionDownloadDelegate>
@property(nonatomic,copy) kDownloadEventHandler _result;
@property(nonatomic,assign) int64_t totalBytesWritten;
@property(nonatomic,assign) int64_t totalBytesExpectedToWrite;
@end
@implementation ZXFileDownload

-(NSURLSession *)downLoadWithUrlStr:(NSString *)urlStr callBack:(kDownloadEventHandler)_result{
    self._result = _result;
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *identifier = [NSString stringWithFormat:@"%@.BackgroundSession", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    config.timeoutIntervalForRequest = 10;
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    config.HTTPAdditionalHeaders = @{@"User-Agent": ZXUA};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
    [task resume];
    
    return session;
}


#pragma mark - NSURLSessionDataDelegate
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if(totalBytesWritten > 1024){
        self.totalBytesWritten = totalBytesWritten;
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    }
    self._result(YES,self.totalBytesWritten,self.totalBytesExpectedToWrite,nil);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
  self._result(YES,self.totalBytesWritten,self.totalBytesExpectedToWrite,location.absoluteString);
    [session invalidateAndCancel];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error){
        self._result(NO,0,0,nil);
        [session invalidateAndCancel];
    }
}
@end
