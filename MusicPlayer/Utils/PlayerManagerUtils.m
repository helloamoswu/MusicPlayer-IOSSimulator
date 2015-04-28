//
//  PlayerManagerUtils.m
//  MusicPlayer
//
//  Created by amos on 15/4/25.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "PlayerManagerUtils.h"
#import "MPManager.h"
#import "FMManager.h"   
#import "TryListenManager.h"

@implementation PlayerManagerUtils

// 先关掉其他正在播放的播放器
+ (void)pauseAllPlayerExcept:(id)player
{
    if (!player) {
        if ([FMManager shareManager].isPlaying) {
            [[FMManager shareManager] pause];
            [FMManager shareManager].isActive = NO;
        } else if ([TryListenManager shareManager].isPlaying) {
            [[TryListenManager shareManager] stop];
        } else if ([MPManager shareManager].isPlaying) {
            [[MPManager shareManager] pause];
            [MPManager shareManager].isActive = NO;
        }
    } else if ([player isEqual:[MPManager shareManager]]) {
        if ([FMManager shareManager].isPlaying) {
            [[FMManager shareManager] pause];
            [FMManager shareManager].isActive = NO;
        } else if ([TryListenManager shareManager].isPlaying) {
            [[TryListenManager shareManager] stop];
        }
    } else if ([player isEqual:[FMManager shareManager]]) {
        if ([MPManager shareManager].isPlaying) {
            [[MPManager shareManager] pause];
            [MPManager shareManager].isActive = NO;
        } else if ([TryListenManager shareManager].isPlaying) {
            [[TryListenManager shareManager] stop];
        }
    } else if ([player isEqual:[TryListenManager shareManager]]) {
        if ([MPManager shareManager].isPlaying) {
            [[MPManager shareManager] pause];
            [MPManager shareManager].isActive = NO;
        } else if ([FMManager shareManager].isPlaying) {
            [[FMManager shareManager] pause];
            [FMManager shareManager].isActive = NO;
        }
    }
}

@end
