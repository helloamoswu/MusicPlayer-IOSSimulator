//
//  OnlineLrc.h
//  MusicPlayer
//
//  Created by amos on 15-3-30.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineMusic.h"

// 百度歌词
@interface OnlineLrc : OnlineMusic

@property (nonatomic, strong)NSString *lrcUrl;

@end
