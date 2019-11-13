//
//  NSMutableArray+ZXSafetySet.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "NSMutableArray+ZXSafetySet.h"
#import "ZXDataHandleLog.h"
@implementation NSMutableArray (ZXSafetySet)
-(id)zx_arrSafetyObjAtIndex:(NSUInteger)index{
    if(index < self.count){
        return [self objectAtIndex:index];
    }else{
        ZXDataHandleLog(@"数组：%@的索引%lu不存在",self,(unsigned long)index);
        return nil;
    }
}
-(void)zx_arrSafetyAddObj:(id)obj{
    if(obj){
        [self addObject:obj];
    }else{
        ZXDataHandleLog(@"加入数组的对象不存在");
    }
}
-(void)zx_arrSafetyAddObjNORepetition:(id)obj{
    if(![self containsObject:obj]){
        [self zx_arrSafetyAddObj:obj];
    }
}

-(void)zx_arrSafetyRemoveObj:(id)obj{
    if([self containsObject:obj]){
        [self removeObject:obj];
    }
}
@end
