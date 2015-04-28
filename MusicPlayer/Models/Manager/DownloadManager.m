//
//  DownloadManager.m
//  MusicPlayer
//
//  Created by amos on 15-4-7.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "DownloadManager.h"
#import "MPManager.h"
#import "OnlineLrc.h"
#import "Utils.h"

static DownloadManager *_manager;

@interface DownloadManager () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong)NSURLSession *session;
// 根据任务找音乐
@property (nonatomic, strong)NSMutableDictionary *taskToMusicDict;
// 根据音乐找任务
@property (nonatomic, strong)NSMutableDictionary *musicToTaskDict;
// 当前正在下载的所有音乐
@property (nonatomic, strong)NSMutableArray *musicTasks;

@end

@implementation DownloadManager

- (id)initWithIdentifier:(NSString *)identifier
{
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        self.taskToMusicDict = [NSMutableDictionary dictionary];
        self.musicToTaskDict = [NSMutableDictionary dictionary];
        self.musicTasks = [NSMutableArray array];
    }
    
    return self;
}

+ (DownloadManager *)shareManager
{
    if (!_manager) {
        _manager = [[DownloadManager alloc] initWithIdentifier:@"download"];
    }
    
    return _manager;
}
// 添加一个新的下载任务
- (void)addDownloadTaskWithMusic:(OnlineMusic *)music
{
    NSString *path = nil;
    if ([music isMemberOfClass:[OnlineLrc class]]) {
        path = ((OnlineLrc *)music).lrcUrl;
    } else {
        // 下载的是百度歌曲则添加码率参数
        if (!music.rateUrlDict) {
            path = [music.musicUrl stringByAppendingString:[NSString stringWithFormat:@"&rate=%d", music.rate]];
        }
        // 下载的是天天动听歌曲，根据比特率从字典里取链接
        else {
            path = music.rateUrlDict[@(music.rate)][@"url"];
        }
        
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
    [task resume];
    
    DownloadMusicTask *newMusicTask = [DownloadMusicTask taskWithOnlineMusic:music];
    
    [self.taskToMusicDict setObject:newMusicTask forKey:task];
    // 使用音乐对象的哈希值作为key
    [self.musicToTaskDict setObject:task forKey:@(newMusicTask.hash)];
    [self.musicTasks addObject:newMusicTask];
    
}
// 返回音乐所属的任务
- (NSURLSessionDownloadTask *)downloadTaskWithMusicTask:(DownloadMusicTask *)musicTask
{
    return [self.musicToTaskDict objectForKey:@(musicTask.hash)];
}

// 下载完成啦
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // 下载的音乐
    DownloadMusicTask *musicTask = self.taskToMusicDict[downloadTask];
    // 向代理发出下载完成的消息
    OnlineMusic *music = musicTask.music;
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingFromURL:location error:nil];
    // 文件为空，说明下载失败了，极有可能是所选品质的音乐不存在。
    if ([fh seekToEndOfFile] == 0) {
        NSLog(@"下载失败");
        [fh closeFile];
        [[NSFileManager defaultManager]removeItemAtURL:location error:nil];
        musicTask.state = Fail;
        [self.delegate downloadFailWithMusicTask:musicTask];
    
    } else {
        NSLog(@"下载完成");
        [fh closeFile];
        // 保存
        NSString *extension = nil;
        BOOL isLrc = [music isMemberOfClass:[OnlineLrc class]];
        if (isLrc) {
            extension = @"lrc";
        } else {
            if (music.rateUrlDict) {
                extension = music.rateUrlDict[@(music.rate)][@"format"];
            } else {
                extension = @"mp3";
            }
        }
        NSString *formatStr = [[[Utils applicationDocumentsDirectory]
                                stringByAppendingPathComponent: isLrc?@"Lrcs":@"Musics"] stringByAppendingString:@"/%@ - %@.%@"];
        NSString *savePath = [NSString stringWithFormat:formatStr, music.singer, music.title, extension];
        savePath = [Utils generateSuitablePathForPath:savePath];
        NSURL *newURL = [NSURL fileURLWithPath:savePath];
        [[NSFileManager defaultManager]moveItemAtURL:location toURL:newURL error:nil];
        
        // 添加到下载列表
        if (!isLrc) {
            [[MPManager shareManager] addMusicWithFilePath:savePath AndTitle:music.title AndArtist:music.singer intoGroup:@"Download"];
        }
        
        [self cleanMusicTask:musicTask];
        [self.delegate downloadSuccessWithMusicTask:musicTask];
    }
}

- (void)cleanMusicTask:(DownloadMusicTask *)musicTask
{
    // 清理
    [self.musicTasks removeObject:musicTask];
    NSURLSessionDownloadTask *task = self.musicToTaskDict[@(musicTask.hash)];
    // 任务还没完成，先取消
    if (task.state != NSURLSessionTaskStateCompleted) {
        [task cancel];
    }
    [self.taskToMusicDict removeObjectForKey:task];
    [self.musicToTaskDict removeObjectForKey:@(musicTask.hash)];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // 把下载进度消息发送给代理
    if ([self.delegate respondsToSelector:@selector(musicTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.delegate musicTask:self.taskToMusicDict[downloadTask] didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

@end
