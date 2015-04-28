//
//  ScrolleTableViewCell.m
//  MusicPlayer
//
//  Created by amos on 15-3-31.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "ScrolleTableViewCell.h"

@implementation ScrolleTableViewCell

- (void)awakeFromNib {
    
    self.frame = CGRectMake(0, 0, 280, 30);
    CGRect frame = self.frame;
    frame.origin.x += 10;
    self.bgScrollView.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.lrcLabel.text = self.lrc;
    self.lrcLabel.textColor = [UIColor whiteColor];
    
    CGRect rect = [self.lrc boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17] } context: nil];
    self.bgScrollView.contentSize = CGSizeMake(rect.size.width, self.bgScrollView.bounds.size.height);
    self.lrcLabel.frame = CGRectMake(0, 0, rect.size.width, self.lrcLabel.frame.size.height);
}



@end
