//
//  FMManager.h
//  MusicPlayer
//
//  Created by amos on 15-4-10.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class OnlineMusic;

@protocol FMManagerDelegate <NSObject>

- (void)readyToPlay;

@end

@interface FMManager : NSObject

@property (nonatomic, strong)AVQueuePlayer *fmPlayer;
@property (nonatomic, readonly)NSInteger count;
@property (nonatomic, readonly)BOOL isPlaying;
// 当前是否是正在使用的播放器，不管是否有在播放歌曲
@property (nonatomic)BOOL isActive;
@property (nonatomic, strong,readonly)OnlineMusic *curPlayMusic;
@property (nonatomic, weak) id<FMManagerDelegate> delegate;

+ (FMManager *)shareManager;

- (void)removeAllMusics;
- (void)addMusics:(NSArray *)musics;
- (void)playNextSong;
- (void)pause;
- (void)play;

@end
