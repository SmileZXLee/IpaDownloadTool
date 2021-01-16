//
//  ZXIpaUrlHisCell.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2021/1/16.
//  Copyright © 2021 李兆祥. All rights reserved.
//

#import "ZXIpaUrlHisCell.h"
#import "ZXIpaUrlHisModel.h"
#import "UIImageView+WebCache.h"
@interface ZXIpaUrlHisCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (strong, nonatomic)ZXIpaUrlHisModel *hisModel;
@end
@implementation ZXIpaUrlHisCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.iconImgV.clipsToBounds = YES;
    self.iconImgV.layer.cornerRadius = 8;
}

- (void)setHisModel:(ZXIpaUrlHisModel *)hisModel{
    _hisModel = hisModel;
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:hisModel.favicon] placeholderImage:[UIImage imageNamed:@"icon"]];
    self.titleLabel.text = hisModel.title;
    self.urlLabel.text = hisModel.urlStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
