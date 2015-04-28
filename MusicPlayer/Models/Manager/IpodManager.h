//
//  IpodManager.h
//  MusicPlayer
//
//  Created by amos on 15/4/16.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol IpodManagerDelegate <NSObject>

- (void)didFinishPlayIpodMusic;

@end

@interface IpodManager : NSObject

@property (nonatomic, weak)id<IpodManagerDelegate>delegate;
@property (nonatomic)float volume;
@property (nonatomic)NSTimeInterval currentTime;
@property (nonatomic, readonly)NSTimeInterval duration;
@property (nonatomic)BOOL hasPlayItem;

@property (nonatomic, strong)NSArray *ipodMusicPaths;

+ (IpodManager *)shareManager;

- (void)play;
- (void)pause;
- (void)stop;

- (void)playMusicWithAssertPath:(NSString *)path;
- (UIImage *)artworkImageWithPath:(NSString *)path;

- (NSArray *)ipodMusics;

@end
