//
//  ZXPlaceView.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXPlaceView : UIView
///显示占位图提示信息
+(instancetype)showWithNotice:(NSString *)notice superV:(UIView *)superView;
@end

NS_ASSUME_NONNULL_END
