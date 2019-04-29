//
//  ZXDataHandleLog.h
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/3/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#ifndef ZXDataHandleLog_h
#define ZXDataHandleLog_h
#define ZXDocPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define DbPath [ZXDocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",[NSBundle mainBundle].bundleIdentifier]]
#ifdef DEBUG
#define ZXDataHandleLog(FORMAT, ...) fprintf(stderr,"------------------------- ZXDataHandleLog -------------------------\n编译时间:%s\n文件名:%s\n方法名:%s\n行号:%d\n打印信息:%s\n\n", __TIME__,[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__func__,__LINE__,[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#else
#define ZXDataHandleLog(FORMAT, ...) nil
#endif

#endif /* ZXDataHandleLog_h */
