//
//  Lrc.h
//  MusicPlayer
//
//  Created by amos on 15-3-20.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>

// 保存歌词文件lrc的信息

@interface Lrc : NSObject

@property (nonatomic, strong)NSString *text;
@property (nonatomic)int time;

- (id)initWithText: (NSString *)text atTime: (int)time;

+ (id)lrcWithText: (NSString *)text atTime: (int)time;

@end
