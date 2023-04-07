//
//  NSString+ZXIpaRegular.h
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ZXIpaRegular)
///获取plist文件下载路径
-(NSString *)getPlistPathUrlStr;
///获取网页的favicon路径
-(NSString *)getWebFaviconStrWithHostUrl:(NSString *)hostUrl;
///解析query数据
- (NSDictionary *)parseToQuery;
///根据字典替换字符串中内容
- (NSString *)replaceKeysWithValuesInDict:(NSDictionary *)dic;
///判断字符串是否匹配任一规则
- (BOOL)matchesAnyRegexInArr:(NSArray<NSString *> *)regexArr;
@end

NS_ASSUME_NONNULL_END
