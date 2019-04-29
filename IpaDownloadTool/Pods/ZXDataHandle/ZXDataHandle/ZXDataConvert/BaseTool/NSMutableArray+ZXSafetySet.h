//
//  NSMutableArray+ZXSafetySet.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (ZXSafetySet)
-(id)zx_arrSafetyObjAtIndex:(NSUInteger)index;
-(void)zx_arrSafetyAddObj:(id)obj;
-(void)zx_arrSafetyAddObjNORepetition:(id)obj;
-(void)zx_arrSafetyRemoveObj:(id)obj;
@end

NS_ASSUME_NONNULL_END
