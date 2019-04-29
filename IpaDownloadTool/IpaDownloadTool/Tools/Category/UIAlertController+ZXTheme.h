//
//  UIAlertController+ZXTheme.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (ZXTheme)
///添加主题色按钮
- (void)addThemeAction:(UIAlertAction *)action;
@end

NS_ASSUME_NONNULL_END
