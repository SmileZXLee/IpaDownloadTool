//
//  ZXDeviceInfoModel.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2023/4/7.
//  Copyright © 2023 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXDeviceInfoModel : NSObject

///IMEI
@property (copy, nonatomic) NSString *IMEI_RESULT;
///PRODUCT
@property (copy, nonatomic) NSString *PRODUCT_RESULT;
///UDID
@property (copy, nonatomic) NSString *UDID_RESULT;

@end

NS_ASSUME_NONNULL_END
