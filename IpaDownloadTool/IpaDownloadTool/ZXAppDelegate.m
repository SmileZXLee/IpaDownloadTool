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
    [self creatIpaDownloadedPath];
    return YES;
}
#pragma mark 设置全局外观
-(void)setAppearance{
    [[UIBarButtonItem appearance] setTintColor:MainColor];
}
#pragma mark 创建ipa下载文件夹
-(void)creatIpaDownloadedPath{
    [ZXFileManage creatDirWithPathComponent:ZXIpaDownloadedPath];
}
@end
