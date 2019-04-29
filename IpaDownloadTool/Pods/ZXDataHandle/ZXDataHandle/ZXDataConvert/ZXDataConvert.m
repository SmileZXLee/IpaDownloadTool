//
//  ZXDataConvert.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/27.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "ZXDataConvert.h"

@implementation ZXDataConvert
+ (instancetype)shareInstance{
    static ZXDataConvert * s_instance_dj_singleton = nil ;
    if (s_instance_dj_singleton == nil) {
        s_instance_dj_singleton = [[ZXDataConvert alloc] init];
    }
    return (ZXDataConvert *)s_instance_dj_singleton;
}
-(NSMutableDictionary *)allPropertyDic{
    if(_allPropertyDic){
        _allPropertyDic = [NSMutableDictionary dictionary];
    }
    return _allPropertyDic;
}

@end
