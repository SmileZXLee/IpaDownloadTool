//
//  ZXMPRegularVC.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2023/4/7.
//  Copyright © 2023 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/IpaDownloadTool

#import "ZXMPRegularVC.h"
#import "ZXIpaHttpRequest.h"

@interface ZXMPRegularVC ()
@property (weak, nonatomic) IBOutlet UITextView *regularTv;

@end

@implementation ZXMPRegularVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
}

- (void)initUI {
    self.title = @"描述文件URL匹配规则";
    
    UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc]initWithTitle:@"重载" style:UIBarButtonItemStyleDone target:self action:@selector(reloadAction)];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction)];
    
    self.navigationItem.rightBarButtonItems = @[saveItem, reloadItem];
    
}

- (void)initData {
    NSArray *mobileprovisionRegulaArr = [ZXDataStoreCache readObjForKey:ZXMobileprovisionRegularCacheKey];
    if (mobileprovisionRegulaArr != nil && mobileprovisionRegulaArr.count) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;

        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[mobileprovisionRegulaArr componentsJoinedByString:@"\n"] attributes:@{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: [UIFont systemFontOfSize:14]}];

        UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        textView.attributedText = attributedString;
        self.regularTv.attributedText = attributedString;
    }
}

- (void)saveAction {
    NSMutableArray *mobileprovisionRegulaArr = [[self.regularTv.attributedText.string componentsSeparatedByString:@"\n"] mutableCopy];
    for (NSString *string in mobileprovisionRegulaArr) {
        if ([string isEqualToString:@""]) {
            [mobileprovisionRegulaArr removeObjectIdenticalTo:string];
        }
    }
    [ZXDataStoreCache saveObj:mobileprovisionRegulaArr forKey:ZXMobileprovisionRegularCacheKey];
    [ALToastView showToastWithText:@"匹配规则保存成功"];
    [[NSNotificationCenter defaultCenter]postNotificationName:ZXMobileprovisionRegularUpdateNotification object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)reloadAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"重载配置将从服务端重新加载最新配置，本地已添加/修改的描述文件URL匹配规则将被覆盖且无法恢复，是否确认重载配置？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"重载配置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [ZXIpaHttpRequest getUrl:ZXMobileprovisionUrlRegularGetPath callBack:^(BOOL result, id  _Nonnull data) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (result) {
                NSDictionary *resultDic = [data zx_toDic];
                NSArray *mobileprovisionRegulaArr = resultDic[@"matches"];
                [ZXDataStoreCache saveObj:mobileprovisionRegulaArr forKey:ZXMobileprovisionRegularCacheKey];
                [self initData];
                [ALToastView showToastWithText:@"配置文件重载成功"];
                [[NSNotificationCenter defaultCenter]postNotificationName:ZXMobileprovisionRegularUpdateNotification object:nil];
            } else {
                [ALToastView showToastWithText:@"配置文件下载失败"];
            }
        }];
    }];
    [alertController addThemeAction:cancelAction];
    [alertController addThemeAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
