//
//  ZXLocalIpaDownloadModel.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXLocalIpaDownloadModel.h"

@implementation ZXLocalIpaDownloadModel
-(NSString *)localPath{
    _localPath = [NSString stringWithFormat:@"%@/%@/%@.ipa",ZXDocPath,ZXIpaDownloadedPath,self.sign];
    return _localPath;
}
@end
