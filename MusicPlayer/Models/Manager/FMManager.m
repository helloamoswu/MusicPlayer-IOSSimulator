//
//  FMManager.m
//  MusicPlayer
//
//  Created by amos on 15-4-10.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "FMManager.h"
#import "MPManager.h"
#import "TryListenManager.h"
#import "OnlineMusic.h"
#import "AWAVPlayerItem.h"
#import "PlayerManagerUtils.h"

static FMManager *_manager;

@interface FMManager ()

@property (nonatomic, strong)NSArray *musics;
@property (nonatomic)NSInteger curMusicIndex;
@property (nonatomic)BOOL isPlaying;

@end

@implementation FMManager

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentPlayerItemWillDealloc:) name:@"PlayerItemWillDealloc" object:nil];
    }
    
    return self;
}

+ (FMManager *)shareManager
{
    if (!_manager) {
        _manager = [[FMManager alloc] init];
    }
    
    return _manager;
}

- (NSInteger)count
{
    return self.fmPlayer.items.count;
}

- (OnlineMusic *)curPlayMusic
{
    AWAVPlayerItem *playItem = (AWAVPlayerItem *)self.fmPlayer.currentItem;
    return playItem.music;
}

- (void)removeAllMusics
{
    [self.fmPlayer removeAllItems];
}

- (void)play
{
    [PlayerManagerUtils pauseAllPlayerExcept:self];
    
    [self.fmPlayer play];
    self.isPlaying = YES;
    self.isActive = YES;
}

- (void)pause
{
    [self.fmPlayer pause];
    self.isPlaying = NO;
}

- (void)playNextSong
{
    [self.fmPlayer advanceToNextItem];
}

- (void)addMusics:(NSArray *)musics
{
    if (!musics) {
        return;
    }
    
    NSLog(@"fm:即将加载%d首歌", (int)musics.count);
    
    self.musics = musics;
    NSMutableArray *playItems = [NSMutableArray array];
    
    for (int i = 0; i < self.musics.count; i++) {
        OnlineMusic *music = self.musics[i];
        AWAVPlayerItem *playItem = [[AWAVPlayerItem alloc] initWithURL:[NSURL URLWithString:music.musicUrl]];
        if (!playItem) {
            NSLog(@"加载第%d首歌失败: %@-%@", i, music.singer, music.title);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadPlayItemFailed" object:music];
        } else {
            playItem.music = music;
            [playItems addObject:playItem];
        }
    }
    // 判断是不是首次创建fm或者切换了新的频道(切换频道会把当前播放队列清空)
    if (!self.fmPlayer || self.fmPlayer.items.count == 0) {
        self.fmPlayer = [[AVQueuePlayer alloc] initWithItems:playItems];
        [self play];
        [self.delegate readyToPlay];
    }
    // 已经创建fm且频道没有切换，将新的歌曲添加进播放队列即可
    else {
        for (AWAVPlayerItem *item in playItems) {
            [self.fmPlayer insertItem:item afterItem:nil];
        }
    }
    
    NSLog(@"fm:加载音乐成功.");
}

// 当前的playerItem执行释放时发出的通知
- (void)currentPlayerItemWillDealloc:(NSNotification *)notif
{
    // playerItem的释放说明下一首歌要播放了
    [self.delegate readyToPlay];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PlayerItemWillDealloc" object:nil];
}

@end
