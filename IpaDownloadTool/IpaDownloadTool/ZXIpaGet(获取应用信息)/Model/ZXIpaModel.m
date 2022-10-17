//
//  ZXIpaModel.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXIpaModel.h"
#import "NSString+ZXMD5.h"
@implementation ZXIpaModel{
    BOOL hasLoadLocalPath;
}

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

-(NSString *)title{
    if(_title && _title.length > 50){
        _title = [_title substringToIndex:50];
    }
    return _title;
}

-(NSString *)localPath{
    if(!hasLoadLocalPath){
        NSString *localPath = [NSString stringWithFormat:@"%@/%@/%@/%@.ipa",ZXDocPath,ZXIpaDownloadedPath,self.sign,self.title];
        NSString *oldLocalPath = [NSString stringWithFormat:@"%@/%@/%@.ipa",ZXDocPath,ZXIpaDownloadedPath,self.sign];
        if([ZXFileManage isExistWithPath:oldLocalPath]){
            _localPath = oldLocalPath;
        }else {
            _localPath = localPath;
        }
        hasLoadLocalPath = YES;
    }
    return _localPath;
}
@end
