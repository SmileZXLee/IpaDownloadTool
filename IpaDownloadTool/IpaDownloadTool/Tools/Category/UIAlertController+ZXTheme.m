//
//  UIAlertController+ZXTheme.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "UIAlertController+ZXTheme.h"

@implementation UIAlertController (ZXTheme)
- (void)addThemeAction:(UIAlertAction *)action{
    [action setValue:MainColor forKey:@"titleTextColor"];
    [self addAction:action];
}
@end
