//
//  VolumeSlider.m
//  MusicPlayer
//
//  Created by amos on 15-4-8.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "VolumeSlider.h"

@implementation VolumeSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:1 animations:^{
        self.label.alpha = 0;
    }];
}

@end
