//
//  DownloadManager.h
//  MusicPlayer
//
//  Created by amos on 15-4-7.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineMusic.h"
#import "DownloadMusicTask.h"


@protocol DownloadManagerDelegate <NSObject>

@required
- (void)downloadSuccessWithMusicTask:(DownloadMusicTask *)musicTask;
- (void)downloadFailWithMusicTask:(DownloadMusicTask *)musicTask;

@optional
- (void)musicTask:(DownloadMusicTask *)musicTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

@end

@interface DownloadManager : NSObject

@property (nonatomic, strong, readonly)NSMutableArray *musicTasks;
@property (nonatomic, weak)id<DownloadManagerDelegate> delegate;

- (id)initWithIdentifier:(NSString *)identifier;

+ (DownloadManager *)shareManager;

- (void)addDownloadTaskWithMusic:(OnlineMusic *)music;
- (NSURLSessionDownloadTask *)downloadTaskWithMusicTask:(DownloadMusicTask *)musicTask;
- (void)cleanMusicTask:(DownloadMusicTask *)musicTask;

@end
