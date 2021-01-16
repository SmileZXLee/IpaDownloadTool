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
#import "UIView+ZXTbGetResponder.h"
@interface ZXTableView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)NSMutableDictionary *zx_headerViewCacheDic;
@property(nonatomic, strong)NSMutableDictionary *zx_footerViewCacheDic;
@end
@implementation ZXTableView
#pragma mark - Perference
#pragma mark 设置ZXTableView，此设置会应用到全部的ZXTableView中
-(void)setZXTableView{
    [self privateSetZXTableView];
    [self zx_setTableView];
}
#pragma mark ZXTableView的cell，此设置会应用到全部的ZXTableView的cell中
-(void)zx_setCell:(UITableViewCell *)cell{
    if(self.zx_makeAllCellSelectionStyleNone){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

#pragma mark ZXTableView的cell，此设置会应用到全部的ZXTableView的cell中
-(void)zx_setTableView{
    
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
        }else{
            if(self.zx_cellClassName.length){
                className = self.zx_cellClassName;
            }
        }
        BOOL isExist = [self hasNib:className];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:className];
        if(!cell){
            if(isExist){
                cell = [[[NSBundle mainBundle]loadNibNamed:className owner:nil options:nil]lastObject];
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
            [cell zx_safeSetValue:indexPath forKey:INDEX];
            [model zx_safeSetValue:indexPath forKey:INDEX];
            [cell setValue:indexPath forKey:@"zx_indexPathInTableView"];
            [model setValue:indexPath forKey:@"zx_indexPathInTableView"];
            [cell setValue:[NSNumber numberWithInteger:indexPath.section] forKey:@"zx_sectionInTableView"];
            [model setValue:[NSNumber numberWithInteger:indexPath.section] forKey:@"zx_sectionInTableView"];
            CGFloat cellH = ((UITableViewCell *)cell).frame.size.height;
            if(cellH && ![[model zx_safeValueForKey:CELLH] floatValue]){
                if([model respondsToSelector:NSSelectorFromString(CELLH)]){
                    [model zx_safeSetValue:[NSNumber numberWithFloat:cellH] forKey:CELLH];
                }else{
                    [model setValue:[NSNumber numberWithFloat:cellH] forKey:@"zx_cellHRunTime"];
                }
                
            }
            if(!self.zx_fixCellBlockAfterAutoSetModel){
                !self.zx_getCellAtIndexPath ? : self.zx_getCellAtIndexPath(indexPath,cell,model);
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
        }else{
            if(!self.zx_fixCellBlockAfterAutoSetModel){
                !self.zx_getCellAtIndexPath ? : self.zx_getCellAtIndexPath(indexPath,cell,model);
            }
        }
        if(self.zx_fixCellBlockAfterAutoSetModel){
            !self.zx_getCellAtIndexPath ? : self.zx_getCellAtIndexPath(indexPath,cell,model);
        }
        [self zx_setCell:cell];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if([self.zxDataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]){
        return [self.zxDataSource tableView:tableView titleForHeaderInSection:section];
    }else{
        if(self.zx_setTitleForHeaderInSection){
            return self.zx_setTitleForHeaderInSection(section);
        }
        return nil;
    }
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if([self.zxDataSource respondsToSelector:@selector(sectionIndexTitlesForTableView:)]){
        return [self.zxDataSource sectionIndexTitlesForTableView:tableView];
    }else{
        if(self.zx_setSectionIndexTitlesForTableView){
            return self.zx_setSectionIndexTitlesForTableView(tableView);
        }
        return nil;
    }
}

#pragma mark 返回索引对应的section
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    if([self.zxDataSource respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)]){
        return [self.zxDataSource tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
    }else{
        if(self.zx_setSectionForSectionIndex){
            return self.zx_setSectionForSectionIndex(title,index);
        }
        return 0;
    }
}

#pragma mark - UITableViewDelegate
#pragma mark tableView 选中某一indexPath
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.zx_autoDeselectWhenSelected){
        [self deselectRowAtIndexPath:indexPath animated:YES];
    }
    id model = [self getModelAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([self.zxDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
        [self.zxDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }else{
        !self.zx_didSelectedAtIndexPath ? : self.zx_didSelectedAtIndexPath(indexPath,model,cell);
    }
    if(self.zx_autoPushConfigDictionary){
        [self handleDidSelectedAtIndexPath:indexPath model:model cell:cell];
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
                    return [[model valueForKey:@"zx_cellHRunTime"] floatValue];
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
    if([self.zxDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]){
        [self.zxDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }else{
        !self.zx_willDisplayCell ? : self.zx_willDisplayCell(indexPath,cell);
    }
    
}
#pragma mark tableView cell 已经展示
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    if([self.zxDelegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]){
        [self.zxDelegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }else{
        !self.zx_didEndDisplayingCell ? : self.zx_didEndDisplayingCell(indexPath,cell);
    }
    
}
#pragma mark tableView HeaderView & FooterView
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = nil;
    if([self.zxDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]){
        headerView = [self.zxDelegate tableView:tableView viewForHeaderInSection:section];
        
    }else{
        if(self.zx_setHeaderClassInSection || self.zx_headerClassName.length){
            headerView = [self getHeaderViewInSection:section];
            
        }else{
            if(self.zx_setHeaderViewInSection){
                headerView = self.zx_setHeaderViewInSection(section);
            }
        }
    }
    NSMutableArray *secArr = self.zxDatas.count ? [self isMultiDatas] ? self.zxDatas[section] : self.zxDatas : nil;
    !self.zx_getHeaderViewInSection ? : self.zx_getHeaderViewInSection(section,headerView,secArr);
    [headerView zx_safeSetValue:[NSNumber numberWithInteger:section] forKey:SECTION];
    [headerView setValue:[NSNumber numberWithInteger:section] forKey:@"zx_sectionInTableView"];
    return !secArr.count ? self.zx_showHeaderWhenNoMsg ? headerView : nil : headerView;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = nil;
    if([self.zxDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]){
        footerView = [self.zxDelegate tableView:tableView viewForFooterInSection:section];
        
    }else{
        if(self.zx_setFooterClassInSection || self.zx_footerClassName.length){
            footerView = [self getFooterViewInSection:section];
            
        }else{
            if(self.zx_setFooterViewInSection){
                footerView = self.zx_setFooterViewInSection(section);
            }
        }
    }
    NSMutableArray *secArr = self.zxDatas.count ? [self isMultiDatas] ? self.zxDatas[section] : self.zxDatas : nil;
    !self.zx_getFooterViewInSection ? : self.zx_getFooterViewInSection(section,footerView,secArr);
    [footerView zx_safeSetValue:[NSNumber numberWithInteger:section] forKey:SECTION];
    [footerView setValue:[NSNumber numberWithInteger:section] forKey:@"zx_sectionInTableView"];
    return !secArr.count ? self.zx_showFooterWhenNoMsg ? footerView : nil : footerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]){
        return [self.zxDelegate tableView:tableView heightForHeaderInSection:section];
        
    }else{
        if(self.zx_setHeaderClassInSection || self.zx_headerClassName.length){
            if(self.zx_setHeaderHInSection){
                if(section < self.zxDatas.count || (self.zx_showHeaderWhenNoMsg &&  section == 0)){
                    return self.zx_setHeaderHInSection(section);
                }else{
                    return CGFLOAT_MIN;
                }
            }else{
                if(section < self.zxDatas.count || (self.zx_showHeaderWhenNoMsg &&  section == 0)){
                    UIView *headerView = [self getHeaderViewInSection:section];
                    return headerView ? headerView.frame.size.height : CGFLOAT_MIN;
                }else{
                    return CGFLOAT_MIN;
                }
            }
        }else{
            if(self.zx_setHeaderHInSection){
                return self.zx_showHeaderWhenNoMsg ? self.zx_setHeaderHInSection(section) : CGFLOAT_MIN;
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
        if(self.zx_setFooterClassInSection || self.zx_footerClassName.length){
            if(self.zx_setFooterHInSection){
                if(section < self.zxDatas.count || (self.zx_showFooterWhenNoMsg &&  section == 0)){
                    return self.zx_setFooterHInSection(section);
                }else{
                    return CGFLOAT_MIN;
                }
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
                return self.zx_showFooterWhenNoMsg ? self.zx_setFooterHInSection(section) : CGFLOAT_MIN;
            }else{
                return CGFLOAT_MIN;
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)]){
        [self.zxDelegate tableView:tableView willDisplayHeaderView:view forSection:section];
    }else{
        !self.zx_willDisplayHeaderView ? : self.zx_willDisplayHeaderView(section,view);
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]){
        [self.zxDelegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }else{
        !self.zx_didEndDisplayingHeaderView ? : self.zx_didEndDisplayingHeaderView(section,view);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]){
        [self.zxDelegate tableView:tableView willDisplayFooterView:view forSection:section];
    }else{
        !self.zx_willDisplayFooterView ? : self.zx_willDisplayFooterView(section,view);
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section{
    if([self.zxDelegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]){
        [self.zxDelegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }else{
        !self.zx_didEndDisplayingFooterView ? : self.zx_didEndDisplayingFooterView(section,view);
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
    NSString *sectionStr = [NSString stringWithFormat:@"%lu",section];
    if(self.zx_keepStaticHeaderView && [self.zx_headerViewCacheDic.allKeys containsObject:sectionStr]){
        return self.zx_headerViewCacheDic[sectionStr];
    }
    Class headerClass = [self getHeaderClassInSection:section];
    if(!headerClass){
        return nil;
    }
    BOOL isExist = [self hasNib:NSStringFromClass(headerClass)];
    UIView *headerView = nil;
    if(isExist){
        headerView = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(headerClass) owner:nil options:nil]lastObject];
    }else{
        headerView = [[headerClass alloc]init];
    }
    if(self.zx_keepStaticHeaderView && headerView){
        [self.zx_headerViewCacheDic setObject:headerView forKey:sectionStr];
    }
    return headerView;
}

#pragma mark 根据section获取headerView的class
- (Class)getHeaderClassInSection:(NSUInteger)section{
    if(self.zx_setHeaderClassInSection){
        return self.zx_setHeaderClassInSection(section);
    }
    if(self.zx_headerClassName.length){
        return NSClassFromString(self.zx_headerClassName);
    }
    return nil;
}

#pragma mark 根据section获取footerView
-(UIView *)getFooterViewInSection:(NSUInteger)section{
    NSString *sectionStr = [NSString stringWithFormat:@"%lu",section];
    if(self.zx_keepStaticFooterView && [self.zx_footerViewCacheDic.allKeys containsObject:sectionStr]){
        return self.zx_footerViewCacheDic[sectionStr];
    }
    Class footerClass = [self getFooterClassInSection:section];
    if(!footerClass){
        return nil;
    }
    BOOL isExist = [self hasNib:NSStringFromClass(footerClass)];
    UIView *footerView = nil;
    if(isExist){
        footerView = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(footerClass) owner:nil options:nil]lastObject];
    }else{
        footerView = [[footerClass alloc]init];
    }
    if(self.zx_keepStaticFooterView && footerView){
        [self.zx_footerViewCacheDic setObject:footerView forKey:sectionStr];
    }
    return footerView;
}

#pragma mark 根据section获取footerView的class
- (Class)getFooterClassInSection:(NSUInteger)section{
    if(self.zx_setFooterClassInSection){
        return self.zx_setFooterClassInSection(section);
    }
    if(self.zx_footerClassName.length){
        return NSClassFromString(self.zx_footerClassName);
    }
    return nil;
}

#pragma mark 获取当前tableView所在的导航控制器
- (UINavigationController *)getCurrentNavigationController{
    return [self zx_getResponderWithClass:[UINavigationController class]];
}

#pragma mark 根据zx_autoPushConfigDictionary设置控制器Push及参数
- (void)handleDidSelectedAtIndexPath:(NSIndexPath *)indexPath model:(id)model cell:(UITableViewCell *)cell{
    if(self.zx_autoPushConfigDictionary){
        NSMutableDictionary *muAutoPushConfigDictionary = [self.zx_autoPushConfigDictionary mutableCopy];
        [self.zx_autoPushConfigDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if([key isKindOfClass:[NSString class]]){
                NSString *lowercaseKey = [key lowercaseString];
                if([lowercaseKey isEqualToString:AutoPushConfigPushVCKey]){
                    [muAutoPushConfigDictionary setObject:obj forKey:lowercaseKey];
                    *(stop) = YES;
                }
            }
        }];
        id vcValue = nil;
        if([muAutoPushConfigDictionary.allKeys containsObject:AutoPushConfigPushVCKey]){
            vcValue = [muAutoPushConfigDictionary valueForKey:AutoPushConfigPushVCKey];
        }else{
            NSString *desc = [NSString stringWithFormat:@"您必须设置key为%@的value，若不需要自动跳转功能，请勿给zx_autoPushConfigDictionary赋值！",AutoPushConfigPushVCKey];
            NSAssert(NO, desc);
            return;
        }
        UINavigationController *currentNav = [self getCurrentNavigationController];
        if(currentNav){
            id vcObj = [self getObjFromUnknowValue:vcValue];
            if(vcObj){
                [muAutoPushConfigDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if(![key isEqualToString:AutoPushConfigPushVCKey]){
                        id value = nil;
                        if([obj isKindOfClass:[NSString class]]){
                            obj = [obj lowercaseString];
                            NSArray *comapreKeyArr = @[AutoPushConfigModelValueKey,AutoPushConfigIndexPathValueKey,AutoPushConfigCellValueKey];
                            for (NSString *comapreKey in comapreKeyArr) {
                                value = [self getAutoPushConfigDictionaryAttrValueWithValueKey:obj compareValueKey:comapreKey model:model indexPath:indexPath cell:cell];
                                if(value)break;
                            }
                            
                        }else{
                            value = obj;
                        }
                        if(value){
                            [vcObj setValue:value forKeyPath:key];
                        }
                    }
                }];
                [[self getCurrentNavigationController] pushViewController:vcObj animated:YES];
            }
        }
        
    }
}

#pragma mark 根据unknowValue类型获取其对象
- (id)getObjFromUnknowValue:(id)unknowValue{
    if([unknowValue isKindOfClass:[NSString class]]){
        return [NSClassFromString(unknowValue) new];
    }
    if([unknowValue respondsToSelector:@selector(new)]){
        return [unknowValue new];
    }
    if([unknowValue isKindOfClass:[NSObject class]]){
        return unknowValue;
    }
    return nil;
}

#pragma mark 获取AutoPushConfigDictionary所匹配的value值
- (id)getAutoPushConfigDictionaryAttrValueWithValueKey:(NSString *)valueKey compareValueKey:(NSString *)compareValueKey model:(id)model indexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell{
    id value = nil;
    id targerValue = nil;
    if([compareValueKey isEqualToString:AutoPushConfigIndexPathValueKey]){
        targerValue = indexPath;
    }else if([compareValueKey isEqualToString:AutoPushConfigModelValueKey]){
        targerValue = model;
    }else if([compareValueKey isEqualToString:AutoPushConfigCellValueKey]){
        targerValue = cell;
    }
    NSString *compareValueKeyAddition = [NSString stringWithFormat:@"%@.",compareValueKey];
    if([valueKey hasPrefix:compareValueKeyAddition] || [valueKey isEqualToString:compareValueKey]){
        if([valueKey isEqualToString:compareValueKey]){
            value = targerValue;
        }else{
            if(targerValue){
                value = [targerValue valueForKeyPath:[valueKey substringFromIndex:compareValueKeyAddition.length]];
            }
        }
    }
    return value;
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
    self.zx_keepStaticHeaderView = KeepStaticHeaderView;
    self.zx_keepStaticFooterView = KeepStaticFooterView;
    self.zx_fixCellBlockAfterAutoSetModel = FixCellBlockAfterAutoSetModel;
    self.zx_autoDeselectWhenSelected = AutoDeselectWhenSelected;
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
#pragma mark - Private
#pragma mark 重写reload方法
-(void)reloadData{
    if(!self.zx_keepStaticHeaderView){
        [self.zx_headerViewCacheDic removeAllObjects];
    }
    if(!self.zx_keepStaticFooterView){
        [self.zx_footerViewCacheDic removeAllObjects];
    }
    [super reloadData];
}
#pragma mark - 懒加载
-(NSMutableDictionary *)zx_headerViewCacheDic{
    if(!_zx_headerViewCacheDic){
        _zx_headerViewCacheDic = [NSMutableDictionary dictionary];
    }
    return _zx_headerViewCacheDic;
}

-(NSMutableDictionary *)zx_footerViewCacheDic{
    if(!_zx_footerViewCacheDic){
        _zx_footerViewCacheDic = [NSMutableDictionary dictionary];
    }
    return _zx_footerViewCacheDic;
}

@end
