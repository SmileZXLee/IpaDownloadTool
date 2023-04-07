//
//  ZXDeviceInfo.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2023/4/7.
//  Copyright © 2023 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXDeviceInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZXDeviceInfo : NSObject
+ (ZXDeviceInfoModel *)getDeviceInfo;
@end

NS_ASSUME_NONNULL_END
