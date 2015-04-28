//
//  UserDataUtils.h
//  MusicPlayer
//
//  Created by amos on 15/4/17.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDataUtils : NSObject

+ (void)setupUserAppData;

+ (float)CurrentVolume;
+ (double)CurrentPlayTime;
+ (int)CurrentMode;
+ (NSString *)CurrentMusic;
+ (NSString *)CurrentPlayGroup;
+ (BOOL)isFirstLoadApp;
+ (BOOL)isLoadIpodMusics;

+ (void)setCurrentVolume:(float)volume;
+ (void)setCurrentPlayTime:(double)playTime;
+ (void)setCurrentMode:(int)mode;
+ (void)setCurrentMusic:(NSString *)title;
+ (void)setCurrentPlayGroup:(NSString *)group;
+ (void)setIsFirstLoadApp:(BOOL)isFirstLoadApp;
+ (void)setIsLoadIpodMusics:(BOOL)isLoadIpodMusics;

@end
