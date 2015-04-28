//
//  MusicTableViewCell.m
//  MusicPlayer
//
//  Created by amos on 15-3-24.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "MusicTableViewCell.h"
#import "Utils.h"
#import "IpodManager.h"

@implementation MusicTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 添加歌曲名标签，宽度为歌曲名用一行显示时的宽度
    NSString *title = self.music.title;
    
    NSArray *artistAndTitle = [title componentsSeparatedByString:@" - "];
    if (artistAndTitle.count > 1) {
        title = [artistAndTitle lastObject];
    }
    
    int duration = self.music.duration.intValue;
    self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", duration/60, duration%60];
    self.albumIV.alpha = 0.4;
    self.titleLabel.text = title;
    self.singerLabel.text = self.music.artist;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image = nil;
        if ([self.music.path hasPrefix:@"ipod"]) {
            image = [[IpodManager shareManager] artworkImageWithPath:self.music.path];
        } else {
            image = [Utils artworkImageWithPath:self.music.path];
        }
        if (!image) {
            image = [Utils albumPlaceHolderImage];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.albumIV.image = image;
                        
            [UIView animateWithDuration:0.5 animations:^{
                self.albumIV.alpha = 1;
            }];
        });
    });

}

@end
