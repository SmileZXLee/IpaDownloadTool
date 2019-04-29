//
//  ZXIpaHisCell.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXIpaHisCell.h"
#import "ZXIpaModel.h"
#import "UIImageView+WebCache.h"
@interface ZXIpaHisCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic)ZXIpaModel *ipaModel;
@end
@implementation ZXIpaHisCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.iconImgV.clipsToBounds = YES;
    self.iconImgV.layer.cornerRadius = 8;
}

-(void)setIpaModel:(ZXIpaModel *)ipaModel{
    _ipaModel = ipaModel;
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:ipaModel.iconUrl] placeholderImage:[UIImage imageNamed:@"icon"]];
    self.titleLabel.text = ipaModel.title;
    self.timeLabel.text = ipaModel.time;
}

@end
