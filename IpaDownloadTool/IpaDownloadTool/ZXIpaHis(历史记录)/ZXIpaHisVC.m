//
//  ZXIpaHisVC.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/IpaDownloadTool

#import "ZXIpaHisVC.h"
#import "ZXIpaHisCell.h"
#import "ZXIpaModel.h"

#import "ZXIpaDetailVC.h"
@interface ZXIpaHisVC ()
@property (weak, nonatomic) IBOutlet ZXTableView *tableView;
@end

@implementation ZXIpaHisVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}
#pragma mark - 初始化视图
-(void)initUI{
    self.title = @"IPA提取历史记录";
    __weak __typeof(self) weakSelf = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(cleanAction)];
    
    self.tableView.zx_setCellClassAtIndexPath = ^Class(NSIndexPath *indexPath) {
        return [ZXIpaHisCell class];
    };
    self.tableView.zx_didSelectedAtIndexPath = ^(NSIndexPath *indexPath, id model, id cell) {
        ZXIpaDetailVC *VC = [[ZXIpaDetailVC alloc]init];
        VC.ipaModel = model;
        [weakSelf.navigationController pushViewController:VC animated:YES];
    };
    self.tableView.zx_editActionsForRowAtIndexPath = ^NSArray<UITableViewRowAction *> *(NSIndexPath *indexPath) {
        UITableViewRowAction *delAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            ZXIpaModel *delModel = weakSelf.tableView.zxDatas[indexPath.row];
            [ZXFileManage delFileWithPath:delModel.localPath];
            [ZXIpaModel zx_dbDropWhere:[NSString stringWithFormat:@"sign='%@'",delModel.sign]];
            [weakSelf setTbData];
        }];
        return @[delAction];
    };
}
#pragma mark - Actions
#pragma mark 点击清除历史记录
-(void)cleanAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定清空IPA提取历史记录吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [ZXIpaModel zx_dbDropTable];
        [ZXFileManage delFileWithPathComponent:[NSString stringWithFormat:@"%@",ZXIpaDownloadedPath]];
        [ZXFileManage creatDirWithPathComponent:ZXIpaDownloadedPath];
        
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
    NSMutableArray *allData = [[ZXIpaModel zx_dbQuaryAll] mutableCopy];
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
