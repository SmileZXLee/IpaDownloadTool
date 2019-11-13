//
//  UIImage+ZXTheme.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ZXTheme)
///将图像转化为主题色图像
+ (UIImage *)imageThemeNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
