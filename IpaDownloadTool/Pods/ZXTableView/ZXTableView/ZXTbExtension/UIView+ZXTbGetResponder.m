//
//  UIView+ZXTbGetResponder.m
//  ZXTableViewDemo
//
//  Created by 李兆祥 on 2019/10/22.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXTableView

#import "UIView+ZXTbGetResponder.h"
#import <objc/runtime.h>
@implementation UIView (ZXTbGetResponder)

#pragma mark - Public
- (id)zx_getResponderWithClass:(Class)cls{
    for (UIView *next = self; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:cls]) {
            return nextResponder;
        }
    }
    return nil;
}

#pragma mark - Private
- (UIViewController *)zx_getVC{
    return [self zx_getResponderWithClass:[UIViewController class]];
}

- (UITableView *)zx_getTableView{
    return [self zx_getResponderWithClass:[UITableView class]];
}

- (NSMutableArray *)zx_getZXDatas{
    UITableView *tableView = [self zx_getTableView];
    if(tableView && [tableView isKindOfClass:NSClassFromString(@"ZXTableView")]){
        return [tableView valueForKey:@"zxDatas"];
    }
    return nil;
}
- (void)zx_setZXDatas:(id)zxDatas{
    UITableView *tableView = [self zx_getTableView];
    if(tableView && [tableView isKindOfClass:NSClassFromString(@"ZXTableView")]){
        [tableView setValue:zxDatas forKey:@"zxDatas"];
    }
}

#pragma mark - getter
- (UITableView *)zx_tableView{
    return [self zx_getTableView];
}

- (UIViewController *)zx_vc{
    return [self zx_getVC];
}

- (UINavigationController *)zx_navVc{
    return self.zx_vc.navigationController;
}

- (NSMutableArray *)zx_tableViewDatas{
    return [self zx_getZXDatas];
}

- (void)setZx_tableViewDatas:(NSMutableArray *)zx_tableViewDatas{
    [self zx_setZXDatas:zx_tableViewDatas];
}

@end
