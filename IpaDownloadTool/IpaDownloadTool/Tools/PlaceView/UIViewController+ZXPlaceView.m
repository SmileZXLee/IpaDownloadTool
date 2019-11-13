//
//  UIViewController+ZXPlaceView.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/5/24.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "UIViewController+ZXPlaceView.h"
#import <objc/runtime.h>
static NSString *placeViewKey = @"placeViewKey";
@implementation UIViewController (ZXPlaceView)

-(void)showPlaceViewWithText:(NSString *)text{
    if(self.placeView){
        [self.placeView removeFromSuperview];
    }
    ZXPlaceView *placeView = [ZXPlaceView showWithNotice:text superV:self.view];
    self.placeView = placeView;
}

-(void)removePlaceView{
    if(self.placeView){
        [self.placeView removeFromSuperview];
        self.placeView = nil;
    }
}


#pragma mark - Getter & Setter
-(void)setPlaceView:(ZXPlaceView *)placeView{
    objc_setAssociatedObject(self, &placeViewKey, placeView, OBJC_ASSOCIATION_ASSIGN);
}

-(ZXPlaceView *)placeView{
    return objc_getAssociatedObject(self, &placeViewKey);
}
@end
