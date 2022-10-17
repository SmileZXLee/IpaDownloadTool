//
//  ZXIpaAboutVC.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2022/10/16.
//  Copyright © 2022 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/IpaDownloadTool

#import "ZXIpaAboutVC.h"
#import "ZXTableView.h"
#import "ZXIpaAboutHeaderView.h"
#import "ZXIpaAboutCell.h"

#import "ZXIpaModel.h"
#import "ZXIpaUrlHisModel.h"
@interface ZXIpaAboutVC ()
@property (weak, nonatomic) IBOutlet ZXTableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *copyrightBtn;
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
    [self.copyrightBtn setTintColor:MainColor];
    self.copyrightBtn.userInteractionEnabled = NO;
    self.copyrightBtn.titleLabel.font = [UIFont systemFontOfSize: 11.0];
    [self.copyrightBtn setTitle:@"Copyright © 2019-2022 IPA提取器. All rights reserved." forState:UIControlStateNormal];
    
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
        return 190;
    };
    self.tableView.zx_didSelectedAtIndexPath = ^(NSIndexPath *indexPath, NSString *title, id cell) {
        if([title isEqualToString:@"用户协议&使用说明"]){
            [weakSelf handleInstructionsClick];
        }else if([title isEqualToString:@"开源地址"]){
            [weakSelf handleOpenSourceAddressClick];
        }else if([title isEqualToString:@"数据导出或导入"]){
            [weakSelf handleDataExportAndImportClick];
        }
    };
    self.tableView.zxDatas = [@[@"数据导出或导入",@"用户协议&使用说明",@"开源地址"] mutableCopy];
}

#pragma mark 处理点击使用说明
-(void)handleInstructionsClick{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"用户协议&使用说明" message:ZXUserAgreement preferredStyle:UIAlertControllerStyleAlert];
    UILabel *messageLabel = [alertController.view valueForKeyPath:@"_messageLabel"];
    if(messageLabel){
        messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:nil];
    [alertController addThemeAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 处理点击开源地址
-(void)handleOpenSourceAddressClick{
    NSString *urlStr = @"https://github.com/SmileZXLee/IpaDownloadTool";
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication]canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark 处理点击数据导出或导入
-(void)handleDataExportAndImportClick{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"数据导出或导入" message:@"此功能用于导出/导入“IPA提取历史”和“网址历史”中的数据，已下载中的文件无法导入或导出。导出后将保存在剪贴板中，请及时转存！" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *exportAction = [UIAlertAction actionWithTitle:@"数据导出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *allIpaHistoryDicArr = [[ZXIpaModel zx_dbQuaryAll] zx_toDic];
        NSMutableArray *finalAllIpaHistoryDicArr = [NSMutableArray array];
        if(allIpaHistoryDicArr){
            for(int i = 0;i < allIpaHistoryDicArr.count;i++){
                NSDictionary *dic = allIpaHistoryDicArr[i];
                NSMutableDictionary *muDic = [dic mutableCopy];
                [muDic removeObjectForKey:@"localPath"];
                [finalAllIpaHistoryDicArr addObject:muDic];
            }
        }
        NSMutableArray *finalAllWebHistoryDicArr = [[ZXIpaUrlHisModel zx_dbQuaryAll] zx_toDic];
        finalAllWebHistoryDicArr = finalAllWebHistoryDicArr ? finalAllWebHistoryDicArr : @[];
        NSDictionary *allDataDic = @{@"ipaHistory": finalAllIpaHistoryDicArr,@"webHistory": finalAllWebHistoryDicArr};
        if(!finalAllIpaHistoryDicArr.count && !finalAllWebHistoryDicArr.count){
            [ALToastView showToastWithText:@"无可导出的数据"];
            return;
        }
        UIAlertController *exportResultController = [UIAlertController alertControllerWithTitle:@"导出成功" message:[NSString stringWithFormat:@"成功导出%ld条IPA提取历史和%ld条网址历史，是否复制至剪贴板？",finalAllIpaHistoryDicArr.count,finalAllWebHistoryDicArr.count] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *exportAction = [UIAlertAction actionWithTitle:@"复制到剪贴板" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [allDataDic zx_toJsonStr];
            [ALToastView showToastWithText:@"已复制至剪贴板"];
        }];
        [exportResultController addThemeAction:cancelAction];
        [exportResultController addThemeAction:exportAction];
        [self presentViewController:exportResultController animated:YES completion:nil];
    }];
    UIAlertAction *importAction = [UIAlertAction actionWithTitle:@"数据导入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *importResultController = [UIAlertController alertControllerWithTitle:@"数据导入" message:@"请确保已将需要导入的数据复制至剪贴板，即将从剪贴板获取数据并导入，导入的数据将在旧数据基础上追加" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *exportAction = [UIAlertAction actionWithTitle:@"从剪贴板获取并导入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            NSString *importString = pasteboard.string;
            NSDictionary *importDic = [importString zx_toDic];
            if(!importDic){
                [ALToastView showToastWithText:@"解析剪贴板中的数据失败，导入失败！"];
                return;
            }
            NSArray *finalAllIpaHistoryDicArr = @[];
            NSArray *finalAllWebHistoryDicArr = @[];
            if([self checkIsArrayAndHasCount:importDic[@"ipaHistory"]]){
                finalAllIpaHistoryDicArr = [ZXIpaModel zx_modelWithObj:importDic[@"ipaHistory"]];
            }
            if([self checkIsArrayAndHasCount:importDic[@"webHistory"]]){
                finalAllWebHistoryDicArr = [ZXIpaUrlHisModel zx_modelWithObj:importDic[@"webHistory"]];
            }
            if(!finalAllIpaHistoryDicArr.count && !finalAllWebHistoryDicArr.count){
                [ALToastView showToastWithText:@"无可导入的数据"];
                return;
            }
            [finalAllIpaHistoryDicArr zx_dbSave];
            [finalAllWebHistoryDicArr zx_dbSave];
            [ALToastView showToastWithText:[NSString stringWithFormat:@"成功导入%ld条IPA提取历史和%ld条网址历史",finalAllIpaHistoryDicArr.count,finalAllWebHistoryDicArr.count]];
        }];
        [importResultController addThemeAction:cancelAction];
        [importResultController addThemeAction:exportAction];
        [self presentViewController:importResultController animated:YES completion:nil];
    }];
    [alertController addThemeAction:cancelAction];
    [alertController addThemeAction:exportAction];
    [alertController addThemeAction:importAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 判断对象是不是非空数组
-(BOOL)checkIsArrayAndHasCount:(id)obj{
    return obj && [obj isKindOfClass:[NSArray class]] && [obj count] > 0;
}

@end
