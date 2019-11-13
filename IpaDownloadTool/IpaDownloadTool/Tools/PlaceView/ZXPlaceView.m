//
//  ZXPlaceView.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXPlaceView.h"
@interface ZXPlaceView()
@property (weak, nonatomic) UIImageView *iconImgV;
@property (weak, nonatomic) UILabel *noticeLabel;
@end
@implementation ZXPlaceView
-(instancetype)initWithFrame:(CGRect)frame notice:(NSString *)notice{
    if(self = [super initWithFrame:frame]){
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
        UIImageView *iconImgV = [[UIImageView alloc]init];
        iconImgV.image = [UIImage imageNamed:@"icon"];
        iconImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:iconImgV];
        self.iconImgV = iconImgV;
        
        UILabel *noticeLabel = [[UILabel alloc]init];
        noticeLabel.font = [UIFont systemFontOfSize:13];
        noticeLabel.textColor = MainColor;
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        noticeLabel.text = notice;
        [self addSubview:noticeLabel];
        self.noticeLabel = noticeLabel;
        
        [self refSubViews];
        
    }
    return self;
}

+(instancetype)showWithNotice:(NSString *)notice superV:(UIView *)superView{
    ZXPlaceView *placeView = [[ZXPlaceView alloc]initWithFrame:CGRectMake(0, (superView.frame.size.height - 160 ) / 2, superView.frame.size.width, 200) notice:notice];
    [superView addSubview:placeView];
    return placeView;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.frame = CGRectMake(0, (self.superview.frame.size.height - 160 ) / 2, self.superview.frame.size.width, 200);
    [self refSubViews];
    
}

-(void)refSubViews{
    CGFloat iconImgVW = 200;
    CGFloat iconImgVH = 120;
    CGFloat noticeLabelH = 20;
    CGFloat noticeLabelMargin = 20;
    self.iconImgV.frame = CGRectMake((self.frame.size.width - iconImgVW) / 2, 10, iconImgVW, iconImgVH);
    self.noticeLabel.frame = CGRectMake(noticeLabelMargin, CGRectGetMaxY(self.iconImgV.frame) + noticeLabelMargin, (self.frame.size.width - noticeLabelMargin * 2), noticeLabelH);
}
@end
