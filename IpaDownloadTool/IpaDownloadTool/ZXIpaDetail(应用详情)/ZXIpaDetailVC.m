//
//  ZXIpaDetailVC.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/IpaDownloadTool

#import "ZXIpaDetailVC.h"
#import "ZXIpaDetailCell.h"
#import "ZXIpaDetailModel.h"

#import "ZXLocalIpaVC.h"
@interface ZXIpaDetailVC ()
@property (weak, nonatomic) IBOutlet ZXTableView *tableView;

@end

@implementation ZXIpaDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

#pragma mark - 初始化视图
-(void)initUI{
    self.title = @"应用详情";
    __weak __typeof(self) weakSelf = self;
    self.tableView.zx_setCellClassAtIndexPath = ^Class(NSIndexPath *indexPath) {
        return [ZXIpaDetailCell class];
    };
    self.tableView.zx_didSelectedAtIndexPath = ^(NSIndexPath *indexPath, ZXIpaDetailModel *model, id cell) {
        [weakSelf handelSelActionWithModel:model];
    };
    self.tableView.zxDatas = [self getTbData];
}

#pragma mark - Private
#pragma mark 设置tableView数据
-(NSMutableArray *)getTbData{
    ZXIpaDetailModel *titleModel = [[ZXIpaDetailModel alloc]init];
    titleModel.title = @"应用名称";
    titleModel.detail = self.ipaModel.title;
    
    ZXIpaDetailModel *versionModel = [[ZXIpaDetailModel alloc]init];
    versionModel.title = @"版本号";
    versionModel.detail = self.ipaModel.version;
    
    ZXIpaDetailModel *bundleIdModel = [[ZXIpaDetailModel alloc]init];
    bundleIdModel.title = @"BundleId";
    bundleIdModel.detail = self.ipaModel.bundleId;
    
    ZXIpaDetailModel *downloadModel = [[ZXIpaDetailModel alloc]init];
    downloadModel.title = @"下载地址";
    downloadModel.detail = self.ipaModel.downloadUrl;
    
    ZXIpaDetailModel *fromModel = [[ZXIpaDetailModel alloc]init];
    fromModel.title = @"来源地址";
    fromModel.detail = self.ipaModel.fromPageUrl;
    
    ZXIpaDetailModel *timeModel = [[ZXIpaDetailModel alloc]init];
    timeModel.title = @"创建时间";
    timeModel.detail = self.ipaModel.time;
    ZXIpaDetailModel *fileModel = [[ZXIpaDetailModel alloc]init];
    if([ZXFileManage isExistWithPath:self.ipaModel.localPath]){
        fileModel.title = @"IPA已下载";
        fileModel.detail = @"点击分享/重新下载";
    }else{
        fileModel.title = @"IPA未下载";
        fileModel.detail = @"点击下载";
    }
    
    return [@[titleModel,versionModel,bundleIdModel,downloadModel,fromModel,timeModel,fileModel]mutableCopy];
    
}

#pragma mark 处理cell点击事件
-(void)handelSelActionWithModel:(ZXIpaDetailModel *)model{
    if([model.title hasPrefix:@"IPA"]){
        if([ZXFileManage isExistWithPath:self.ipaModel.localPath]){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"操作选择" message:@"请选择您要进行的操作" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"分享文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[ZXFileManage shareInstance] shareFileWithPath:self.ipaModel.localPath];
            }];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"重新下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                ZXLocalIpaVC *VC = [[ZXLocalIpaVC alloc]init];
                VC.ipaModel = self.ipaModel;
                [self.navigationController pushViewController:VC animated:YES];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addThemeAction:shareAction];
            [alertController addThemeAction:confirmAction];
            [alertController addThemeAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            ZXLocalIpaVC *VC = [[ZXLocalIpaVC alloc]init];
            VC.ipaModel = self.ipaModel;
            [self.navigationController pushViewController:VC animated:YES];
        }
        return;
    }
    if([model.title hasPrefix:@"应用名称"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改应用名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *inputTf = alertController.textFields[0];
            [inputTf becomeFirstResponder];
            NSString *title = inputTf.text;
            self.ipaModel.title = title;
            [self.ipaModel zx_dbUpdateWhere:[NSString stringWithFormat:@"sign='%@'",self.ipaModel.sign]];
            self.tableView.zxDatas = [self getTbData];
        }];
        [alertController addThemeAction:cancelAction];
        [alertController addThemeAction:confirmAction];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入新的应用名称";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.text = model.detail;
        }];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = model.detail;
    if([model.title isEqualToString:@"下载地址"] && [model.detail containsString:@"pgyer.com"]){
        [ALToastView showToastWithText:@"已复制至剪切板，若无法下载请使用Chrome再次尝试"];
    }else{
        [ALToastView showToastWithText:@"已复制至剪切板"];
    }
}
#pragma mark - 生命周期
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.tableView){
        self.tableView.zxDatas = [self getTbData];
    }
}
@end
