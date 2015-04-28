//
//  TryListenManager.m
//  MusicPlayer
//
//  Created by amos on 15-4-12.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "TryListenManager.h"
#import "STKAudioPlayer.h"
#import "MPManager.h"
#import "FMManager.h"
#import "PlayerManagerUtils.h"

static TryListenManager *_manager;

@interface TryListenManager () <STKAudioPlayerDelegate>
// 目前只有这个可以播放在线的歌曲（需要重定向的链接，不是歌曲的最终链接）
@property (nonatomic, strong)STKAudioPlayer *player;
@property (nonatomic, readwrite)BOOL isPlaying;

@end

@implementation TryListenManager

+ (TryListenManager *)shareManager
{
    if (!_manager) {
        _manager = [[TryListenManager alloc]init];
    }
    
    return _manager;
}

- (id)init
{
    if (self = [super init]) {
        self.player = [[STKAudioPlayer alloc] init];
        self.player.equalizerEnabled = NO;
        self.player.meteringEnabled = NO;
        self.player.delegate = self;
    }
    
    return self;
}

- (void)playMusicWithUrlPath:(NSString *)path isLocalFile:(BOOL)isLocalFile
{
    [PlayerManagerUtils pauseAllPlayerExcept:self];
    
    NSURL *url = nil;
    
    if (isLocalFile) {
        url = [NSURL fileURLWithPath:path];
    } else {
        url = [NSURL URLWithString:path];
    }
    
    if ([self.player.currentlyPlayingQueueItemId isEqual:url]) {
        [self stop];
    } else {
        [self.player playURL:url];
        self.isPlaying = YES;
    }
}

- (void)addMusicWithUrlPath:(NSString *)path
{
    NSURL *url = [NSURL URLWithString:path];
    
    [self.player queueURL:url];
}

- (void)cleanPlayQueue
{
    [self.player clearQueue];
}

- (void)play
{
    [self.player resume];
    self.isPlaying = YES;
}

- (void)pause
{
    [self.player pause];
    self.isPlaying = NO;
}

- (void)stop
{
    [self.player stop];
    self.isPlaying = NO;
}

#pragma mark - STKAudioPlayer Delegate
- (void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishPlayingQueueItemId:(NSObject *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{
    
    if (stopReason == STKAudioPlayerStopReasonEof) {
        [self.delegate didFinishedPlay];
    }
    NSLog(@"finish play");
}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    if (state & STKAudioPlayerStateBuffering || state & STKAudioPlayerStatePaused) {
        NSLog(@"buffering...");
    }
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didStartPlayingQueueItemId:(NSObject *)queueItemId
{
    [[MPManager shareManager] pause];
    
    NSLog(@"start playing...");
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject *)queueItemId
{
    NSLog(@"finish buffering");
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    NSLog(@"error code:%d", errorCode);
}

@end
