//
//  DownloadTableViewCell.m
//  MusicPlayer
//
//  Created by amos on 15-4-3.
//  Copyright (c) 2015年 amos. All rights reserved.
//


#import "DownloadTableViewCell.h"

@implementation DownloadTableViewCell

- (void)awakeFromNib {
    [self.downloadBtn setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
    [self.downloadBtn setImage:[UIImage imageNamed:@"download_btn_h"] forState:UIControlStateHighlighted];
    [self.downloadBtn setImage:[UIImage imageNamed:@"download_btn_h"] forState:UIControlStateSelected];
    
    self.downloadBtn.layer.cornerRadius = self.downloadBtn.frame.size.height/2;
    [self.qualityBtn setBackgroundColor:[UIColor blackColor]];
    self.qualityBtn.layer.cornerRadius = self.qualityBtn.frame.size.height/2;
    [self.qualityBtn addTarget:self action:@selector(qualityClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createQualitySV
{
    if (self.qualitySV) {
        return;
    }
    self.qualitySV = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.qualitySV.backgroundColor = [UIColor blackColor];
    self.qualitySV.layer.cornerRadius = 5;
    self.qualitySV.hidden = YES;
    self.qualitySV.alpha = 0;
    [self addSubview:self.qualitySV];
    
    NSArray *qualities = nil;
    // 百度的音乐判断不了有哪些码率的歌曲是可用的，所以简单的给几个初始值
    if (!self.music.rateUrlDict) {
        qualities = @[@(128),@(192),@(256),@(320)];
    } else {
        qualities = [self.music.rateUrlDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            int rate1 = ((NSNumber *)obj1).intValue;
            int rate2 = ((NSNumber *)obj2).intValue;
            
            if (rate1 < rate2) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }];
    }
    
    float width = self.qualityBtn.frame.size.width + 5;
    for (int i = 0 ; i < qualities.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(i*width, 0, width, self.qualityBtn.frame.size.height)];
        NSNumber *rate = qualities[i];
        [btn setTitle:rate.stringValue forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn addTarget:self action:@selector(selectQuality:) forControlEvents:UIControlEventTouchUpInside];
        [self.qualitySV addSubview:btn];
    }
    
    CGRect frame = self.qualityBtn.frame;
    frame.size.width += 5;
    frame.size.width *= qualities.count;
    frame.origin.x -= (frame.size.width+5);
    self.qualitySV.frame = frame;
}

- (void)qualityClicked
{
    if (self.qualitySV.isHidden) {
        self.qualitySV.hidden = NO;
        CGRect frame = self.qualitySV.frame;
        CGRect oldFrame = frame;
        oldFrame.size.width = 0;
        oldFrame.origin.x = self.qualityBtn.frame.origin.x;
        self.qualitySV.frame = oldFrame;
        [UIView animateWithDuration:0.5 animations:^{
            self.qualitySV.alpha = 1;
            self.qualitySV.frame = frame;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.qualitySV.alpha = 0;
        } completion:^(BOOL finished) {
            self.qualitySV.hidden = YES;
        }];
    }
    
}

- (void)selectQuality:(UIButton *)sender
{
    NSString *quality = sender.titleLabel.text;
    [self.qualityBtn setTitle:quality forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.qualitySV.alpha = 0;
    } completion:^(BOOL finished) {
        self.qualitySV.hidden = YES;
    } ];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"QualityChanged" object:nil userInfo:@{@"cell":self, @"rate":@(quality.intValue)}];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void)layoutSubviews
{
    self.titleLabel.text = self.music.title;
    self.singerLabel.text = self.music.singer;
    
    [self createQualitySV];
}

@end
