//
//  ZXIpaDetailCell.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXIpaDetailCell.h"
#import "ZXIpaDetailModel.h"
@interface ZXIpaDetailCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) ZXIpaDetailModel *detailModel;
@end
@implementation ZXIpaDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    //self.detailLabel.adjustsFontSizeToFitWidth = YES;
}

-(void)setDetailModel:(ZXIpaDetailModel *)detailModel{
    _detailModel = detailModel;
    self.titleLabel.text = detailModel.title;
    self.detailLabel.text = detailModel.detail;
}

@end
