//
//  ZXIpaAboutCell.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2022/10/16.
//  Copyright © 2022 李兆祥. All rights reserved.
//

#import "ZXIpaAboutCell.h"
@interface ZXIpaAboutCell()
@property (weak, nonatomic) IBOutlet UILabel *aboutTitleLabel;
@property (copy, nonatomic)NSString *titleModel;
@end
@implementation ZXIpaAboutCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.aboutTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
}

-(void)setTitleModel:(NSString *)titleModel{
    _titleModel = titleModel;
    self.aboutTitleLabel.text = titleModel;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
