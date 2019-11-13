//
//  ZXTableViewConfig.h
//  ZXTableView
//
//  Created by 李兆祥 on 2019/3/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXTableView

#ifndef ZXTableViewConfig_h
#define ZXTableViewConfig_h
#pragma mark - 数据处理配置
///model默认去匹配的cell高度属性名 若不存在则动态生成cellHRunTime的属性名
static NSString *const CELLH = @"cellH";
///cell会自动赋值包含“model”的属性
static NSString *const DATAMODEL = @"model";
///model与cell的index属性，存储当前model与cell所属的indexPath
static NSString *const INDEX = @"indexPath";
///若ZXBaseTableView无法自动获取cell高度（zxdata有值即可），且用户未自定义高度，则使用默认高度
static CGFloat const CELLDEFAULTH = 44;

#pragma mark - TableView默认偏好配置
///无数据是否显示HeaderView，默认为YES
static BOOL const ShowHeaderWhenNoMsg = YES;
///无数据是否显示FooterView，默认为YES
static BOOL const ShowFooterWhenNoMsg = YES;
///禁止系统Cell自动高度 可以有效解决tableView跳动问题，默认为YES
static BOOL const DisableAutomaticDimension = YES;
///分割线样式，默认为UITableViewCellSeparatorStyleNone
static BOOL const DefaultSeparatorStyle =  UITableViewCellSeparatorStyleNone;

#endif /* ZXTableViewConfig_h */
