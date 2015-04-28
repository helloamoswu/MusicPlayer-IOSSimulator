//
//  DownloadMusicTask.m
//  MusicPlayer
//
//  Created by amos on 15-4-9.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "DownloadMusicTask.h"

@implementation DownloadMusicTask

- (id)initWithOnlineMusic:(OnlineMusic *)music
{
    if (self = [super init]) {
        self.music = music;
        self.state = Running;
    }
    
    return self;
}

+ (id)taskWithOnlineMusic:(OnlineMusic *)music
{
    DownloadMusicTask *task = [[DownloadMusicTask alloc]initWithOnlineMusic:music];
    
    return task;
}

@end
