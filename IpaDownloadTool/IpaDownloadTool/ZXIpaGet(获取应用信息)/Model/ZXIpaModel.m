//
//  ZXIpaModel.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXIpaModel.h"
#import "NSString+ZXMD5.h"
@implementation ZXIpaModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if(self = [super init]){
        NSDictionary *item = dic[@"items"][0];
        NSArray *assets = item[@"assets"];
        NSDictionary *metadata = item[@"metadata"];
        for (NSDictionary *asset in assets) {
            NSString *kind = asset[@"kind"];
            if([kind isEqualToString:@"software-package"]){
                self.downloadUrl = asset[@"url"];
            }
            if([kind isEqualToString:@"display-image"]){
                self.iconUrl = asset[@"url"];
            }
        }
        self.bundleId = metadata[@"bundle-identifier"];
        self.version = metadata[@"bundle-version"];
        self.title = metadata[@"title"];
        
        NSString *orgSign = [NSString stringWithFormat:@"%@%@%@",self.bundleId,self.version,self.fromPageUrl];
        NSString *sign = [orgSign md5Str];
        self.sign = sign;
    }
    return self;
}
-(NSString *)localPath{
    _localPath = [NSString stringWithFormat:@"%@/%@/%@.ipa",ZXDocPath,ZXIpaDownloadedPath,self.sign];
    return _localPath;
}
@end
