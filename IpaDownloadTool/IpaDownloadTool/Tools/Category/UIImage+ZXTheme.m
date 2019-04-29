//
//  UIImage+ZXTheme.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "UIImage+ZXTheme.h"

@implementation UIImage (ZXTheme)
+ (UIImage *)imageThemeNamed:(NSString *)name{
    UIImage *orgImg = [self imageNamed:name];
    return [[orgImg gray] renderingColor:MainColor];
}
@end
