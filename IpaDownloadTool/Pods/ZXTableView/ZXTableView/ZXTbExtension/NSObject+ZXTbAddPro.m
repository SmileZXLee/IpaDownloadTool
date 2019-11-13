//
//  NSObject+ZXTbAddPro.m
//  ZXTableView
//
//  Created by 李兆祥 on 2019/3/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXTableView

#import "NSObject+ZXTbAddPro.h"
#import "objc/runtime.h"
@implementation NSObject (ZXTbAddPro)
-(void)setCellHRunTime:(NSNumber *)cellHRunTime{
    objc_setAssociatedObject(self, @"cellHRunTime",cellHRunTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)cellHRunTime
{
    return objc_getAssociatedObject(self, @"cellHRunTime");
}
@end
