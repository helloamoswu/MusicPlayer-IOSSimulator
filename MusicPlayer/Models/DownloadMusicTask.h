//
//  DownloadMusicTask.h
//  MusicPlayer
//
//  Created by amos on 15-4-9.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineMusic.h"

typedef enum DownloadState{
    Fail,
    Success,
    Running
}DownloadState;

@interface DownloadMusicTask : NSObject

@property (nonatomic, strong)OnlineMusic *music;
@property (nonatomic)DownloadState state;

- (id)initWithOnlineMusic:(OnlineMusic *)music;

+ (id)taskWithOnlineMusic:(OnlineMusic *)music;

@end
