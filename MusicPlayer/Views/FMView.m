//
//  FMView.m
//  MusicPlayer
//
//  Created by amos on 15-4-2.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "FMView.h"
#import "Utils.h"
#import "FMUtils.h"
#import "UIImageView+AFNetworking.h"
#import "OnlineMusic.h"
#import "FMManager.h"
#import "MPManager.h"
#import "AWAVPlayerItem.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface FMView () <UIScrollViewDelegate, FMManagerDelegate>

@property (nonatomic, strong)NSMutableArray *musics;
@property (nonatomic)int curChannel;
@property (nonatomic)BOOL isChannelChange;
// 当前播放歌曲的下标
@property (nonatomic)int curIndex;
@property (nonatomic)FMSource curSource;
@property (nonatomic, strong)FMManager *fmManager;
@property (nonatomic)int duration;

@property (nonatomic, strong)UIScrollView *channelSV;
@property (nonatomic, strong)UIButton *closeBtn;
@property (nonatomic, strong)UIButton *doubanBtn;
@property (nonatomic, strong)UIButton *baiduBtn;

@end

@implementation FMView

-(void)awakeFromNib
{
    [self initUI];
    
    self.fmManager = [FMManager shareManager];
    self.fmManager.delegate = self;
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playTimeChanged:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerItemFaildToReachEnd:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadPlayItemFailed:) name:@"LoadPlayItemFailed" object:nil];
}

- (void)initUI
{
    self.alpha = 0.8;
    self.albumIV.layer.cornerRadius = 5;
    self.albumIV.layer.borderWidth = 2;
    self.albumIV.layer.borderColor = [[UIColor grayColor] CGColor];
    self.albumIV.layer.masksToBounds = YES;
    
    [self createChannelView];
    
    CGFloat width = SCREEN_WIDTH/2;
    CGFloat height = self.frame.size.height;
    self.doubanBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.doubanBtn.frame = CGRectMake(0, 0, width, height);
    self.doubanBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    self.doubanBtn.layer.borderWidth = 1;
    [self.doubanBtn setTitle:@"豆瓣FM" forState:UIControlStateNormal];
    [self.doubanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doubanBtn setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.doubanBtn addTarget:self action:@selector(loadDoubanFM:) forControlEvents:UIControlEventTouchUpInside];
    
    self.baiduBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.baiduBtn.frame = CGRectMake(width, 0, width, height);
    self.baiduBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    self.baiduBtn.layer.borderWidth = 1;
    [self.baiduBtn setTitle:@"百度FM" forState:UIControlStateNormal];
    [self.baiduBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.baiduBtn setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.baiduBtn addTarget:self action:@selector(loadBaiduFM:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.doubanBtn];
    [self addSubview:self.baiduBtn];
}

- (void)createChannelView
{
    self.channelSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height)];
    self.channelSV.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    self.channelSV.scrollEnabled = YES;
    self.channelSV.hidden = YES;
    self.channelSV.alpha = 0;
    self.channelSV.delegate = self;
    [self addSubview:self.channelSV];
}

- (NSMutableArray *)musics
{
    if (!_musics) {
        _musics = [NSMutableArray array];
    }
    
    return _musics;
}

- (void)setCurChannel:(int)curChannel
{
    if (_curChannel != curChannel) {
        self.isChannelChange = YES;
    }
    
    _curChannel = curChannel;
}

- (void)updateChannelView
{
    for (UIView *subView in self.channelSV.subviews) {
        [subView removeFromSuperview];
    }
    NSArray *channels;
    switch (self.curSource) {
        case DOUBAN:
            channels = [FMUtils douBanChannels];
            break;
        case BAIDU:
            channels = [FMUtils baiDuChannels];
            break;
        default:
            break;
    }
    float width = (self.bounds.size.width - 30) / 4;
    float height = (self.bounds.size.height-15) / 2;
    int lineItemCount = (int)(channels.count+1)/2;
    for (int i = 0; i < channels.count; i++) {
        NSDictionary *chanDict = channels[i];
        UIButton *cBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [cBtn setTitle:chanDict[@"name"] forState:UIControlStateNormal];
        [cBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cBtn.frame = CGRectMake(i%lineItemCount * width + 5, i/lineItemCount * height + 10, width, height);
        cBtn.tag = [chanDict[@"type"] intValue];
        [cBtn addTarget:self action:@selector(changeChannelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.channelSV addSubview:cBtn];
    }
    self.closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 16, 0, 16, 16)];
    [self.closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(hideChannelSVClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.channelSV addSubview:self.closeBtn];
    
    self.channelSV.contentSize = CGSizeMake(( width + 5 ) * lineItemCount + 5, self.channelSV.frame.size.height);
}

- (void)updateUI
{
    OnlineMusic *m = self.fmManager.curPlayMusic;
    
    NSLog(@"fm: 播放 %@", m.title);
    
    [self.albumIV setImageWithURL:[NSURL URLWithString:m.albumUrl] placeholderImage:[UIImage imageNamed:@"album_placehoder"]];
    self.nameLabel.text = m.title;
    self.artistLabel.text = m.singer;
    self.duration = m.duration;
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", m.duration/60, m.duration%60];
    
    if (self.fmManager.isPlaying) {
        [self.playBtn setImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateNormal];
    } else {
        [self.playBtn setImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateNormal];
    }
}

- (void)loadDoubanFM:(UIButton *)sender
{
    self.curSource = DOUBAN;
    self.curChannel = DBOUMEI;
    [self requsetNewMusicsWithChannelId:self.curChannel];
    
    CGRect frame1 = self.doubanBtn.frame;
    frame1.size.width = 0;
    CGRect frame2 = self.baiduBtn.frame;
    frame2.origin.x = self.frame.size.width;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.doubanBtn.frame = frame1;
        self.baiduBtn.frame = frame2;
    } completion:^(BOOL finished) {
        [self.changeFMBtn setImage:[UIImage imageNamed:@"douban"] forState:UIControlStateNormal];
        self.channelLabel.text = @"欧美";
        [self updateChannelView];
    }];
}

- (void)loadBaiduFM:(UIButton *)sender
{
    self.curSource = BAIDU;
    self.curChannel = BDOUMEI;
    [self requsetNewMusicsWithChannelId:self.curChannel];
    
    CGRect frame1 = self.doubanBtn.frame;
    frame1.size.width = 0;
    CGRect frame2 = self.baiduBtn.frame;
    frame2.origin.x = self.frame.size.width;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.doubanBtn.frame = frame1;
        self.baiduBtn.frame = frame2;
    } completion:^(BOOL finished) {
        [self.changeFMBtn setImage:[UIImage imageNamed:@"baidu"] forState:UIControlStateNormal];
        self.channelLabel.text = @"欧美";
        [self updateChannelView];
    }];
}

- (void)requsetNewMusicsWithChannelId:(int)channel
{
    // 新的频道，清空以前的
    if (self.isChannelChange) {
        self.isChannelChange = NO;
        self.curIndex = 0;
        [self.musics removeAllObjects];
        [self.fmManager removeAllMusics];
    }
    
    switch (self.curSource) {
        case DOUBAN:
        {
            [FMUtils requestDuBanFMMusicsWithChannel:channel Completion:^(id obj) {
                NSArray *newMusics = obj;
                
                if (!newMusics || newMusics.count == 0) {
                    NSLog(@"douban:获取失败");
                    return ;
                }
                NSLog(@"douban:获得%d首歌", (int)newMusics.count);
                
                [self.musics addObjectsFromArray:newMusics];
                // 每次获取到9首歌，加载前3首到播放队列
                [self.fmManager addMusics:[self.musics subarrayWithRange:NSMakeRange(self.curIndex, 3)]];
                self.curIndex += 3;
            }];
        }
            break;
        case BAIDU:
        {
            [FMUtils requestBaiDuFMMusicsWithChannel:channel Completion:^(id obj) {
                NSArray *newMusics = obj;
                
                if (!newMusics || newMusics.count == 0) {
                    NSLog(@"baidu:获取失败");
                    return ;
                }
                NSLog(@"baidu:获得%d首歌", (int)newMusics.count);
                [self.musics addObjectsFromArray:newMusics];
                NSLog(@"baidu:当前有%d首歌", (int)newMusics.count);
                
                // 每次获取到9首歌，加载前3首到播放队列
                [self.fmManager addMusics:[self.musics subarrayWithRange:NSMakeRange(self.curIndex, 3)]];
                self.curIndex += 3;
            }];
        }
            break;
        default:
            break;
    }
    
}
#pragma mark FMManagerDelegate
- (void)readyToPlay
{
    [self updateUI];
}

// 收到歌曲播放完的通知
- (void)playerItemDidReachEnd:(NSNotification *)notif
{
    // 确保是AWAVPlayerItem发出的
    if (![notif.object isMemberOfClass:[AWAVPlayerItem class]]) {
        return;
    }
    // 把播放完的歌曲移除出歌曲列表
    AWAVPlayerItem *item = notif.object;
    [self.musics removeObject:item.music];
    self.curIndex--;
    
    NSLog(@"即将播放下一首歌");
    // 如果fm只剩下2首歌，包括当前播放完的但还没被销毁的，也就是说播放队列真正只剩下一首歌时，
    // 需要加载跟多的歌到播放队列中，这样才能保证连续播放时没有间隙
    if (self.fmManager.count == 2) {
        
        if (self.musics.count - self.curIndex < 3) {
            [self requsetNewMusicsWithChannelId:self.curChannel];
        } else {
            NSArray *moreMusics = [self.musics subarrayWithRange:NSMakeRange(self.curIndex, 3)];
            self.curIndex += 3;
            [self.fmManager addMusics:moreMusics];
        }
    }
}

- (void)playerItemFaildToReachEnd:(NSNotification *)notif
{
    NSLog(@"播放失败");
}

// 改变播放时间，有误差
- (void)playTimeChanged:(NSTimer *)timer
{
    if (self.fmManager.fmPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay && self.fmManager.isPlaying && self.fmManager.fmPlayer.rate) {
        if (self.duration <= 0) {
            return;
        }
        self.duration--;
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", self.duration/60, self.duration%60];
    }
}
// 隐藏频道
- (void)hideChannelSVClicked:(id)sender
{
    [UIView animateWithDuration:1 animations:^{
        self.channelSV.alpha = 0;
    } completion:^(BOOL finished) {
        self.channelSV.hidden = YES;
    }];
}
// 选择不同的频道，加载不同的歌曲
- (void)changeChannelClicked:(UIButton *)sender
{
    self.curChannel = (int)sender.tag;
    self.channelLabel.text = sender.titleLabel.text;
    [self requsetNewMusicsWithChannelId:self.curChannel];
}

// 更新关闭按钮的位置，使它一直处于右上角
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.closeBtn.frame;
    frame.origin.x = SCREEN_WIDTH - 16 + scrollView.contentOffset.x;
    self.closeBtn.frame = frame;
}

- (IBAction)playClicked:(UIButton *)sender {
    if (!self.fmManager.isPlaying) {
        [self.fmManager play];
        [sender setImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateNormal];
    } else {
        [self.fmManager pause];
        [sender setImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateNormal];
    }
}

- (IBAction)nextClicked:(UIButton *)sender {
    
    if (self.fmManager.count == 2) {
        if (self.musics.count - self.curIndex < 3) {
            [self requsetNewMusicsWithChannelId:self.curChannel];
        } else {
            NSArray *moreMusics = [self.musics subarrayWithRange:NSMakeRange(self.curIndex, 3)];
            self.curIndex += 3;
            [self.fmManager addMusics:moreMusics];
        }
    }
    [self.fmManager playNextSong];
}
// 隐藏/显示频道
- (IBAction)changeRadioClicked:(UIButton *)sender {
    self.channelSV.hidden = NO;
    [UIView animateWithDuration:1 animations:^{
        self.channelSV.alpha = 1;
    }];
}
// 切换电台
- (IBAction)changeFMClicked:(UIButton *)sender {
    if (self.curSource == DOUBAN) {
        self.curSource = BAIDU;
        [self.changeFMBtn setImage:[UIImage imageNamed:@"baidu"] forState:UIControlStateNormal];
    } else {
        self.curSource = DOUBAN;
        [self.changeFMBtn setImage:[UIImage imageNamed:@"douban"] forState:UIControlStateNormal];
    }
    
    [self updateChannelView];
}

// 收到歌曲加载失败的通知啦
- (void)loadPlayItemFailed:(NSNotification *)notif
{
    OnlineMusic *failedMusic = notif.object;
    // 赶紧移除出播放队列
    [self.musics removeObject:failedMusic];
    self.curIndex--;
    
    NSLog(@"fm failed:%@", failedMusic.title);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadPlayItemFailed" object:nil];
}

@end
