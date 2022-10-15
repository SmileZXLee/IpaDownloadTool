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
typedef enum {
    SortTimeDesc = 0x00,    // 按照时间降序排列
    SortFileNameAsc = 0x01,    // 按照文件名升序排列
}SortType;

@interface ZXIpaHisVC ()
@property (weak, nonatomic) IBOutlet ZXTableView *tableView;
@property (assign, nonatomic) SortType sort;
@property (copy, nonatomic) NSString *sortKey;
@end

@implementation ZXIpaHisVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}
#pragma mark - 初始化视图
-(void)initUI{
    self.title = @"IPA提取历史";
    __weak __typeof(self) weakSelf = self;
    UIBarButtonItem *cleanItem = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(cleanAction)];
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc]initWithImage:[self resizeImage:[UIImage imageNamed:self.sortKey] toSize:CGSizeMake(28, 28)] style:UIBarButtonItemStyleDone target:self action:@selector(sortAction)];
    self.navigationItem.rightBarButtonItems = @[cleanItem,sortItem];
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
#pragma mark 切换排序方式
-(void)sortAction{
    NSString *currentSort = self.sort == SortFileNameAsc ? @"time_desc" : @"file_name_asc";
    [[NSUserDefaults standardUserDefaults]setObject:currentSort forKey:@"historySort"];
    ((UIBarButtonItem *)self.navigationItem.rightBarButtonItems[1]).image = [self resizeImage:[UIImage imageNamed:self.sortKey] toSize:CGSizeMake(28, 28)];
    [self setTbData];
}
#pragma mark - Private
#pragma mark 设置tableView数据
-(void)setTbData{
    if(!self.tableView)return;
    
    NSMutableArray *allData = [[ZXIpaModel zx_dbQuaryWhere:self.sort == SortFileNameAsc ? @"1 = 1 order by title asc" : @"1 = 1 order by time desc"] mutableCopy];
    self.tableView.zxDatas = allData;
    
    if(!self.tableView.zxDatas.count){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showPlaceViewWithText:@"暂无数据"];
        });
        ((UIBarButtonItem *)self.navigationItem.rightBarButtonItems[0]).enabled = NO;
       
    }else{
        [self removePlaceView];
        ((UIBarButtonItem *)self.navigationItem.rightBarButtonItems[0]).enabled = YES;
    }
    [self.tableView reloadData];
}


-(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark getter
-(SortType)sort{
    NSString *historySort = [[NSUserDefaults standardUserDefaults]objectForKey:@"historySort"];
    if(historySort && [historySort isEqualToString:@"file_name_asc"]){
        _sort = SortFileNameAsc;
    }else{
        _sort = SortTimeDesc;
    }
    return _sort;
}
-(NSString *)sortKey{
    _sortKey = self.sort == SortFileNameAsc ? @"file_name_asc" : @"time_desc";
    return _sortKey;
}

#pragma mark - 生命周期
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setTbData];
}
@end
