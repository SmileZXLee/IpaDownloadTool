//
//  UIImage+Rendering.h
//  Focus
//
//  Created by 李兆祥 on 2018/5/2.
//  Copyright © 2018年 李兆祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rendering)
///将图片渲染为需要的颜色
-(UIImage*)renderingColor:(UIColor *)color;
///图片转为灰色
-(UIImage *)gray;
@end
