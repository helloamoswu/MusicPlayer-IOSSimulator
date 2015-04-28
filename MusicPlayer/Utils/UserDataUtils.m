//
//  UserDataUtils.m
//  MusicPlayer
//
//  Created by amos on 15/4/17.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "UserDataUtils.h"

@implementation UserDataUtils

+ (void)setupUserAppData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    [ud setFloat:0.2 forKey:@"CurrentVolume"];
    [ud setDouble:0.0 forKey:@"CurrentPlayTime"];
    [ud setObject:@"" forKey:@"CurrentMusic"];
    [ud setInteger:0 forKey:@"CurrentMode"];
    [ud setObject:@"Ipod" forKey:@"CurrentPlayGroup"];
}

+ (BOOL)isFirstLoadApp
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"IsFirstLoadApp"];
}

+ (void)setIsFirstLoadApp:(BOOL)isFirstLoadApp
{
    [[NSUserDefaults standardUserDefaults] setBool:isFirstLoadApp forKey:@"IsFirstLoadApp"];
}

+ (BOOL)isLoadIpodMusics
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"IsLoadIpodMusics"];
}

+ (void)setIsLoadIpodMusics:(BOOL)isLoadIpodMusics
{
    [[NSUserDefaults standardUserDefaults] setBool:isLoadIpodMusics forKey:@"IsLoadIpodMusics"];
}

+ (float)CurrentVolume
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"CurrentVolume"];
}

+ (void)setCurrentVolume:(float)volume
{
    [[NSUserDefaults standardUserDefaults] setFloat:volume forKey:@"CurrentVolume"];
}

+ (double)CurrentPlayTime
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:@"CurrentPlayTime"];
}

+ (void)setCurrentPlayTime:(double)playTime
{
    [[NSUserDefaults standardUserDefaults] setDouble:playTime forKey:@"CurrentPlayTime"];
}

+ (int)CurrentMode
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentMode"];
}

+ (void)setCurrentMode:(int)mode
{
    [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:@"CurrentMode"];
}

+ (NSString *)CurrentMusic
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentMusic"];
}

+ (void)setCurrentMusic:(NSString *)title
{
    [[NSUserDefaults standardUserDefaults] setObject:title forKey:@"CurrentMusic"];
}

+ (NSString *)CurrentPlayGroup
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPlayGroup"];
}

+ (void)setCurrentPlayGroup:(NSString *)group
{
    [[NSUserDefaults standardUserDefaults] setObject:group forKey:@"CurrentPlayGroup"];
}


@end
