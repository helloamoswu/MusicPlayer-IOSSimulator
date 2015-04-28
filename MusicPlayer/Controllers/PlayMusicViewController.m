//
//  PlayMusicViewController.m
//  TMusic
//
//  Created by amos on 15-3-20.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "PlayMusicViewController.h"
#import "Utils.h"
#import "Lrc.h"
#import "Music.h"
#import "VolumeSlider.h"
#import "PlayTimeSlider.h"
#import "ScrolleTableViewCell.h"
#import "EqualizerView.h"
#import "MPManager.h"
#import "FMManager.h"
#import "UserDataUtils.h"

#define FPS 1/30.0

@interface PlayMusicViewController () <UITableViewDataSource,UITableViewDelegate,
                                        MPManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet PlayTimeSlider *playTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *volumLabel;
@property (weak, nonatomic) IBOutlet VolumeSlider *volumSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UIImageView *artworkIV;
@property (weak, nonatomic) IBOutlet UISegmentedControl *playModeSC;
@property (weak, nonatomic)IBOutlet UITableView *lrcTableView;
@property (weak, nonatomic) IBOutlet UIButton *loveButton;
@property (weak, nonatomic) IBOutlet UIButton *eqButton;

@property (nonatomic, strong)UIImageView *bgView;
@property (nonatomic, strong)EqualizerView *equalizerView;

@property (nonatomic, strong)NSArray *lrcs;

@property (nonatomic, strong)MPManager *playerManager;

@property (nonatomic, strong)NSUserDefaults *ud;
@property (nonatomic, strong)NSMutableArray *timers;

@property (nonatomic, strong)UIImageView *cover;

@end

@implementation PlayMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ud = [NSUserDefaults standardUserDefaults];
    
    self.playerManager = [MPManager shareManager];
    
    [self setTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 更新代理源
    self.playerManager.delegate = self;
    
    // 添加cover, 遮丑用
    self.cover = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%02d.jpg", arc4random_uniform(9)]]];
    self.cover.frame = self.view.frame;
    [self.tabBarController.view addSubview:self.cover];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 只能再这更新UI了，好像只有这里constrains才生效，闪屏啊，蛋疼啊,只能伪装起来了
    [self setupUI];
    [self updateMusicUI];
    // UI更新完毕，赶紧移除
    [UIView animateWithDuration:0.5 animations:^{
        self.cover.alpha = 0;
    } completion:^(BOOL finished) {
        [self.cover removeFromSuperview];
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.bgView removeFromSuperview];
    
    // 清除计时器，才能够释放掉这个页面
    for (NSTimer *timer in self.timers) {
        [timer invalidate];
    }
    
}

- (NSMutableArray *)timers
{
    if (!_timers) {
        _timers = [NSMutableArray array];
    }
    
    return _timers;
}

- (void)setupUI
{
    self.lrcTableView.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.6] CGColor];
    self.lrcTableView.layer.borderWidth = 3;
    self.lrcTableView.layer.cornerRadius = 20;
    
    self.artworkIV.layer.borderColor = [[UIColor colorWithWhite:0 alpha:0.6] CGColor];
    self.artworkIV.layer.borderWidth = 3;
    self.artworkIV.layer.cornerRadius = self.artworkIV.bounds.size.width/2;
    self.artworkIV.layer.masksToBounds = YES;
    
    self.playModeSC.layer.cornerRadius = 5;
    self.playModeSC.layer.masksToBounds = YES;
    self.playModeSC.selectedSegmentIndex = [UserDataUtils CurrentMode];
    
    self.playTimeLabel.layer.cornerRadius = 5;
    self.playTimeLabel.layer.masksToBounds = YES;
    
    self.volumSlider.maximumValue = 1;
    self.volumSlider.value = [UserDataUtils CurrentVolume];
    self.volumSlider.label = self.volumLabel;

    self.volumLabel.layer.cornerRadius = 5;
    self.volumLabel.layer.masksToBounds = YES;
    self.volumLabel.alpha = 0;
    
    [self.playTimeSlider setThumbImage:[UIImage imageNamed:@"thumb_white"] forState:UIControlStateNormal];
    [self.playTimeSlider setMaximumTrackImage:[UIImage imageNamed:@"playing_slider_buf_right"] forState:UIControlStateNormal];
    [self.playTimeSlider setMinimumTrackImage:[UIImage imageNamed:@"playing_slider_buf_left"] forState:UIControlStateNormal];
    self.playTimeSlider.alpha = 0.8;
    
    [self.volumSlider setThumbImage:[UIImage imageNamed:@"thumb_white"] forState:UIControlStateNormal];
    [self.volumSlider setMaximumTrackImage:[UIImage imageNamed:@"playing_slider_buf_right"] forState:UIControlStateNormal];
    [self.volumSlider setMinimumTrackImage:[UIImage imageNamed:@"playing_slider_buf_left"] forState:UIControlStateNormal];
    self.volumSlider.alpha = 0.8;
    
    self.loveButton.layer.cornerRadius = 20;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAutoreverse animations:^{
        self.loveButton.alpha = 1;
        self.playButton.alpha = 1;
        self.nextButton.alpha = 1;
        self.prevButton.alpha = 1;
        self.eqButton.alpha = 0.5;
    } completion:^(BOOL finished) {
        self.loveButton.alpha = 0.4;
        self.playButton.alpha = 0.4;
        self.nextButton.alpha = 0.4;
        self.prevButton.alpha = 0.4;
        self.eqButton.alpha = 1;
    }];
    
    // 背景模糊
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualView.frame = self.view.frame;
    
    self.bgView = [[UIImageView alloc]initWithImage:self.artworkIV.image];
    self.bgView.frame = self.view.frame;
    self.bgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.bgView atIndex:0];
    [self.bgView addSubview:visualView];
    
    self.equalizerView = [[EqualizerView alloc]initWithFrame:CGRectMake(self.eqButton.frame.origin.x - 250, self.eqButton.frame.origin.y - 280, 250, 280)];
    self.equalizerView.alpha = 0;
    [self.view addSubview:self.equalizerView];
}

- (NSString *)minuteStringWithDuration:(NSTimeInterval)duration
{
    int time = duration;
    return [NSString stringWithFormat:@"%02d:%02d", time/60, time%60];
}

- (NSString *)displayTimeString
{
    return [[self minuteStringWithDuration:self.playerManager.currentTime] stringByAppendingFormat:@"/%@", [self minuteStringWithDuration:self.playerManager.duration] ];
}

- (void)setTimer
{
    // 清除上一次的计时器
    for (NSTimer *timer in self.timers) {
        [timer invalidate];
    }
    [self.timers removeAllObjects];
    // 添加计时器
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:FPS/2 target:self selector:@selector(rotateArtworkIV:) userInfo:nil repeats:YES];
    [self.timers addObject:timer];
    timer = [NSTimer scheduledTimerWithTimeInterval:FPS*3 target:self selector:@selector(playTime:) userInfo:nil repeats:YES];
    [self.timers addObject:timer];
}

- (void)rotateArtworkIV: (NSTimer *)timer
{
    self.artworkIV.transform = CGAffineTransformRotate(self.artworkIV.transform, FPS/10);
}

- (void)updateMusicUI
{
    // 更新歌曲名
    Music *curMusic = self.playerManager.curMusic;
    self.title = [NSString stringWithFormat:@"%@ - %@",curMusic.artist, curMusic.title];
    // 设置音量
    self.playerManager.volume = self.volumSlider.value;
    // 添加定时器
    [self setTimer];
    // 更新显示的时间
    self.playTimeSlider.value = 0;
    self.playTimeSlider.maximumValue =  self.playerManager.duration;
    self.playTimeLabel.text = [self displayTimeString];
    
    // 更新播放按钮状态图片
    if (self.playerManager.isPlaying) {
        [self.playButton setImage:[Utils pauseImage] forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:[Utils playImage] forState:UIControlStateNormal];
    }
    
    // 判断是不是喜欢的音乐
    if ([self.playerManager isInLoveGroup]) {
        self.loveButton.backgroundColor = [UIColor purpleColor];
    } else {
        self.loveButton.backgroundColor = [UIColor blackColor];
    }
    
    // 是否是播放ipod歌曲
    BOOL isIpod = self.playerManager.isIpodMusic;
    // 隐藏EQ
    if (isIpod) {
        self.eqButton.hidden = YES;
    } else {
        self.eqButton.hidden = NO;
    }
    
    // 加载歌曲封面图
    
    UIImage *image;
    if (isIpod) {
        image = self.playerManager.ipodArtworkImage;
    } else {
        image = [Utils artworkImageWithPath:curMusic.path];
    }
    if (image) {
        self.artworkIV.image = image;
    } else {
        self.artworkIV.image = [Utils albumPlaceHolderImage];
    }
    // 更新背景
    self.bgView.image = self.artworkIV.image;
    
    //获取歌词
    // 先隐藏歌词栏
    self.lrcTableView.alpha = 0.0;
    [self.playerManager lrcPathWithMusicTitle:self.title Completion:^(id obj) {
        NSLog(@"歌词....");
        NSString *lrcPath =  obj;
        // 判断有没有歌词，有的话加载歌词
        if (lrcPath) {
            NSString *lrcString = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
            self.lrcs = [Utils parseLrcWithString:lrcString];
            self.lrcTableView.alpha = 0.6;
            [self.lrcTableView reloadData];
        }
    }];
}

- (IBAction)playClicked:(UIButton *)sender {
   
    switch (sender.tag) {
        // 播放／暂停
        case 0:
        {
            if (self.playerManager.isPlaying == NO) {
                [self.playerManager play];
                
                [sender setImage:[Utils pauseImage] forState:UIControlStateNormal];
                
            } else {
                [self.playerManager pause];
                
                [sender setImage:[Utils playImage] forState:UIControlStateNormal];
            }
        }
            break;
        // 上一曲
        case 1:
        {
            [self.playButton setImage:[Utils pauseImage] forState:UIControlStateNormal];
            if (self.playModeSC.selectedSegmentIndex ==2) {
                [self.playerManager randomMusic];
            } else {
                [self.playerManager prevMusic];
            }
        }
            break;
        // 下一曲
        case 2:
        {
            [self.playButton setImage:[Utils pauseImage] forState:UIControlStateNormal];
            if (self.playModeSC.selectedSegmentIndex ==2) {
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
// 音量变化触发事件
- (IBAction)volumeValueChanged:(VolumeSlider *)sender {
    
    self.playerManager.volume = sender.value;
    
    self.volumLabel.text = [NSString stringWithFormat:@"%.0f", sender.value / sender.maximumValue * 100];
    
    [UIView animateWithDuration:1 animations:^{
        self.volumLabel.alpha = 0.8;
    }];
    
    // 更新入文件
    [UserDataUtils setCurrentVolume:sender.value];
}

- (IBAction)playModeChanged:(id)sender {
    [UserDataUtils setCurrentMode:self.playModeSC.selectedSegmentIndex];
}

- (IBAction)equalizerClicked:(UIButton *)sender {
    
    CGRect originFrame = self.equalizerView.frame;
    CGRect animateFrame = originFrame;
    if (self.equalizerView.alpha == 0) {
        animateFrame.size.height = 0;
        animateFrame.size.width = 0;
        self.equalizerView.frame = animateFrame;
        [UIView animateWithDuration:0.5 animations:^{
            self.equalizerView.alpha = 0.7;
            self.equalizerView.frame = originFrame;
        }];
    } else {
        animateFrame.size.width = 0;
        animateFrame.size.height = 0;
        [UIView animateWithDuration:0.5 animations:^{
            self.equalizerView.alpha = 0;
            self.equalizerView.frame = animateFrame;
        } completion:^(BOOL finished) {
            self.equalizerView.frame = originFrame;
        }];
    }
    
}

// 播放时间变化触发事件
- (IBAction)playTimeChanged:(PlayTimeSlider *)sender {
    // 不能随着slider值的变化而变化，会有异常状况（加锁了？），只能在滑动结束后才能设置当前的播放时间。
    //self.playerManager.currentTime = sender.value;
    self.playTimeLabel.text = [self displayTimeString];
}
// 播放时间定时器回调事件
- (void)playTime: (NSTimer *)timer
{
    if (!self.playTimeSlider.active) {
        self.playTimeSlider.value = self.playerManager.currentTime;
    }
    
    self.playTimeLabel.text = [self displayTimeString];
    
    static BOOL isScroll = NO;
    for (int i = 0; i < self.lrcs.count; i++) {
        Lrc *lrc = self.lrcs[i];
        if (lrc.time == (int)self.playerManager.currentTime && !isScroll) {
            // 改变当前歌词的颜色
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.lrcTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            ScrolleTableViewCell *cell = (ScrolleTableViewCell *)[self.lrcTableView cellForRowAtIndexPath:indexPath];
            cell.lrcLabel.textColor = [UIColor greenColor];
            // 滚动歌词
            float offsetX = cell.bgScrollView.contentSize.width - cell.bgScrollView.bounds.size.width;
            if (offsetX > 0) {
                isScroll = YES;
                float duration = 0.0f;
                if (i < self.lrcs.count - 1) {
                    duration = ((Lrc *)self.lrcs[i + 1]).time - lrc.time;
                }
            
                [UIView animateWithDuration:duration animations:^{
                    cell.bgScrollView.contentOffset = CGPointMake(offsetX, 0);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.5 animations:^{
                        cell.bgScrollView.contentOffset = CGPointZero;
                    }];
                    isScroll = NO;
                }];
            }
            
            // 把上一句歌词的颜色还原
            indexPath = [NSIndexPath indexPathForRow:i-1 inSection:0];
            if (indexPath) {
                cell = (ScrolleTableViewCell *)[self.lrcTableView cellForRowAtIndexPath:indexPath];
                cell.lrcLabel.textColor = [UIColor whiteColor];

            }
        }
    }
}

- (void)didStartPlaying
{
    [self updateMusicUI];
}

- (IBAction)loveClicked:(UIButton *)sender {
    BOOL curState = [self.playerManager updateMusicLoveState];
    if (curState) {
        sender.backgroundColor = [UIColor purpleColor];
    } else {
        sender.backgroundColor = [UIColor blackColor];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lrcs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ScrolleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LrcCell"];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LrcCell" owner:self options:nil] lastObject];
    }
    
    Lrc *aLrc = self.lrcs[indexPath.row];
    
    cell.lrc = aLrc.text;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
