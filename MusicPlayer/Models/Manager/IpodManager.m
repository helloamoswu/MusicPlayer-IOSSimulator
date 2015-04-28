//
//  IpodManager.m
//  MusicPlayer
//
//  Created by amos on 15/4/16.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "IpodManager.h"
#import <AVFoundation/AVFoundation.h>
#import "NSArray+Shuffle.h"
#import "UserDataUtils.h"

#define IPOD_PLAY_QUEUE_COUNT 50

static IpodManager *_manager;

@interface IpodManager ()

@property (nonatomic, strong)AVPlayer *player;

@end

@implementation IpodManager

+ (IpodManager *)shareManager
{
    if (!_manager) {
        _manager = [[IpodManager alloc]init];
    }
    
    return _manager;
}

- (id)init
{
    if (self = [super init]) {
        self.hasPlayItem = NO;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    
    return self;
}

- (NSArray *)ipodMusics
{
    MPMediaQuery *allMusics = [[MPMediaQuery alloc] init];
    
    NSMutableArray *musics = [NSMutableArray array];
    for (MPMediaItem *songMediumItem in allMusics.items) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSString *songTitle =  [songMediumItem valueForProperty: MPMediaItemPropertyTitle];
        NSURL *songAssertUrl = [songMediumItem valueForProperty:MPMediaItemPropertyAssetURL];
        NSString *artist = [songMediumItem valueForKeyPath:MPMediaItemPropertyArtist];
        
        NSArray *artistAndTitle = [songTitle componentsSeparatedByString:@" - "];
        if (artistAndTitle.count > 1) {
            if (artist.length == 0) {
                artist = [artistAndTitle firstObject];
            }
        }
        if (artist.length == 0) {
            artist = @"未知";
        }
        dic[@"title"] = [artistAndTitle lastObject];
        dic[@"artist"] = artist;
        dic[@"path"] = [songAssertUrl absoluteString];
        
        [musics addObject:dic];
    }
    return musics;
}

- (void)playMusicWithAssertPath:(NSString *)path
{
    self.hasPlayItem = YES;
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:path]];
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
    [self play];
}

- (void)play
{
    [self.player play];
}

- (void)pause
{
    [self.player pause];
}

- (void)stop
{
    [self pause];
}

- (void)setVolume:(float)volume
{
    self.player.volume = volume;
}

- (float)volume
{
    return self.player.volume;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    [self.player seekToTime: CMTimeMakeWithSeconds(currentTime, 1)];
}

- (NSTimeInterval)currentTime
{
    return CMTimeGetSeconds(self.player.currentTime);
}

- (NSTimeInterval)duration
{
    return CMTimeGetSeconds(self.player.currentItem.duration);
}

- (UIImage *)artworkImageWithPath:(NSString *)path
{
    NSString *idStr = [[path componentsSeparatedByString:@"="] lastObject];
    NSNumber *songPersistenceId = [NSNumber numberWithUnsignedLongLong:[idStr longLongValue]];
    
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:songPersistenceId forProperty:MPMediaItemPropertyPersistentID];
    MPMediaQuery *allMusics = [[MPMediaQuery alloc] init];
    [allMusics addFilterPredicate:predicate];
    
    MPMediaItem *item = [allMusics.items lastObject];
    
    MPMediaItemArtwork *artwork = [item valueForProperty: MPMediaItemPropertyArtwork];
    
    UIImage *artworkImage = nil;
    if (artwork) {
        artworkImage = [artwork imageWithSize: CGSizeMake (200, 200)];
    }
    
    return artworkImage;
}

- (void)playerItemDidReachEnd:(NSNotification *)notif
{
    if (![notif.object isMemberOfClass:[AVPlayerItem class]]) {
        return;
    }
    
    NSLog(@"即将播放下一首Ipod歌");
    
    [self.delegate didFinishPlayIpodMusic];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

@end
