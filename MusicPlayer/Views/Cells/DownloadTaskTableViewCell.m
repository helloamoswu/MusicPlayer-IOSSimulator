//
//  DownloadTaskTableViewCell.m
//  MusicPlayer
//
//  Created by amos on 15-4-7.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "DownloadTaskTableViewCell.h"

@implementation DownloadTaskTableViewCell

- (void)awakeFromNib {
    self.processBtn.layer.cornerRadius = self.processBtn.frame.size.height/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
