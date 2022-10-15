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
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
}

-(void)setIpaModel:(ZXIpaModel *)ipaModel{
    _ipaModel = ipaModel;
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:ipaModel.iconUrl] placeholderImage:[UIImage imageNamed:@"icon"]];
    if(ipaModel.version && ipaModel.version.length){
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  v%@ ", ipaModel.title,ipaModel.version] attributes:@{}];
        [attributeStr addAttributes:@{NSBackgroundColorAttributeName: MainColor,NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:12]} range:NSMakeRange(attributeStr.length - ipaModel.version.length - 3, ipaModel.version.length + 3)];
        [self.titleLabel setAttributedText:attributeStr];
    }else{
        self.titleLabel.text = ipaModel.title;
    }
    self.timeLabel.text = ipaModel.time;
}

@end
