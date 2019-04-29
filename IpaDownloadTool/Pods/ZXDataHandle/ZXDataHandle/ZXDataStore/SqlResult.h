//
//  SqlResult.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/3/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SqlResult : NSObject
@property(nonatomic,assign)BOOL success;
@property(nonatomic,strong)NSArray *resData;
@property(nonatomic,assign)char *error;
@end

NS_ASSUME_NONNULL_END
