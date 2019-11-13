//
//  ZXFileDownload.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXFileDownload.h"
@interface ZXFileDownload()<NSURLSessionDownloadDelegate,NSURLConnectionDataDelegate>
@property(nonatomic,copy) kDownloadEventHandler _result;
@property(nonatomic,assign) int64_t totalBytesWritten;
@property(nonatomic,assign) int64_t totalBytesExpectedToWrite;
@property (nonatomic, strong) NSFileHandle *handle;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) int64_t totalLength;
@property (nonatomic, assign) int64_t currLength;
@end
@implementation ZXFileDownload
-(NSURLConnection *)downLoadWithUrlStrByURLConnection:(NSString *)urlStr filePath:(NSString *)filePath callBack:(kDownloadEventHandler)_result{
    self._result = _result;
    self.filePath = filePath;
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *rquest = [NSURLRequest requestWithURL:url];
    return [NSURLConnection connectionWithRequest:rquest delegate:self];
}
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
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self._result(NO,0,0,nil);
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpRespone = (NSHTTPURLResponse *)response;
    self.totalLength = httpRespone.expectedContentLength;
    if(self.totalLength > 1024){
        [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
        self.handle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.handle seekToEndOfFile];
    [self.handle writeData:data];
    self.currLength += data.length;
    self._result(YES,self.currLength,self.totalLength,nil);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self.handle closeFile];
    self.handle = nil;
    self.currLength = 0;
    self.totalLength = 0;
    self._result(YES,self.currLength,self.totalLength,nil);
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
