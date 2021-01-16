//
//  ZXTableView.h
//  ZXTableView
//
//  Created by 李兆祥 on 2019/3/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXTableView

#import <UIKit/UIKit.h>
//在任何view中获取所属的控制器、导航控制器，tableView和ZXTableView的zxDatas
#import "UIView+ZXTbGetResponder.h"
//在任何对象中获取在tableView所属的indexPath和section
#import "NSObject+ZXTbAddPro.h"
NS_ASSUME_NONNULL_BEGIN
@interface ZXTableView : UITableView
#pragma mark - 数据设置
///设置所有数据数组
@property(nonatomic, strong)NSMutableArray *zxDatas;
///设置所有cell的类名
@property (nullable, nonatomic, copy) IBInspectable NSString *zx_cellClassName;
///设置cell的类，若设置了，则zx_cellClassName无效
@property (nonatomic, copy) Class (^zx_setCellClassAtIndexPath)(NSIndexPath *indexPath);
///设置cell的高度(非必须，若设置了，则内部的自动计算高度无效)
@property (nonatomic, copy) CGFloat (^zx_setCellHAtIndexPath)(NSIndexPath *indexPath);
///设置section数量(非必须，若设置了，则内部自动设置section个数无效)
@property (nonatomic, copy) CGFloat (^zx_setNumberOfSectionsInTableView)(UITableView *tableView);
///设置对应section中row的数量(非必须，若设置了，则内部自动设置对应section中row的数量无效)
@property (nonatomic, copy) CGFloat (^zx_setNumberOfRowsInSection)(NSUInteger section);
///设置返回每个索引的内容
@property (nonatomic, copy) NSString * (^zx_setTitleForHeaderInSection)(NSUInteger section);
///设置返回索引数组
@property (nonatomic, copy) NSArray<NSString *> * (^zx_setSectionIndexTitlesForTableView)(UITableView *tableView);
///设置索引对应的section
@property (nonatomic, copy) NSInteger (^zx_setSectionForSectionIndex)(NSString *title,NSInteger index);
///设置所有headerView的类名
@property (nullable, nonatomic, copy) IBInspectable NSString *zx_headerClassName;
///根据HeaderView类名设置HeaderView，写了此方法则zx_setHeaderViewInSection无效，无需实现zx_setHeaderHInSection，自动计算高度，若设置了，则zx_headerClassName无效
@property (nonatomic, copy) Class (^zx_setHeaderClassInSection)(NSInteger section);
///设置所有footerView的类名
@property (nullable, nonatomic, copy) IBInspectable NSString *zx_footerClassName;
///根据FooterView类名设置FooterView，写了此方法则zx_setFooterViewInSection无效，无需实现zx_setFooterHInSection，自动计算高度，若设置了，则zx_footerClassName无效
@property (nonatomic, copy) Class (^zx_setFooterClassInSection)(NSInteger section);
///设置HeaderView，必须实现zx_setHeaderHInSection
@property (nonatomic, copy) UIView *(^zx_setHeaderViewInSection)(NSInteger section);
///设置FooterView，必须实现zx_setFooterHInSection
@property (nonatomic, copy) UIView *(^zx_setFooterViewInSection)(NSInteger section);
///设置HeaderView高度，非必须，若设置了则自动设置的HeaderView高度无效
@property (nonatomic, copy) CGFloat (^zx_setHeaderHInSection)(NSInteger section);
///设置FooterView高度，非必须，若设置了则自动设置的FooterView高度无效
@property (nonatomic, copy) CGFloat (^zx_setFooterHInSection)(NSInteger section);
///设置点击cell自动跳转的配置字典，如@{@"vc":@"TestVC",@"testGoodid":@"model.goodid"}则代表点击cell自动push到控制器TestVC，且将cell对应model的goodid赋值给TestVC控制器的testGoodid属性
@property(nonatomic, strong) NSDictionary *zx_autoPushConfigDictionary;
///禁止系统Cell自动高度 可以有效解决tableView跳动问题，默认为YES
@property(nonatomic, assign)BOOL zx_disableAutomaticDimension;
///无数据是否显示HeaderView，默认为YES
@property(nonatomic, assign)BOOL zx_showHeaderWhenNoMsg;
///无数据是否显示FooterView，默认为YES
@property(nonatomic, assign)BOOL zx_showFooterWhenNoMsg;
///保持headerView不变（仅初始化一次），默认为NO
@property(nonatomic, assign)BOOL zx_keepStaticHeaderView;
///保持footerView不变（仅初始化一次），默认为NO
@property(nonatomic, assign)BOOL zx_keepStaticFooterView;
///控制获取cell回调在获取model之后，默认为NO
@property(nonatomic, assign)BOOL zx_fixCellBlockAfterAutoSetModel;
///当选中cell的时候是否自动调用tableView的deselectRowAtIndexPath，默认为YES
@property(nonatomic, assign)BOOL zx_autoDeselectWhenSelected;
///是否将所有cell的SelectionStyle设置为None，默认为NO
@property(nonatomic, assign)BOOL zx_makeAllCellSelectionStyleNone;
#pragma mark - 数据获取
///获取对应行的cell，把id改成对应类名即可无需强制转换
@property (nonatomic, copy) void (^zx_getCellAtIndexPath)(NSIndexPath *indexPath,id cell,id model);
///获取对应section的headerView，把id改成对应类名即可无需强制转换，secArr为对应section的model数组
@property (nonatomic, copy) void (^zx_getHeaderViewInSection)(NSUInteger section,id headerView,NSMutableArray *secArr);
///获取对应section的footerView，把id改成对应类名即可无需强制转换，secArr为对应section的model数组
@property (nonatomic, copy) void (^zx_getFooterViewInSection)(NSUInteger section,id footerView,NSMutableArray *secArr);
#pragma mark - 偏好设置(全局设置)
///在子类中重写这个方法，可以统一设置所有cell样式
-(void)zx_setCell:(UITableViewCell *)cell;
///在子类中重写这个方法，可以统一设置所有tableView样式
-(void)zx_setTableView;

#pragma mark - 快速构建
///声明cell的类并返回cell对象
-(void)zx_setCellClassAtIndexPath:(Class (^)(NSIndexPath * indexPath)) setCellClassCallBack returnCell:(void (^)(NSIndexPath * indexPath,id cell,id model))returnCellCallBack;
///声明HeaderView的类并返回HeaderView对象
-(void)zx_setHeaderClassInSection:(Class (^)(NSInteger section)) setHeaderClassCallBack returnHeader:(void (^)(NSUInteger section,id headerView,NSMutableArray *secArr))returnHeaderCallBack;
///声明FooterView的类并返回FooterView对象
-(void)zx_setFooterClassInSection:(Class (^)(NSInteger section)) setFooterClassCallBack returnHeader:(void (^)(NSUInteger section,id headerView,NSMutableArray *secArr))returnFooterCallBack;
#pragma mark - 代理事件相关
///选中某一行，把id改成对应类名即可无需强制转换
@property (nonatomic, copy) void (^zx_didSelectedAtIndexPath)(NSIndexPath *indexPath,id model,id cell);
///取消选中某一行，把id改成对应类名即可无需强制转换
@property (nonatomic, copy) void (^zx_didDeselectedAtIndexPath)(NSIndexPath *indexPath,id model,id cell);
///滑动编辑
@property (nonatomic, copy) NSArray<UITableViewRowAction *>* (^zx_editActionsForRowAtIndexPath)(NSIndexPath *indexPath);
///cell将要展示，把id改成对应类名即可无需强制转换
@property (nonatomic, copy) void (^zx_willDisplayCell)(NSIndexPath *indexPath,id cell);
///cell已经展示，把id改成对应类名即可无需强制转换
@property (nonatomic, copy) void (^zx_didEndDisplayingCell)(NSIndexPath *indexPath,id cell);
///headerView将要展示，把id改成对应类名即可无需强制转换
@property (nonatomic, copy) void (^zx_willDisplayHeaderView)(NSInteger section,id headerView);
///headerView已经展示完毕，把id改成对应类名即可无需强制转换
@property (nonatomic, copy) void (^zx_didEndDisplayingHeaderView)(NSInteger section,id headerView);
///footerView将要展示，把id改成对应类名即可无需强制转换
@property (nonatomic, copy) void (^zx_willDisplayFooterView)(NSInteger section,id footerView);
///footerView已经展示完毕，把id改成对应类名即可无需强制转换
@property (nonatomic, copy) void (^zx_didEndDisplayingFooterView)(NSInteger section,id footerView);
///scrollView滚动事件
@property (nonatomic, copy) void (^zx_scrollViewDidScroll)(UIScrollView *scrollView);
///scrollView缩放事件
@property (nonatomic, copy) void (^zx_scrollViewDidZoom)(UIScrollView *scrollView);
///scrollView滚动到顶部事件
@property (nonatomic, copy) void (^zx_scrollViewDidScrollToTop)(UIScrollView *scrollView);
///scrollView开始拖拽事件
@property (nonatomic, copy) void (^zx_scrollViewWillBeginDragging)(UIScrollView *scrollView);
///scrollView结束拖拽事件
@property (nonatomic, copy) void (^zx_scrollViewDidEndDragging)(UIScrollView *scrollView, BOOL willDecelerate);
#pragma mark - UITableViewDataSource & UITableViewDelegate
///tableView的DataSource 设置为当前控制器即可重写对应数据源方法
@property (nonatomic, weak, nullable) id <UITableViewDataSource> zxDataSource;
///tableView的Delegate 设置为当前控制器即可重写对应代理方法
@property (nonatomic, weak, nullable) id <UITableViewDelegate> zxDelegate;
@end
NS_ASSUME_NONNULL_END
