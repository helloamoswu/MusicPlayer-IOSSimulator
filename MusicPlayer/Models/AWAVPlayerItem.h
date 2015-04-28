//
//  AWAVPlayerItem.h
//  MusicPlayer
//
//  Created by amos on 15-4-14.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "OnlineMusic.h"

// for FM

@interface AWAVPlayerItem : AVPlayerItem

@property (nonatomic, strong)OnlineMusic *music;

@end
