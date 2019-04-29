//
//  ZXTableView.m
//  ZXTableView
//
//  Created by 李兆祥 on 2019/3/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXTableView

#import "ZXTableView.h"
#import "ZXTableViewConfig.h"
#import "ZXTbGetProName.h"
#import "NSObject+ZXTbSafeValue.h"
#import "NSObject+ZXTbAddPro.h"
@interface ZXTableView()<UITableViewDelegate,UITableViewDataSource>

@end
@implementation ZXTableView
#pragma mark - Perference
#pragma mark 设置ZXTableView，此设置会应用到全部的ZXTableView中
-(void)setZXTableView{
    [self privateSetZXTableView];
}
#pragma mark ZXTableView的cell，此设置会应用到全部的ZXTableView的cell中
-(void)setCell{
    
}

#pragma mark - UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if([self.zxDataSource respondsToSelector:@selector(cellForRowAtIndexPath:)]){
        return [self.zxDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    }else{
        id model = [self getModelAtIndexPath:indexPath];
        NSString *className  = nil;
        Class cellClass = nil;
        if(self.zx_setCellClassAtIndexPath){
            cellClass = self.zx_setCellClassAtIndexPath(indexPath);
            className = NSStringFromClass(cellClass);
        }
        BOOL isExist = [self hasNib:className];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:className];
        if(!cell){
            if(isExist){
                cell = [[[NSBundle mainBundle]loadNibNamed:className owner:nil options:nil]lastObject];
                [cell setValue:className forKey:@"reuseIdentifier"];
                [cell zx_safeSetValue:className forKey:@"reuseIdentifier"];
            }else{
                if(cellClass){
                    cell = [[cellClass alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:className];
                }else{
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:className];
                    cell.textLabel.text = @"Undefined Cell";
                }
            }
        }
        if(model){
            [model zx_safeSetValue:indexPath forKey:INDEX];
            [cell zx_safeSetValue:indexPath forKey:INDEX];
            CGFloat cellH = ((UITableViewCell *)cell).frame.size.height;
            if(cellH && ![[model zx_safeValueForKey:CELLH] floatValue]){
                NSMutableArray *modelProNames = [ZXTbGetProName zx_getRecursionPropertyNames:model];
                if([modelProNames containsObject:CELLH]){
                    [model zx_safeSetValue:[NSNumber numberWithFloat:cellH] forKey:CELLH];
                }else{
                    [model setCellHRunTime:[NSNumber numberWithFloat:cellH]];
                }
                
            }
            NSArray *cellProNames = [ZXTbGetProName zx_getRecursionPropertyNames:cell];
            BOOL cellContainsModel = NO;
            for (NSString *proStr in cellProNames) {
                if([proStr.uppercaseString containsString:DATAMODEL.uppercaseString]){
                    [cell zx_safeSetValue:model forKey:proStr];
                    cellContainsModel = YES;
                    break;
                }
            }
        }
        !self.zx_getCellAtIndexPath ? : self.zx_getCellAtIndexPath(indexPath,cell,model);
        [self setCell];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.zxDataSource respondsToSelector:@selector(numberOfRowsInSection:)]){
        return [self.zxDataSource tableView:tableView numberOfRowsInSection:section];
    }else{
        if(self.zx_setNumberOfRowsInSection){
            return self.zx_setNumberOfRowsInSection(section);
        }else{
            if([self isMultiDatas]){
                NSArray *sectionArr = [self.zxDatas objectAtIndex:section];
                if(![sectionArr isKindOfClass:[NSArray class]]){
                    NSAssert(NO, @"数据源内容不符合要求，多section情况数据源中必须皆为数组！");
                    return 0;
                }
                return sectionArr.count;
            }else{
                return self.zxDatas.count;
            }
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([self.zxDataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]){
        return [self.zxDataSource numberOfSectionsInTableView:tableView];
    }else{
        if(self.zx_setNumberOfSectionsInTableView){
            return self.zx_setNumberOfSectionsInTableView(tableView);
        }else{
            return [self isMultiDatas] ? self.zxDatas.count : 1;
        }
    }
}

#pragma mark - UITableViewDelegate
#pragma mark tableView 选中某一indexPath
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self deselectRowAtIndexPath:indexPath animated:YES];
    if([self.zxDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
        [self.zxDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }else{
        [self deselectRowAtIndexPath:indexPath animated:YES];
        id model = [self getModelAtIndexPath:indexPath];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        !self.zx_didSelectedAtIndexPath ? : self.zx_didSelectedAtIndexPath(indexPath,model,cell);
    }
}
#pragma mark tableView 取消选中某一indexPath
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.zxDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]){
        [self.zxDelegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
        id model = [self getModelAtIndexPath:indexPath];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        !self.zx_didDeselectedAtIndexPath ? : self.zx_didDeselectedAtIndexPath(indexPath,model,cell);
    }
}
#pragma mark tableView 滑动编辑
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.zx_editActionsForRowAtIndexPath){
        return self.zx_editActionsForRowAtIndexPath(indexPath);
    }else{
        return nil;
    }
}
#pragma mark tableView 是否可以编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.zx_editActionsForRowAtIndexPath){
        NSArray *rowActionsArr = self.zx_editActionsForRowAtIndexPath(indexPath);
        if(rowActionsArr && ![rowActionsArr isKindOfClass:[NSNull class]] && rowActionsArr.count){
            return YES;
        }
    }
    return NO;
}
#pragma mark tableView cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.zxDelegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]) {
        return UITableViewAutomaticDimension;
    }
    if([self.zxDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]){
        return [self.zxDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        if(self.zx_setCellHAtIndexPath){
            return self.zx_setCellHAtIndexPath(indexPath);
        }else{
            id model = [self getModelAtIndexPath:indexPath];
            if(model){
                CGFloat cellH = [[model zx_safeValueForKey:CELLH] floatValue];
                if(cellH){
                    return cellH;
                }else{
                    return [[model cellHRunTime] floatValue];
                }
            }
            else{
                return CELLDEFAULTH;
            }
        }
        
    }
}
#pragma mark tableView cell 将要展示
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    !self.zx_willDisplayCell ? : self.zx_willDisplayCell(indexPath,cell);
}
#pragma mark tableView HeaderView & FooterView
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = nil;
    if([self.zxDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]){
        headerView = [self.zxDelegate tableView:tableView viewForHeaderInSection:section];
        
    }else{
        if(self.zx_setHeaderClassInSection){
            headerView = [self getHeaderViewInSection:section];
            
        }else{
            if(self.zx_setHeaderViewInSection){
                headerView = self.zx_setHeaderViewInSection(section);
            }
        }
    }
    NSMutableArray *secArr = self.zxDatas.count ? [self isMultiDatas] ? self.zxDatas[section] : self.zxDatas : nil;
    !self.zx_getHeaderViewInSection ? : self.zx_getHeaderViewInSection(section,headerView,secArr);
    return !secArr.count ? self.zx_showHeaderWhenNoMsg ? headerView : nil : headerView;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = nil;
    if([self.zxDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]){
        footerView = [self.zxDelegate tableView:tableView viewForFooterInSection:section];
        
    }else{
        if(self.zx_setFooterClassInSection){
            footerView = [self getFooterViewInSection:section];
            
        }else{
            if(self.zx_setFooterViewInSection){
                footerView = self.zx_setFooterViewInSection(section);
            }
        }
    }
    NSMutableArray *secArr = self.zxDatas.count ? [self isMultiDatas] ? self.zxDatas[section] : self.zxDatas : nil;
    !self.zx_getFooterViewInSection ? : self.zx_getFooterViewInSection(section,footerView,secArr);
    return footerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]){
        return [self.zxDelegate tableView:tableView heightForHeaderInSection:section];
        
    }else{
        if(self.zx_setHeaderClassInSection){
            if(self.zx_setHeaderHInSection){
                return self.zx_setHeaderHInSection(section);
            }else{
                if(section < self.zxDatas.count || (self.zx_showHeaderWhenNoMsg &&  section == 0)){
                    UIView *headerView = [self getHeaderViewInSection:section];
                    return headerView.frame.size.height;
                }else{
                    return CGFLOAT_MIN;
                }
            }
        }else{
            if(self.zx_setHeaderHInSection){
                return self.zx_setHeaderHInSection(section);
            }else{
                return CGFLOAT_MIN;
            }
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]){
        return [self.zxDelegate tableView:tableView heightForFooterInSection:section];
        
    }else{
        if(self.zx_setFooterClassInSection){
            if(self.zx_setFooterHInSection){
                return self.zx_setFooterHInSection(section);
            }else{
                if(section < self.zxDatas.count || (self.zx_showFooterWhenNoMsg &&  section == 0)){
                    UIView *footerView = [self getFooterViewInSection:section];
                    return footerView.frame.size.height;
                }else{
                    return CGFLOAT_MIN;
                }
                
            }
        }else{
            if(self.zx_setFooterHInSection){
                return self.zx_setFooterHInSection(section);
            }else{
                return CGFLOAT_MIN;
            }
        }
    }
}

#pragma mark - scrollView相关代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([self.zxDelegate respondsToSelector:@selector(scrollViewDidScroll:)]){
        return [self.zxDelegate scrollViewDidScroll:scrollView];
        
    }else{
        if(self.zx_scrollViewDidScroll){
            self.zx_scrollViewDidScroll(scrollView);
        }
    }
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if([self.zxDelegate respondsToSelector:@selector(scrollViewDidZoom:)]){
        return [self.zxDelegate scrollViewDidZoom:scrollView];
        
    }else{
        if(self.zx_scrollViewDidZoom){
            self.zx_scrollViewDidZoom(scrollView);
        }
    }
}
-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if([self.zxDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]){
        return [self.zxDelegate scrollViewDidScrollToTop:scrollView];
        
    }else{
        if(self.zx_scrollViewDidScrollToTop){
            self.zx_scrollViewDidScrollToTop(scrollView);
        }
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if([self.zxDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        return [self.zxDelegate scrollViewWillBeginDragging:scrollView];
        
    }else{
        if(self.zx_scrollViewWillBeginDragging){
            self.zx_scrollViewWillBeginDragging(scrollView);
        }
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if([self.zxDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]){
        return [self.zxDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        
    }else{
        if(self.zx_scrollViewDidEndDragging){
            self.zx_scrollViewDidEndDragging(scrollView,decelerate);
        }
    }
}
#pragma mark - Other
#pragma mark 假数据填充，多section
-(void)zx_fillWithSectionCount:(NSUInteger)secCount rowCount:(NSUInteger)rowCount{
    NSMutableArray *datasArr = [NSMutableArray array];
    for(NSUInteger i = 0; i < secCount;i++){
        NSMutableArray *secArr = [NSMutableArray array];
        for(NSUInteger j = 0; j < secCount;j++){
            NSObject *model = [[NSObject alloc]init];
            [secArr addObject:model];
        }
        [datasArr addObject:secArr];
    }
    self.zxDatas = datasArr;
}
#pragma mark 假数据填充，单section
-(void)zx_fillWithRowCount:(NSUInteger)rowCount{
    NSMutableArray *datasArr = [NSMutableArray array];
    for(NSUInteger i = 0; i < rowCount;i++){
        NSObject *model = [[NSObject alloc]init];
        [datasArr addObject:model];
    }
    self.zxDatas = datasArr;
}

#pragma mark - 快速构建
#pragma mark 声明cell的类并返回cell对象
-(void)zx_setCellClassAtIndexPath:(Class (^)(NSIndexPath * indexPath)) setCellClassCallBack returnCell:(void (^)(NSIndexPath * indexPath,id cell,id model))returnCellCallBack{
    self.zx_setCellClassAtIndexPath = setCellClassCallBack;
    self.zx_getCellAtIndexPath = returnCellCallBack;
}

#pragma mark 声明HeaderView的类并返回HeaderView对象
-(void)zx_setHeaderClassInSection:(Class (^)(NSInteger)) setHeaderClassCallBack returnHeader:(void (^)(NSUInteger section,id headerView,NSMutableArray *secArr))returnHeaderCallBack{
    self.zx_setHeaderClassInSection = setHeaderClassCallBack;
    self.zx_getHeaderViewInSection = returnHeaderCallBack;
}

#pragma mark 声明FooterView的类并返回FooterView对象
-(void)zx_setFooterClassInSection:(Class (^)(NSInteger)) setFooterClassCallBack returnHeader:(void (^)(NSUInteger section,id headerView,NSMutableArray *secArr))returnFooterCallBack{
    self.zx_setFooterClassInSection = setFooterClassCallBack;
    self.zx_getFooterViewInSection = returnFooterCallBack;
}
#pragma mark - Private
#pragma mark 判断是否是多个section的情况
-(BOOL)isMultiDatas{
    return self.zxDatas.count && [[self.zxDatas objectAtIndex:0] isKindOfClass:[NSArray class]];
}
#pragma mark 获取对应indexPath的model
-(instancetype)getModelAtIndexPath:(NSIndexPath *)indexPath{
    id model = nil;;
    if([self isMultiDatas]){
        if(indexPath.section < self.zxDatas.count){
            NSArray *sectionArr = self.zxDatas[indexPath.section];
            if(indexPath.row < sectionArr.count){
                model = sectionArr[indexPath.row];
            }else{
                NSAssert(NO, [NSString stringWithFormat:@"数据源异常，请检查数据源！"]);
            }
        }else{
            NSAssert(NO, [NSString stringWithFormat:@"数据源异常，请检查数据源！"]);
        }
    }else{
        if(indexPath.row < self.zxDatas.count){
            model = self.zxDatas[indexPath.row];
        }else{
            NSAssert(NO, [NSString stringWithFormat:@"数据源异常，请检查数据源！"]);
        }
    }
    return model;
}

#pragma mark 判断对应类名的xib是否存在
-(BOOL)hasNib:(NSString *)clsName{
    return [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.nib",[[NSBundle mainBundle]resourcePath],clsName]];
}

#pragma mark 根据section获取headerView
-(UIView *)getHeaderViewInSection:(NSUInteger)section{
    Class headerClass = self.zx_setHeaderClassInSection(section);
    BOOL isExist = [self hasNib:NSStringFromClass(headerClass)];
    UIView *headerView = nil;
    if(isExist){
        headerView = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(headerClass) owner:nil options:nil]lastObject];
    }else{
        headerView = [[headerClass alloc]init];
    }
    return headerView;
}

#pragma mark 根据section获取footerView
-(UIView *)getFooterViewInSection:(NSUInteger)section{
    Class footerClass = self.zx_setFooterClassInSection(section);
    BOOL isExist = [self hasNib:NSStringFromClass(footerClass)];
    UIView *footerView = nil;
    if(isExist){
        footerView = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(footerClass) owner:nil options:nil]lastObject];
    }else{
        footerView = [[footerClass alloc]init];
    }
    return footerView;
}

#pragma mark zx_disableAutomaticDimension Setter
-(void)setZx_disableAutomaticDimension:(BOOL)zx_disableAutomaticDimension{
    _zx_disableAutomaticDimension = zx_disableAutomaticDimension;
    if(zx_disableAutomaticDimension){
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
    }
}

#pragma mark zxDatas Setter
-(void)setZxDatas:(NSMutableArray *)zxDatas{
    _zxDatas = zxDatas;
    if(zxDatas){
        NSAssert([_zxDatas isKindOfClass:[NSArray class]], @"zxDatas必须为数组");
    }
    [self reloadData];
}

#pragma mark ZXTableView默认初始化设置
-(void)privateSetZXTableView{
    self.zxDatas = [NSMutableArray array];
    self.delegate = self;
    self.dataSource = self;
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    
    self.separatorStyle = DefaultSeparatorStyle;
    self.zx_disableAutomaticDimension = DisableAutomaticDimension;
    self.zx_showHeaderWhenNoMsg = ShowHeaderWhenNoMsg;
    self.zx_showFooterWhenNoMsg = ShowFooterWhenNoMsg;
}
#pragma mark - 生命周期
-(instancetype)init{
    if (self = [super init]) {
        [self setZXTableView];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if(self = [super initWithFrame:frame style:style]){
        [self setZXTableView];
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setZXTableView];
}
-(void)dealloc{
    self.delegate = nil;
    self.dataSource = nil;
}
@end
