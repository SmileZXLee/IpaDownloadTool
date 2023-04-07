//
//  ZXDeviceInfo.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2023/4/7.
//  Copyright © 2023 李兆祥. All rights reserved.
//

#import "ZXDeviceInfo.h"
#include <sys/utsname.h>

@implementation ZXDeviceInfo

+ (ZXDeviceInfoModel *)getDeviceInfo{
    ZXDeviceInfoModel *model = [[ZXDeviceInfoModel alloc]init];
    model.IMEI_RESULT = [self getRandomIMEI];
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    model.PRODUCT_RESULT = deviceModel;
    model.UDID_RESULT = @"0000-0000-0000";
    
    return model;
}



+ (NSString *)getRandomIMEI{
    NSString *randomNumberString = @"";
    for (int i = 0; i < 3; i++) {
        int randomNumber = arc4random_uniform(900000) + 100000;
        randomNumberString = [randomNumberString stringByAppendingFormat:@"%d", randomNumber];
        if (i != 2) {
            randomNumberString = [randomNumberString stringByAppendingString:@" "];
        }
    }
    randomNumberString = [randomNumberString stringByAppendingFormat:@" %d", arc4random_uniform(10)];
    return randomNumberString;
}

+ (NSString *)getUUID{
    NSUUID *uuid = [UIDevice currentDevice].identifierForVendor;
    return [uuid UUIDString];
}
@end
