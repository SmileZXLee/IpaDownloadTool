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
}


@end
