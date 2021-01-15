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
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":ZXFullUA, @"User-Agent":oldUa}];
}
#pragma mark 创建ipa下载文件夹
-(void)creatIpaDownloadedPath{
    [ZXFileManage creatDirWithPathComponent:ZXIpaDownloadedPath];
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
    [ self comeToBackgroundMode];
}

-(void)comeToBackgroundMode{
    UIApplication*  app = [UIApplication sharedApplication];
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
}

@end
