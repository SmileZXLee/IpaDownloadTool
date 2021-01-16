//
//  ZXAppdelegate.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/IpaDownloadTool

#import "ZXAppDelegate.h"
#import "ZXIpaGetVC.h"

@implementation ZXAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    ZXIpaGetVC *VC = [[ZXIpaGetVC alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
    window.rootViewController = nav;
    [window makeKeyAndVisible];
    self.window = window;
    [self setAppearance];
    [self setUserAgent];
    [self creatIpaDownloadedPath];
    [self handlePasteboardStr];
    return YES;
}
#pragma mark 设置全局外观
-(void)setAppearance{
    [[UIBarButtonItem appearance] setTintColor:MainColor];
}
#pragma mark 设置全局UserAgent
-(void)setUserAgent{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *oldUa = [NSString stringWithFormat:@"%@ %@/%@", userAgent, executableFile,version];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":ZXWebUA, @"User-Agent":oldUa}];
}
#pragma mark 创建ipa下载文件夹
-(void)creatIpaDownloadedPath{
    [ZXFileManage creatDirWithPathComponent:ZXIpaDownloadedPath];
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
    [ self comeToBackgroundMode];
}

-(void)comeToBackgroundMode{
    UIApplication *app = [UIApplication sharedApplication];
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self handlePasteboardStr];
}

#pragma mark 获取剪切板内容并判断是否弹出”粘贴并前往“
- (void)handlePasteboardStr{
    NSString *pasteboardStr = [UIPasteboard generalPasteboard].string;
    if([pasteboardStr hasPrefix:@"http"] || [pasteboardStr hasPrefix:@"https"]){
        NSString *oldPasteboardStr = [ZXDataStoreCache readObjForKey:ZXPasteboardStrKey];
        NSString *cacheUrlStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"cacheUrlStr"];
        if(!(oldPasteboardStr && [oldPasteboardStr isEqualToString:pasteboardStr]) && !(cacheUrlStr && [cacheUrlStr isEqualToString:pasteboardStr]) && ![pasteboardStr hasSuffix:@".ipa"]){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"检测到剪切板中的链接【%@】，是否粘贴并前往？",pasteboardStr] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"粘贴并前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[NSNotificationCenter defaultCenter]postNotificationName:ZXPasteboardStrLoadUrlNotification object:pasteboardStr];
            }];
            [alertController addThemeAction:cancelAction];
            [alertController addThemeAction:confirmAction];
            [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
            [ZXDataStoreCache saveObj:pasteboardStr forKey:ZXPasteboardStrKey];
        }
    }
}

@end
