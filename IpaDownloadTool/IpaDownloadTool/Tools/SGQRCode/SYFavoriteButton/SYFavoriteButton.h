//
//  SYFavoriteButton.h
//  SYFavoriteButton
//
//  Created by Sunnyyoung on 15/8/27.
//  Copyright (c) 2015年 GeekBean Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface SYFavoriteButton : UIButton

@property (nonatomic, strong) IBInspectable UIImage *image;
@property (nonatomic, strong) IBInspectable UIColor *favoredColor;
@property (nonatomic, strong) IBInspectable UIColor *defaultColor;
@property (nonatomic, strong) IBInspectable UIColor *circleColor;
@property (nonatomic, strong) IBInspectable UIColor *lineColor;
@property (nonatomic, assign) IBInspectable CGFloat duration;

@end
