//
//  ZXArchived.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  继承这个类即可直接将自定义的对象归档存储

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXClassArchived : NSObject <NSCoding>
-(void)encodeWithCoder:(NSCoder *)enCoder;
-(id)initWithCoder:(NSCoder *)decoder;
@end

NS_ASSUME_NONNULL_END
