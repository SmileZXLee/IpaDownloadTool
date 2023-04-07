//
//  ZXURLProtocol.h
//  ZXRequestBlock
//
//  Created by 李兆祥 on 2018/8/26.
//  Copyright © 2018年 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXRequestBlock
//  V1.0.3

#import <Foundation/Foundation.h>
@interface ZXURLProtocol : NSURLProtocol
@property (nonatomic, copy) NSURLRequest *(^requestBlock)(NSURLRequest *request);
@property (nonatomic, copy) NSData *(^responseBlock)(NSURLResponse *response, NSData *data);
+(instancetype)sharedInstance;
@end
