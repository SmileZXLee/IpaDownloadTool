//
//  ZXFileManage.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXFileManage.h"
#import "ZXDataHandle.h"

#define ExtentDocPath(pathComponent) [NSString stringWithFormat:@"%@/%@",ZXDocPath,pathComponent]
@interface ZXFileManage()
@property (strong, nonatomic) UIDocumentInteractionController *documentController;
@end
@implementation ZXFileManage
+(instancetype)shareInstance{
    static ZXFileManage * s_instance_dj_singleton = nil ;
    if (s_instance_dj_singleton == nil) {
        s_instance_dj_singleton = [[ZXFileManage alloc] init];
    }
    return (ZXFileManage *)s_instance_dj_singleton;
}

+(PathAttr)getPathAttrWithPath:(NSString *)path{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL pathExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!pathExist){
        return PathAttrNotExist;
    }
    if(isDir){
        return PathAttrDir;
    }
    return PathAttrFile;
    
}
+(PathAttr)getPathAttrWithPathComponent:(NSString *)pathComponent{
    return [self getPathAttrWithPath:ExtentDocPath(pathComponent)];
    
}

+(BOOL)isExistWithPath:(NSString *)path{
    return [self getPathAttrWithPath:path] != PathAttrNotExist;
}
+(BOOL)isExistWithPathComponent:(NSString *)pathComponent{
    return [self getPathAttrWithPathComponent:pathComponent] != PathAttrNotExist;
}

+(void)delFileWithPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    PathAttr pathAttr = [self getPathAttrWithPath:path];
    if(pathAttr == PathAttrNotExist){
        
    }else{
        NSError *error;
        [fileManager removeItemAtPath:path error:&error];
    }
}
+(void)delFileWithPathComponent:(NSString *)pathComponent{
    [self delFileWithPath:ExtentDocPath(pathComponent)];
}

+(void)creatDirWithPath:(NSString *)path{
    NSDictionary *attrDic =[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate];
    if(![self isExistWithPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attrDic error:nil];
    }
}
+(void)creatDirWithPathComponent:(NSString *)pathComponent{
    [self creatDirWithPath:ExtentDocPath(pathComponent)];
}
+(long long)getFileSizeWithPath:(NSString *)path{
    if([self isExistWithPath:path]){
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil]fileSize];
    }
    return 0;
}

+(long long)getFileSizeWithPathComponent:(NSString *)pathComponent{
    return [self getFileSizeWithPath:ExtentDocPath(pathComponent)];
}
-(void)shareFileWithPath:(NSString *)path{
    NSLog(@"shareFileWithPath--%@",path);
    if(![ZXFileManage isExistWithPath:path]){
        [ALToastView showToastWithText:@"文件不存在！"];
        return;
    }
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    documentController.UTI = @"com.adobe.pdf";
    [documentController presentOpenInMenuFromRect:CGRectZero inView:[UIApplication sharedApplication].keyWindow.rootViewController.view animated:YES];
    self.documentController = documentController;
}
@end
