//
//  EqualizerView.m
//  MusicPlayer
//
//  Created by amos on 15-4-8.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "EqualizerView.h"
#import "MPManager.h"

@interface EqualizerView ()

@property (nonatomic, weak)MPManager *playerManager;
@property (nonatomic, strong)NSMutableArray *sliders;

@end

@implementation EqualizerView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createEqualizer];
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.7;
        self.playerManager = [MPManager shareManager];
    }
    
    return self;
}

- (void)createEqualizer
{
    self.sliders = [NSMutableArray array];
    for (int i = 0; i < 8; i++) {
        UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(10, 10, 200, 30)];
        slider.transform=CGAffineTransformRotate(slider.transform,90.0/180*M_PI);
        [slider setThumbImage:[UIImage imageNamed:@"thumb_white"] forState:UIControlStateNormal];
        CGRect frame = slider.frame;
        frame.origin.x = 5+i*30;
        frame.origin.y = 40;
        slider.frame = frame;
        
        
        slider.maximumValue = 20;
        slider.minimumValue = -20;
        slider.value = 0;
        slider.tag = i;
        
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:slider];
        [self.sliders addObject:slider];
        
        UILabel *topFreqLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x + 5, 0, 20, 20)];
        topFreqLabel.backgroundColor = [UIColor clearColor];
        NSString *formateStr = equalizerFreqs[i]>1000 ? @"%.fK" : @"%.f";
        topFreqLabel.text = [NSString stringWithFormat:formateStr, equalizerFreqs[i]>1000?equalizerFreqs[i]/1000:equalizerFreqs[i]];
        topFreqLabel.textAlignment = NSTextAlignmentCenter;
        topFreqLabel.textColor = [UIColor whiteColor];
        topFreqLabel.font = [UIFont systemFontOfSize:10];
        
        UILabel *topGainLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x + 5, 20, 20, 20)];
        topGainLabel.backgroundColor = [UIColor clearColor];
        topGainLabel.text = @"20";
        topGainLabel.textColor = [UIColor whiteColor];
        topGainLabel.textAlignment = NSTextAlignmentCenter;
        topGainLabel.font = [UIFont systemFontOfSize:12];
        
        UILabel *bottomGainLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x + 5, 240, 20, 20)];
        bottomGainLabel.backgroundColor = [UIColor clearColor];
        bottomGainLabel.text = @"-20";
        bottomGainLabel.textColor = [UIColor whiteColor];
        bottomGainLabel.textAlignment = NSTextAlignmentCenter;
        bottomGainLabel.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:topFreqLabel];
        [self addSubview:topGainLabel];
        [self addSubview:bottomGainLabel];
        
        UIButton *restoreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        restoreBtn.frame = CGRectMake(0, 260, 250, 20);
        [restoreBtn setTitle:@"恢复预设" forState:UIControlStateNormal];
        [restoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [restoreBtn setBackgroundColor:[UIColor blackColor]];
        restoreBtn.alpha = 0.8;
        
        [restoreBtn addTarget:self action:@selector(restoreEqualizerValue) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:restoreBtn];
    }
}

- (void)sliderValueChanged:(UISlider *)sender
{
    [self.playerManager.audioManager setGain:sender.value forEqualizerBand:(int)sender.tag];
}

- (void)restoreEqualizerValue
{
    for (int i = 0; i < 8; i++) {
        [self.playerManager.audioManager setGain:0 forEqualizerBand:i];
        UISlider *slider = self.sliders[i];
        [UIView animateWithDuration:1.5 animations:^{
            slider.value = 0;
        }];
        
    }
}

@end
