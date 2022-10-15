//
//  ZXIpaUrlHisVC.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2021/1/16.
//  Copyright © 2021 李兆祥. All rights reserved.
//

#import "ZXIpaUrlHisVC.h"
#import "ZXIpaUrlHisCell.h"
#import "ZXIpaUrlHisModel.h"

@interface ZXIpaUrlHisVC ()
@property (weak, nonatomic) IBOutlet ZXTableView *tableView;
@end

@implementation ZXIpaUrlHisVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self setTbData];
}
#pragma mark - 初始化视图
-(void)initUI{
    self.title = @"网址历史记录";
    __weak __typeof(self) weakSelf = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(cleanAction)];
    
    self.tableView.zx_didSelectedAtIndexPath = ^(NSIndexPath *indexPath, ZXIpaUrlHisModel *model, id cell) {
        if(weakSelf.urlSelectedBlock){
            weakSelf.urlSelectedBlock(model.urlStr);
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    };
    self.tableView.zx_editActionsForRowAtIndexPath = ^NSArray<UITableViewRowAction *> *(NSIndexPath *indexPath) {
        UITableViewRowAction *delAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            ZXIpaUrlHisModel *delModel = weakSelf.tableView.zxDatas[indexPath.row];
            [ZXIpaUrlHisModel zx_dbDropWhere:[NSString stringWithFormat:@"urlStr='%@'",delModel.urlStr]];
            [weakSelf setTbData];
        }];
        UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑标题" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            ZXIpaUrlHisModel *editModel = weakSelf.tableView.zxDatas[indexPath.row];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改网站标题" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *inputTf = alertController.textFields[0];
                [inputTf becomeFirstResponder];
                NSString *title = inputTf.text;
                editModel.title = title;
                [editModel zx_dbUpdateWhere:[NSString stringWithFormat:@"urlStr='%@'",editModel.urlStr]];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
            [alertController addThemeAction:cancelAction];
            [alertController addThemeAction:confirmAction];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入新的网站标题";
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.text = editModel.title;
            }];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }];
        return @[delAction,editAction];
    };
}
#pragma mark - Actions
#pragma mark 点击清除历史记录
-(void)cleanAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定清空网址历史记录吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [ZXIpaUrlHisModel zx_dbDropTable];
        [self setTbData];
    }];
    [alertController addThemeAction:cancelAction];
    [alertController addThemeAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
#pragma mark - Private
#pragma mark 设置tableView数据
-(void)setTbData{
    if(!self.tableView)return;
    NSMutableArray *allData = [[ZXIpaUrlHisModel zx_dbQuaryAll] mutableCopy];
    self.tableView.zxDatas = (NSMutableArray *)[[allData reverseObjectEnumerator] allObjects];
    
    if(!self.tableView.zxDatas.count){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showPlaceViewWithText:@"暂无数据"];
        });
        self.navigationItem.rightBarButtonItem.enabled = NO;
       
    }else{
        [self removePlaceView];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [self.tableView reloadData];
}

#pragma mark - 生命周期
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setTbData];
}

@end
