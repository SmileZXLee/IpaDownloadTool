//
//  UIViewController+ZXAlert.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2023/4/8.
//  Copyright © 2023 李兆祥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ZXAlert)
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
