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
///headerView与footerView的section属性，存储当前headerView与footerView所属的section
static NSString *const SECTION = @"section";
///若ZXTableView无法自动获取cell高度（zxdata有值即可），且用户未自定义高度，则使用默认高度
static CGFloat const CELLDEFAULTH = 44;

#pragma mark - TableView默认偏好配置
///无数据是否显示HeaderView，默认为YES
static BOOL const ShowHeaderWhenNoMsg = YES;
///无数据是否显示FooterView，默认为YES
static BOOL const ShowFooterWhenNoMsg = YES;
///保持headerView不变（仅初始化一次），默认为NO
static BOOL const KeepStaticHeaderView = NO;
///保持footerView不变（仅初始化一次），默认为NO
static BOOL const KeepStaticFooterView = NO;
///禁止系统Cell自动高度 可以有效解决tableView跳动问题，默认为YES
static BOOL const DisableAutomaticDimension = YES;
///分割线样式，默认为UITableViewCellSeparatorStyleNone
static BOOL const DefaultSeparatorStyle =  UITableViewCellSeparatorStyleNone;
///控制获取cell回调在获取model之后，默认为NO
static BOOL const FixCellBlockAfterAutoSetModel = NO;
///当选中cell的时候是否自动调用tableView的deselectRowAtIndexPath，默认为YES
static BOOL const AutoDeselectWhenSelected = YES;
///zx_autoPushConfigDictionary获取push控制器的key
static NSString *const AutoPushConfigPushVCKey = @"vc";
///zx_autoPushConfigDictionary获取model值的key
static NSString *const AutoPushConfigModelValueKey = @"model";
///zx_autoPushConfigDictionary获取indexpath值的key
static NSString *const AutoPushConfigIndexPathValueKey = @"indexpath";
///zx_autoPushConfigDictionary获取cell值的key
static NSString *const AutoPushConfigCellValueKey = @"cell";

#endif /* ZXTableViewConfig_h */
