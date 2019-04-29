//
//  JHFeilterManager.h
//  iOS滤镜测试
//
//  Created by 简豪 on 16/6/19.
//  Copyright © 2016年 codingMan. All rights reserved.
/************************************************************
 *                                                           *
 *                                                           *
 简单的滤镜效果生成器
 github地址：https://github.com/China131/JHFilterDemo.git
 主人微博：http://www.cnblogs.com/ToBeTheOne/
 *                                                           *
 *                                                           *
 ************************************************************/


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void(^imageBlock)(UIImage *image);

@interface JHFeilterManager : NSObject

@property (nonatomic,copy)imageBlock imageBLOCK;

- (UIImage *)createImageWithImage:(UIImage *)inImage
                      colorMatrix:(const float *)f;


@end
