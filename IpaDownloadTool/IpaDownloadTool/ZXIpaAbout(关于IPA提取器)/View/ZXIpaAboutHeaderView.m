//
//  ZXIpaAboutHeaderView.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2022/10/16.
//  Copyright © 2022 李兆祥. All rights reserved.
//

#import "ZXIpaAboutHeaderView.h"
@interface ZXIpaAboutHeaderView()
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end
@implementation ZXIpaAboutHeaderView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.versionLabel.textColor = [UIColor grayColor];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
    self.appNameLabel.text = appName;
    self.versionLabel.text = [NSString stringWithFormat:@"v%@(%@)",appVersion,appBuild];
    
    self.versionLabel.userInteractionEnabled = YES; // 允许交互
    UITapGestureRecognizer *versionLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enableDeveloperMode)];
    versionLabelTapGesture.numberOfTapsRequired = 5;
    [self.versionLabel addGestureRecognizer:versionLabelTapGesture];
}

#pragma mark 打开开发者模式
- (void)enableDeveloperMode {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"developerMode"] == nil) {
        [ALToastView showToastWithText:@"开发者模式已开启"];
        [[NSUserDefaults standardUserDefaults]setObject:@1 forKey:@"developerMode"];
    } else {
        [ALToastView showToastWithText:@"开发者模式已关闭"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"developerMode"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
    [[NSNotificationCenter defaultCenter]postNotificationName:ZXDeveloperModeUpdateNotification object:nil];
}


@end
