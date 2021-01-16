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
- (void)setZx_cellHRunTime:(NSNumber *)cellHRunTime{
    objc_setAssociatedObject(self, @"zx_cellHRunTime",cellHRunTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)zx_cellHRunTime{
    return objc_getAssociatedObject(self, @"zx_cellHRunTime");
}

- (void)setZx_indexPathInTableView:(NSIndexPath *)zx_indexPathInTableView{
    objc_setAssociatedObject(self, @"zx_indexPathInTableView", zx_indexPathInTableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSIndexPath *)zx_indexPathInTableView{
    return objc_getAssociatedObject(self, @"zx_indexPathInTableView");
}

- (void)setZx_sectionInTableView:(NSUInteger)zx_sectionInTableView{
    objc_setAssociatedObject(self, @"zx_sectionInTableView", [NSNumber numberWithInteger:zx_sectionInTableView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)zx_sectionInTableView{
    return [objc_getAssociatedObject(self, @"zx_sectionInTableView") unsignedIntegerValue];
}


@end
