//
//  UIView+ZXTbGetResponder.h
//  ZXTableViewDemo
//
//  Created by 李兆祥 on 2019/10/22.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXTableView

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZXTbGetResponder)
///获取当前view所属的cls类型对象(返回最接近且符合条件的父类)
- (id)zx_getResponderWithClass:(Class)cls;
///获取当前view所属的tableView
@property(weak, nonatomic, readonly)UITableView *zx_tableView;
///获取当前view所属的控制器
@property(weak, nonatomic, readonly)UIViewController *zx_vc;
///获取当前view所属的导航控制器
@property(weak, nonatomic, readonly)UINavigationController *zx_navVc;
///获取ZXTableView的zxDatas可变数组
@property(strong, nonatomic)NSMutableArray *zx_tableViewDatas;
@end

NS_ASSUME_NONNULL_END
