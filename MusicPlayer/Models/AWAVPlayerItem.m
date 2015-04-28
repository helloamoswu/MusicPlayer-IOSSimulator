//
//  AWAVPlayerItem.m
//  MusicPlayer
//
//  Created by amos on 15-4-14.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "AWAVPlayerItem.h"

@implementation AWAVPlayerItem

- (void)dealloc
{
    NSLog(@"playItem: dealloc");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerItemWillDealloc" object:self];
}

@end
