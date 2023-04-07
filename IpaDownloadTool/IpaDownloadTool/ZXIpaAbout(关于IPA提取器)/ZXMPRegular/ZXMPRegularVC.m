//
//  ZXMPRegularVC.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2023/4/7.
//  Copyright © 2023 李兆祥. All rights reserved.
//

#import "ZXMPRegularVC.h"

@interface ZXMPRegularVC ()
@property (weak, nonatomic) IBOutlet UITextView *regularTv;

@end

@implementation ZXMPRegularVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.title = @"描述文件URL匹配规则";
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItems = @[saveItem];
    
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

-(void)saveAction{
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

@end
