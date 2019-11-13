//
//  ZXAppdelegate.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/IpaDownloadTool

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
 @property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@end

NS_ASSUME_NONNULL_END
