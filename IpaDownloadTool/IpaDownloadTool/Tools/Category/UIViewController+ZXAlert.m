//
//  UIViewController+ZXAlert.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2023/4/8.
//  Copyright © 2023 李兆祥. All rights reserved.
//

#import "UIViewController+ZXAlert.h"

@implementation UIViewController (ZXAlert)
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addThemeAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end

