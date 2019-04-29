//
//  NSObject+ZXKVO.h
//  ZXKVO
//
//  Created by 李兆祥 on 2018/8/22.
//  Copyright © 2018年 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^obsResultHandler) (id newData, id oldData,id owner);
@interface NSObject (ZXKVO)
-(void)zx_obsKey:(NSString *)key handler:(obsResultHandler)handler;
@end
