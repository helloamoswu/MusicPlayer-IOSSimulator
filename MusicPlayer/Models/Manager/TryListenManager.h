//
//  TryListenManager.h
//  MusicPlayer
//
//  Created by amos on 15-4-12.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TryListenManagerDelegate

- (void)didFinishedPlay;

@end

@interface TryListenManager : NSObject

@property (nonatomic, readonly)BOOL isPlaying;
@property (nonatomic, strong)NSString *curMusicName;

@property (nonatomic, weak)id<TryListenManagerDelegate>delegate;

+ (TryListenManager *)shareManager;

- (void)playMusicWithUrlPath:(NSString *)path isLocalFile:(BOOL)isLocalFile;

- (void)play;
//- (void)pause;
- (void)stop;

@end
