//
//  UIViewController+ZXPlaceView.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/5/24.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXPlaceView.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ZXPlaceView)
@property (weak, nonatomic, readonly) ZXPlaceView *placeView;
///显示ZXPlaceView
-(void)showPlaceViewWithText:(NSString *)text;
///移除ZXPlaceView
-(void)removePlaceView;
@end

NS_ASSUME_NONNULL_END
