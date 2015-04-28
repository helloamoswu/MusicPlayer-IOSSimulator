//
//  PlayView.m
//  MusicPlayer
//
//  Created by amos on 15-4-1.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "PlayView.h"
#import "Utils.h"
#import "PlayTimeSlider.h"
#import "FMManager.h"
#import "Music.h"
#import "UserDataUtils.h"

@interface PlayView () 

@property (weak, nonatomic) IBOutlet UIButton *prevBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet PlayTimeSlider *playTimeSlider;
@property (weak, nonatomic) IBOutlet UIButton *albumBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) MPManager *playerManager;

@end

@implementation PlayView

- (void)awakeFromNib
{
    self.alpha = 0.8;
    self.playerManager = [MPManager shareManager];
    [self.playTimeSlider setThumbImage:[UIImage imageNamed:@"thumb_white"] forState:UIControlStateNormal];
    
    self.playBtn.layer.cornerRadius = self.playBtn.bounds.size.width/2;
    self.playBtn.layer.borderWidth = 2;
    self.playBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.playBtn.layer.masksToBounds = YES;
    
    self.albumBtn.layer.cornerRadius = 5;
    self.albumBtn.layer.borderWidth = 2;
    self.albumBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    self.albumBtn.layer.masksToBounds = YES;
    
    [self updateMusicUI];
    
    [NSTimer scheduledTimerWithTimeInterval:0.08 target:self selector:@selector(playTImeChanged) userInfo:nil repeats:YES];
}

- (void)playTImeChanged
{
    if (!self.playTimeSlider.active) {
        self.playTimeSlider.value = self.playerManager.currentTime;
    }
    
    self.playBtn.transform = CGAffineTransformRotate(self.playBtn.transform, 0.03);
    
}
- (IBAction)playTImeSliderChanged:(UISlider *)sender {
}

- (IBAction)playClicked:(UIButton *)sender {
    
    FMManager *fmManager = [FMManager shareManager];
    if (fmManager.fmPlayer) {
        [fmManager.fmPlayer pause];
    }
    
    switch (sender.tag) {
            // 播放／暂停
        case 0:
        {
            if (self.playerManager.isPlaying == NO) {
                [self.playerManager play];
                
                [self.playBtn setImage:[Utils pauseImage] forState:UIControlStateNormal];
                
            } else {
                [self.playerManager pause];
                
                [self.playBtn setImage:[Utils playImage] forState:UIControlStateNormal];
            }
        }
            break;
            // 上一曲
        case 1:
        {
            [self.playBtn setImage:[Utils pauseImage] forState:UIControlStateNormal];
            NSInteger mode = [UserDataUtils CurrentMode];
            if (mode == 2) {
                [self.playerManager randomMusic];
            } else {
                [self.playerManager prevMusic];
            }
        }
            break;
            // 下一曲
        case 2:
        {
            [self.playBtn setImage:[Utils pauseImage] forState:UIControlStateNormal];
            NSInteger mode = [UserDataUtils CurrentMode];
            if (mode == 2) {
                [self.playerManager randomMusic];
            } else {
                [self.playerManager nextMusic];
            }
        }
            break;
        default:
            break;
    }
}

- (void)updateMusicUI
{
    self.playTimeSlider.maximumValue = self.playerManager.duration;
    
    if (self.playerManager.isPlaying) {
        [self.playBtn setImage:[Utils pauseImage] forState:UIControlStateNormal];
    } else {
        [self.playBtn setImage:[Utils playImage] forState:UIControlStateNormal];
    }
    
    Music *curMusic = self.playerManager.curMusic;
    
    UIImage *image = nil;
    if (self.playerManager.isIpodMusic) {
        image = self.playerManager.ipodArtworkImage;
    } else {
        image = [Utils artworkImageWithPath:curMusic.path];
    }
    if (image) {
        [self.albumBtn setImage:image forState:UIControlStateNormal];
    } else {
        [self.albumBtn setImage:[Utils albumPlaceHolderImage] forState:UIControlStateNormal];
    }
    
    self.playTimeSlider.maximumValue = self.playerManager.duration;
    self.playTimeSlider.value = self.playerManager.currentTime;
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ - %@",curMusic.artist ,curMusic.title];
}

#pragma mark - MPManager Delegate

- (void)didStartPlaying
{
    [self updateMusicUI];
}


@end
