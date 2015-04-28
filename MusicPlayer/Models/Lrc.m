//
//  Lrc.m
//  MusicPlayer
//
//  Created by amos on 15-3-20.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "Lrc.h"

@implementation Lrc

- (id)initWithText:(NSString *)text atTime:(int)time
{
    if (self = [super init]) {
        self.text = text;
        self.time = time;
    }
    
    return self;
}

+ (id)lrcWithText:(NSString *)text atTime:(int)time
{
    Lrc *aLrc = [[Lrc alloc] initWithText:text atTime:time];
    
    return aLrc;
}

@end
