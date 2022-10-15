//
//  ZXLocalIpaDownloadCell.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/29.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXLocalIpaDownloadCell.h"
#import "ZXLocalIpaDownloadModel.h"
@interface ZXLocalIpaDownloadCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) ZXLocalIpaDownloadModel *downloadModel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@end
@implementation ZXLocalIpaDownloadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.progressView.tintColor = MainColor;
    self.progressView.backgroundColor = [UIColor clearColor];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.statusLabel.adjustsFontSizeToFitWidth = YES;
}

-(void)setDownloadModel:(ZXLocalIpaDownloadModel *)downloadModel{
    _downloadModel = downloadModel;
    self.progressView.hidden = YES;
    self.titleLabel.text = downloadModel.title;
    self.statusLabel.textColor = [UIColor colorWithRed:21/255.0 green:126/255.0 blue:255/255.0 alpha:1];
    self.sizeLabel.text = [NSString stringWithFormat:@"%.2lfM",downloadModel.totalBytesExpectedToWrite / 1024 / 1024.0];
    if(downloadModel.isFinish){
        if(downloadModel.totalBytesExpectedToWrite){
            self.statusLabel.text = @"已完成";
        }else{
            self.statusLabel.textColor = [UIColor redColor];
            self.statusLabel.text = @"下载失败，链接可能已过期，请重新生成";
        }
    }else{
        self.statusLabel.text = [NSString stringWithFormat:@"%.2lfM/%.2lfM",downloadModel.totalBytesWritten / 1024 / 1024.0,downloadModel.totalBytesExpectedToWrite / 1024 / 1024.0];
        if(downloadModel.totalBytesExpectedToWrite){
            self.progressView.hidden = NO;
            self.progressView.progress = downloadModel.totalBytesWritten / (downloadModel.totalBytesExpectedToWrite * 1.0);
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
