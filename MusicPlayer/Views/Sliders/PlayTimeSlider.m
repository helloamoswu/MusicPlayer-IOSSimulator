//
//  PlayTimeSlider.m
//  MusicPlayer
//
//  Created by amos on 15-4-8.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "PlayTimeSlider.h"
#import "MPManager.h"

@interface PlayTimeSlider ()

@property (nonatomic, strong)MPManager *playerManager;

@end

@implementation PlayTimeSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.playerManager = [MPManager shareManager];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.active = YES;
    [super touchesBegan:touches withEvent:event];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.playerManager.currentTime = self.value;
    self.active = NO;
}

@end
