//
//  MPManager.h
//  MusicPlayer
//
//  Created by amos on 15-4-10.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKAudioPlayer.h"
#import "OnlineMusic.h"

typedef void (^Completion) (id obj);

@class Music;
@class Group;

@protocol MPManagerDelegate

- (void)didStartPlaying;

@end


@interface MPManager : NSObject<STKAudioPlayerDelegate>

@property (nonatomic, weak)id<MPManagerDelegate>delegate;

@property (nonatomic, strong)NSArray *groups;
@property (nonatomic, strong)NSMutableDictionary *groupsDict;
@property (nonatomic, strong)NSMutableDictionary *musicsDict;

@property (nonatomic, strong)NSArray *curPlayMusics;
@property (nonatomic)NSInteger curMusicIndex;
@property (nonatomic, strong)Music *curMusic;
@property (nonatomic, strong)NSString *curViewGroup;
@property (nonatomic, strong)NSString *curPlayGroup;
@property (nonatomic, strong)NSArray *curViewMusics;
@property (nonatomic)float currentTime;
@property (nonatomic, readonly)float duration;
@property (nonatomic)float volume;
@property (nonatomic, readonly)BOOL isPlaying;
// 当前是否是正在使用的播放器，不管是否有在播放歌曲
@property (nonatomic)BOOL isActive;

@property (nonatomic, strong)UIImage *ipodArtworkImage;
@property (nonatomic)BOOL isIpodMusic;

+ (MPManager *)shareManager;

- (void)nextMusic;
- (void)prevMusic;
- (void)randomMusic;
- (void)playMusicWithIndex: (NSInteger)index;
- (void)replay;
- (void)play;
- (void)pause;

- (BOOL)isInLoveGroup;
- (BOOL)updateMusicLoveState;
- (BOOL)addGroupWithName: (NSString *)name;
- (void)removeMusicAtIndex: (NSInteger)index inGroup: (NSString *)name;
- (void)removeMusic:(Music *)music inGroup:(NSString *)name;
- (void)removeAllMusicInGroup:(NSString *)name;
- (void)addMusicWithFilePath:(NSString *)path AndTitle:(NSString *)title AndArtist:(NSString *)artist intoGroup:(NSString *)groupName;
- (void)addMusics:(NSArray *)musics intoGroup:(NSString *)groupName;
- (BOOL)isMusicDownloaded:(OnlineMusic *)music;
- (NSString *)musicPathWithTitle:(NSString *)title andArtist:(NSString *)artist;
- (void)lrcPathWithMusicTitle:(NSString *)title Completion:(Completion)callback;
- (BOOL)isCustomGroup:(NSString *)name;
- (void)removeGroup:(Group *)group;

- (void)initialAppData;
- (void)reLoadIpoadMusics;

- (void)setGain:(float)gain forEqualizerBand:(int)bandIndex;

@end
