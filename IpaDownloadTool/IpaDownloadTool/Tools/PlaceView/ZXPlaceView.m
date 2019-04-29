//
//  ZXPlaceView.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXPlaceView.h"

@implementation ZXPlaceView
-(instancetype)initWithFrame:(CGRect)frame notice:(NSString *)notice{
    if(self = [super initWithFrame:frame]){
        UIImageView *iconImgV = [[UIImageView alloc]init];
        iconImgV.image = [UIImage imageNamed:@"icon"];
        CGFloat iconImgVW = 200;
        CGFloat iconImgVH = 120;
        CGFloat noticeLabelH = 20;
        CGFloat noticeLabelMargin = 20;
        iconImgV.frame = CGRectMake((frame.size.width - iconImgVW) / 2, 10, iconImgVW, iconImgVH);
        iconImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:iconImgV];
        
        UILabel *noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(noticeLabelMargin, CGRectGetMaxY(iconImgV.frame) + noticeLabelMargin, (frame.size.width - noticeLabelMargin * 2), noticeLabelH)];
        noticeLabel.font = [UIFont systemFontOfSize:13];
        noticeLabel.textColor = MainColor;
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        noticeLabel.text = notice;
        [self addSubview:noticeLabel];
        
    }
    return self;
}

+(instancetype)showWithNotice:(NSString *)notice superV:(UIView *)superView{
    ZXPlaceView *placeView = [[ZXPlaceView alloc]initWithFrame:CGRectMake(0, (superView.frame.size.height - 160 ) / 2, superView.frame.size.width, 200) notice:notice];
    [superView addSubview:placeView];
    return placeView;
}
@end
