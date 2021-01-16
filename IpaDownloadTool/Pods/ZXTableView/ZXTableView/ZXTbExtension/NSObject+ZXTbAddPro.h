//
//  NSObject+ZXTbAddPro.h
//  ZXTableView
//
//  Created by 李兆祥 on 2019/3/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXTableView

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZXTbAddPro)
//非readonly是为了开发者便于重写set方法进行处理
///获取tableView中当前cell/model对应的indexPath
@property(strong, nonatomic)NSIndexPath *zx_indexPathInTableView;
///获取tableView中当前headerView/footerView/cell/model对应的section
@property(assign, nonatomic)NSUInteger zx_sectionInTableView;
@end

NS_ASSUME_NONNULL_END
