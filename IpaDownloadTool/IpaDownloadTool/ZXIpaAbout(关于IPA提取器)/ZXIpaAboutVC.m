//
//  ZXIpaAboutVC.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2022/10/16.
//  Copyright © 2022 李兆祥. All rights reserved.
//

#import "ZXIpaAboutVC.h"
#import "ZXTableView.h"
#import "ZXIpaAboutHeaderView.h"
#import "ZXIpaAboutCell.h"
#import "ZXIpaAboutModel.h"
@interface ZXIpaAboutVC ()
@property (weak, nonatomic) IBOutlet ZXTableView *tableView;

@end

@implementation ZXIpaAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

#pragma mark - 初始化视图
-(void)initUI{
    self.title = @"关于";
    self.view.backgroundColor = BgColor;
    self.tableView.backgroundColor = [UIColor clearColor];
    __weak __typeof(self) weakSelf = self;
    self.tableView.zx_setHeaderClassInSection = ^Class _Nonnull(NSInteger section) {
        return [ZXIpaAboutHeaderView class];
    };
    self.tableView.zx_setCellClassAtIndexPath = ^Class(NSIndexPath *indexPath) {
        return [ZXIpaAboutCell class];
    };
    self.tableView.zx_setCellHAtIndexPath = ^CGFloat(NSIndexPath *indexPath) {
        return 50;
    };
    self.tableView.zx_setHeaderHInSection = ^CGFloat(NSInteger section) {
        return 180;
    };
    self.tableView.zx_didSelectedAtIndexPath = ^(NSIndexPath *indexPath, NSString *title, id cell) {
        if([title isEqualToString:@"使用说明"]){
            
        }else if([title isEqualToString:@"开源地址"]){
            NSString *urlStr = @"https://github.com/SmileZXLee/IpaDownloadTool";
            NSURL *url = [NSURL URLWithString:urlStr];
            if([[UIApplication sharedApplication]canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    };
    self.tableView.zxDatas = [@[@"使用说明",@"开源地址"] mutableCopy];
}

@end
