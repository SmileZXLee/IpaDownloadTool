//
//  ZXIpaUrlHisModel.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2021/1/16.
//  Copyright © 2021 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXIpaUrlHisModel : NSObject
///host链接
@property (copy, nonatomic) NSString *hostStr;
///网站链接
@property (copy, nonatomic) NSString *urlStr;
///网站标题
@property (copy, nonatomic) NSString *title;
///网站图标
@property (copy, nonatomic) NSString *favicon;
@end

NS_ASSUME_NONNULL_END
