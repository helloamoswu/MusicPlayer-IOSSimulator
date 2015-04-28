//
//  MPManager.m
//  MusicPlayer
//
//  Created by amos on 15-4-10.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "MPManager.h"
#import "FMManager.h"
#import "TryListenManager.h"
#import "Music.h"
#import "Group.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "BaiduMusicUtils.h"
#import "OnlineLrc.h"
#import "DownloadManager.h"
#import "IpodManager.h"
#import "UserDataUtils.h"
#import "PlayerManagerUtils.h"
#include "DongTingUtils.h"

#define IPOD @"ipod"

static MPManager *_manager;

@interface MPManager () <IpodManagerDelegate>

@property (nonatomic, weak)AppDelegate *app;
@property (nonatomic, readwrite)BOOL isPlaying;
@property (nonatomic, strong)IpodManager *ipodManager;

@end

@implementation MPManager

+ (MPManager *)shareManager
{
    if (!_manager) {
        _manager = [[MPManager alloc]init];
    }
    
    return _manager;
}

- (id)init
{
    if (self = [super init]) {
        self.app = [UIApplication sharedApplication].delegate;
        
        // 第一次要初始化数据
        if ([UserDataUtils isFirstLoadApp] == NO) {
            [UserDataUtils setIsFirstLoadApp:YES];
            [UserDataUtils setupUserAppData];
            [self initialAppData];
        }
        
        [self loadGroups];
        [self createGroupAndMusicDictionary];
        // 导入Ipod library
        if ([UserDataUtils isLoadIpodMusics] == NO) {
            [UserDataUtils setIsLoadIpodMusics:YES];
            [self loadIpodMusics];
        }
        
        [self setupPlayer];
    }
    
    return self;
}

- (void)initialAppData
{
    [self addGroupWithName:@"Ipod"];
    [self addGroupWithName:@"Love"];
    [self addGroupWithName:@"Latest"];
    [self addGroupWithName:@"Download"];
    
    [self createDir];
}

- (void)createDir
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *docuPath = [Utils applicationDocumentsDirectory];
    
    NSString *musicDir = [docuPath stringByAppendingPathComponent:@"Musics"];
    
    if (![manager fileExistsAtPath:musicDir]) {
        [manager createDirectoryAtPath:musicDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *lrcDir = [docuPath stringByAppendingPathComponent:@"Lrcs"];
    
    if (![manager fileExistsAtPath:lrcDir]) {
        [manager createDirectoryAtPath:lrcDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

- (void)loadIpodMusics
{
    NSArray *ipodMusics = [[IpodManager shareManager] ipodMusics];
    for (NSDictionary *dic in ipodMusics) {
        [self addMusicWithFilePath:dic[@"path"] AndTitle:dic[@"title"] AndArtist:dic[@"artist"] intoGroup:@"Ipod"];
    }
}

- (void)reLoadIpoadMusics
{
    NSArray *ipodMusics = [[IpodManager shareManager] ipodMusics];
    for (NSDictionary *dic in ipodMusics) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Music"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"path == %@", dic[@"path"]];
        request.predicate = predicate;
        NSArray *results = [self.app.managedObjectContext executeFetchRequest:request error:nil];
        if (results && results.count == 0) {
            [self addMusicWithFilePath:dic[@"path"] AndTitle:dic[@"title"] AndArtist:dic[@"artist"] intoGroup:@"Ipod"];
        }
    }
    
    self.musicsDict[@"Ipod"] = [self musicsWithGroupName:@"Ipod"];
    
    if ([self.curPlayGroup isEqualToString:@"Ipod"]) {
        self.curPlayMusics = self.musicsDict[@"Ipod"];
    }
    if ([self.curViewGroup isEqualToString:@"Ipod"]) {
        self.curViewMusics = self.musicsDict[@"Ipod"];
    }
}

// 加载所有的组
- (void)loadGroups
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
    self.groups = [self.app.managedObjectContext executeFetchRequest:request error:nil];
}
// 创建组名到组和组音乐的映射
- (void)createGroupAndMusicDictionary
{
    self.groupsDict = [[NSMutableDictionary alloc] initWithCapacity:self.groups.count];
    self.musicsDict = [[NSMutableDictionary alloc] initWithCapacity:self.groups.count];
    for (Group *group in self.groups) {
        self.groupsDict[group.name] = group;
        self.musicsDict[group.name] = [self musicsWithGroupName:group.name];
        
    }
}
// 获取指定组的音乐
- (NSArray *)musicsWithGroupName:(NSString *)name
{
    Group *group = self.groupsDict[name];
    return [[group.musics allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Music *music1 = obj1;
        Music *music2 = obj2;
        
        return [music1.artist localizedCaseInsensitiveCompare:music2.artist];
    }];
}

- (void)setCurPlayGroup:(NSString *)curPlayGroup
{
    _curPlayGroup = curPlayGroup;
    self.curPlayMusics = self.musicsDict[curPlayGroup];
}

- (void)setCurViewGroup:(NSString *)curViewGroup
{
    _curViewGroup = curViewGroup;
    self.curViewMusics = self.musicsDict[curViewGroup];
}

// 初始化播放器
- (void)setupPlayer
{
    self.curPlayGroup = [UserDataUtils CurrentPlayGroup];
    self.curMusicIndex = 0;
    
    NSString *title = [UserDataUtils CurrentMusic];
    
    self.currentTime = [UserDataUtils CurrentPlayTime];
    
    for (int i = 0; i < self.curPlayMusics.count; i++) {
        Music *music = self.curPlayMusics[i];
        if ([music.title isEqualToString:title]) {
            self.curMusicIndex = i;
            break;
        }
    }
    // 自带均衡器，哈哈😄
    self.audioManager = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = YES, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
    self.audioManager.volume = [UserDataUtils CurrentVolume];
    self.audioManager.equalizerEnabled = YES;
    self.audioManager.delegate = self;
    self.isPlaying = NO;
    
    self.ipodManager = [IpodManager shareManager];
    self.ipodManager.delegate = self;
    
    NSMutableArray *musicPaths = [NSMutableArray array];
    for (Music *music in self.musicsDict[@"Ipod"]) {
        [musicPaths addObject:music.path];
    }
    self.ipodManager.ipodMusicPaths = musicPaths;
}

#pragma Add Group
- (BOOL)addGroupWithName: (NSString *)name
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *res = [self.app.managedObjectContext executeFetchRequest:request error:nil];
    if (res.count > 0) {
        return NO;
    }
    Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.app.managedObjectContext];
    group.name = name;
    
    [self.app saveContext];
    
    // reload groups
    [self loadGroups];
    self.groupsDict[name] = group;
    self.musicsDict[name] = [self musicsWithGroupName:name];
    
    return YES;
}
#pragma Remove Music
- (void)removeMusicAtIndex:(NSInteger)index inGroup:(NSString *)name
{
    Music *music = self.curViewMusics[index];
    
    if (music) {
        [music removeGroupsObject:self.groupsDict[name]];
        
        if (music.groups.count == 0) {
            [[NSFileManager defaultManager] removeItemAtPath:music.path error:nil];
            [self.app.managedObjectContext deleteObject:music];
        }
        
        [self.app saveContext];
        
        self.musicsDict[name] = [self musicsWithGroupName:name];
        
        if ([name isEqualToString:self.curPlayGroup]) {
            self.curPlayMusics = self.musicsDict[name];
        }
        
        if ([name isEqualToString:self.curViewGroup]) {
            self.curViewMusics = self.musicsDict[name];
        }
    }
}

- (void)removeMusic:(Music *)music inGroup:(NSString *)name
{
    if (music) {
        [music removeGroupsObject:self.groupsDict[name]];
        
        if (music.groups.count == 0) {
            [[NSFileManager defaultManager] removeItemAtPath:music.path error:nil];
            [self.app.managedObjectContext deleteObject:music];
        }
        
        [self.app saveContext];
        
        self.musicsDict[name] = [self musicsWithGroupName:name];
        if ([name isEqualToString:self.curPlayGroup]) {
            self.curPlayMusics = self.musicsDict[name];
        }
        if ([name isEqualToString:self.curViewGroup]) {
            self.curViewMusics = self.musicsDict[name];
        }
    }
}

- (void)removeAllMusicInGroup:(NSString *)name
{
    NSArray *musics = self.musicsDict[name];
    Group *group = self.groupsDict[name];
    for (Music *music in musics) {
        [music removeGroupsObject:group];
        
        if (music.groups.count == 0) {
            [[NSFileManager defaultManager] removeItemAtPath:music.path error:nil];
            [self.app.managedObjectContext deleteObject:music];
        }
    }
    
    [self.app saveContext];
    
    self.musicsDict[name] = [self musicsWithGroupName:name];
    if ([name isEqualToString:self.curPlayGroup]) {
        self.curPlayMusics = self.musicsDict[name];
    }
    if ([name isEqualToString:self.curViewGroup]) {
        self.curViewMusics = self.musicsDict[name];
    }
}


#pragma Add Music
// 添加音乐到指定组里
- (void)addMusicWithFilePath:(NSString *)path AndTitle:(NSString *)title AndArtist:(NSString *)artist intoGroup:(NSString *)groupName
{
    Music *music = [NSEntityDescription insertNewObjectForEntityForName:@"Music" inManagedObjectContext:self.app.managedObjectContext];
    music.path = path;
    music.title = title;
    music.artist = artist;
    music.duration = @([Utils getMusicDurationByPath:path]);
    [music addGroupsObject:self.groupsDict[groupName]];
    
    [self.app saveContext];
    // 更新对应组的音乐列表
    self.musicsDict[groupName] = [self musicsWithGroupName:groupName];
}

- (void)addMusics:(NSArray *)musics intoGroup:(NSString *)groupName
{
    for (Music *music in musics) {
        [music addGroupsObject:self.groupsDict[groupName]];
    }
    self.musicsDict[groupName] = [self musicsWithGroupName:groupName];
    
    if ([groupName isEqualToString:self.curPlayGroup]) {
        self.curPlayMusics = self.musicsDict[groupName];
    }
    
    if ([groupName isEqualToString:self.curViewGroup]) {
        self.curViewMusics = self.musicsDict[groupName];
    }
    
    [self.app saveContext];
}

#pragma mark - IpodManager Delegate

- (void)didFinishPlayIpodMusic
{
    [self skipToNextMusic];
}

#pragma mark - STKAudioPlayer Delegate
- (void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishPlayingQueueItemId:(NSObject *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{
    
    if (stopReason != STKAudioPlayerStopReasonEof) {
        return;
    }
    
    [self skipToNextMusic];
}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didStartPlayingQueueItemId:(NSObject *)queueItemId
{
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject *)queueItemId
{
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    NSLog(@"error code:%d", errorCode);
}

- (UIImage *)ipodArtworkImage
{
    return [self.ipodManager artworkImageWithPath:self.curMusic.path];
}

- (void)skipToNextMusic
{
    NSInteger curMode = [UserDataUtils CurrentMode];
    switch (curMode) {
        case 0:
        {
            [self nextMusic];
        }
            break;
        case 1:
        {
            [self replay];
        }
            break;
        case 2:
        {
            [self randomMusic];
        }
            break;
        default:
            break;
    }
}

# pragma mark - Music Controle

- (void)setCurrentTime:(float)currentTime
{
    if (self.isIpodMusic) {
        self.ipodManager.currentTime = currentTime;
    } else {
        [self.audioManager seekToTime:currentTime];
    }
}

- (float)currentTime
{
    if (self.isIpodMusic) {
        return self.ipodManager.currentTime;
    } else {
        return self.audioManager.progress;
    }
}

- (void)setVolume:(float)volume
{
    if (self.isIpodMusic) {
        self.ipodManager.volume = volume;
    } else {
        self.audioManager.volume = volume;
    }
}

- (float)volume
{
    if (self.isIpodMusic) {
        return self.ipodManager.volume;
    } else {
        return self.audioManager.volume;
    }
}

- (float)duration
{
    // 没有歌曲
    if (self.curPlayMusics.count == 0) {
        return 0;
    }
    
    return self.curMusic.duration.floatValue;
}

- (void)play
{
    // 确保有歌曲可播放
    if (!self.curMusic) {
        return;
    }
    
    [PlayerManagerUtils pauseAllPlayerExcept:self];
    
    // 启动时没有准备音乐，所以这里要判断一下
    if (!self.audioManager.currentlyPlayingQueueItemId && !self.ipodManager.hasPlayItem) {
        [self prepareMusic];
    }
    // 当前播放的歌曲是ipod的歌
    if (self.isIpodMusic) {
        [self.ipodManager play];
        [self.audioManager stop];
    }
    // 当前播放的歌曲是自己下载的歌
    else {
        [self.audioManager resume];
        [self.ipodManager stop];
    }
    
    self.isPlaying = YES;
    self.isActive = YES;
}

- (void)pause
{
    if (self.isIpodMusic) {
        [self.ipodManager pause];
    } else {
        [self.audioManager pause];
    }
    
    self.isPlaying = NO;
}

- (void)stop
{
    if (self.isIpodMusic) {
        [self.ipodManager stop];
    } else {
        [self.audioManager stop];
    }
    
    self.isPlaying = NO;
}

- (void)nextMusic
{
    if (self.curPlayMusics.count == 0) {
        [self stop];
    } else {
        self.curMusicIndex++;
        [self playMusic];
    }
}

- (void)prevMusic
{
    if (self.curPlayMusics.count == 0) {
        [self stop];
    } else {
        self.curMusicIndex--;
        [self playMusic];
    }
}

- (void)randomMusic
{
    if (self.curPlayMusics.count == 0) {
        [self stop];
    } else {
        self.curMusicIndex = arc4random()%self.curPlayMusics.count;
        [self playMusic];
    }
}

- (void)prepareMusic
{
    if (self.isIpodMusic) {
        [self.ipodManager playMusicWithAssertPath:self.curMusic.path];
    } else {
        NSURL *url = [NSURL fileURLWithPath:self.curMusic.path];
        [self.audioManager playURL:url];
    }
    // 由于一些歌曲在存入数据库时未能正确的获取时长，比如无损格式的歌曲
    // 对于那些时长为0的歌曲，这里需要重新更新一下
    [self updateDuration];
}

- (void)playMusic
{
    [self prepareMusic];
    [self play];
    
    [self updateLatestGroup];
    
    [self.delegate didStartPlaying];
}

- (void)replay
{
    [self playMusic];
}

- (void)playMusicWithIndex: (NSInteger)index
{
    self.curMusicIndex = index;
    [self playMusic];
}

// 设置索引的同时设置歌曲名称
- (void)setCurMusicIndex:(NSInteger)curMusicIndex
{
    if (curMusicIndex > self.curPlayMusics.count - 1) {
        _curMusicIndex = 0;
    } else if (curMusicIndex < 0) {
        _curMusicIndex = self.curPlayMusics.count - 1;
    } else {
        _curMusicIndex = curMusicIndex;
    }
    
    if (self.curPlayMusics.count == 0) {
        return;
    }
    
    self.curMusic = self.curPlayMusics[_curMusicIndex];
    self.isIpodMusic = [self.curMusic.path hasPrefix:IPOD];
}

#pragma mark -

- (BOOL)isInLatestGroup
{
    Music *music = self.curPlayMusics[self.curMusicIndex];
    for (Group *group in music.groups) {
        if ([group.name isEqualToString:@"Latest"]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateLatestGroup
{
    Music *music = self.curPlayMusics[self.curMusicIndex];
    if (![self isInLatestGroup]) {
        [music addGroupsObject:self.groupsDict[@"Latest"]];
    }
    [self.app saveContext];
    self.musicsDict[@"Latest"] = [self musicsWithGroupName:@"Latest"];
    
    // 当前播放的是最近播放的列表则需要更新
    if ([self.curPlayGroup isEqualToString:@"Latest"]) {
        self.curPlayMusics = self.musicsDict[@"Latest"];
    }
}

- (BOOL)isInLoveGroup
{
    if (self.curPlayMusics.count == 0) {
        return NO;
    }
    
    Music *music = self.curPlayMusics[self.curMusicIndex];
    for (Group *group in music.groups) {
        if ([group.name isEqualToString:@"Love"]) {
            return YES;
        }
    }
    return NO;
}
// 更新当前音乐的喜欢状态
- (BOOL)updateMusicLoveState
{
    if (self.curPlayMusics.count == 0) {
        return NO;
    }
    
    Music *music = self.curPlayMusics[self.curMusicIndex];
    
    BOOL isLove = [self isInLoveGroup];
    if (isLove) {
        [music removeGroupsObject:self.groupsDict[@"Love"]];
    } else {
        [music addGroupsObject:self.groupsDict[@"Love"]];
    }
    
    [self.app saveContext];
    self.musicsDict[@"Love"] = [self musicsWithGroupName:@"Love"];
    
    if ([self.curPlayGroup isEqualToString:@"Love"]) {
        self.curPlayMusics = self.musicsDict[@"Love"];
    }
    
    return !isLove;
}

// 判断提供的歌曲是否已经下载了
- (BOOL)isMusicDownloaded:(OnlineMusic *)music
{
    // 只搜索下载组
    NSArray *downloadedMusics = self.musicsDict[@"Download"];
    for (Music *downloadedMusic in downloadedMusics) {
        if ([downloadedMusic.title isEqualToString:music.title] && [downloadedMusic.artist isEqualToString:music.singer]) {
            return YES;
        }
    }
    return NO;
}
// 根据歌曲名字返回歌曲播放路径
- (NSString *)musicPathWithTitle:(NSString *)title andArtist:(NSString *)artist
{
    NSArray *downloadedMusics = self.musicsDict[@"Download"];
    for (Music *music in downloadedMusics) {
        if ([music.title isEqualToString:title] && [music.artist isEqualToString:artist]) {
            return music.path;
        }
    }
    return nil;
}

- (void)updateDuration
{
    if (self.curMusic.duration.intValue == 0) {
        if (self.isIpodMusic) {
            self.curMusic.duration = @(self.ipodManager.duration);
        } else {
            self.curMusic.duration = @(self.audioManager.duration);
        }
        
        [self.app saveContext];
    }
}

// 先在本地查找歌词文件，找不到的话再到百度音乐找找
- (void)lrcPathWithMusicTitle:(NSString *)title Completion:(Completion)callback
{
    if (title == nil) {
        return;
    }
    
    NSString *lrcName = [title stringByAppendingString:@".lrc"];
    NSFileManager *manager = [NSFileManager defaultManager];
    // 到存放歌词的Lrcs目录下查找
    NSString *formatStr = [[[Utils applicationDocumentsDirectory] stringByAppendingPathComponent:@"Lrcs"] stringByAppendingString:@"/%@"];
    NSString *lrcPath = [NSString stringWithFormat:formatStr, lrcName];
    if ([manager fileExistsAtPath:lrcPath]) {
        callback(lrcPath);
    } else {
        
        NSArray *artistAndTitle = [title componentsSeparatedByString:@" - "];
        NSString *artist = artistAndTitle[0];
        NSString *realTitle = artistAndTitle[1];
        
        // 到天天动听去找找看有没有歌词
        [DongTingUtils searchDongTingLrcWithParams:@{@"artist":artist,@"title":realTitle} Completion:^(id obj){
            if (obj) {
                callback(obj);
            } else {
                
                // 到百度音乐去找找看有没有歌词
                NSString *keyWord = [NSString stringWithFormat:@"%@ %@", artist, realTitle];
                [BaiduMusicUtils searchBaiduLrcWithParams:@{@"key":keyWord} Completion:^(id obj) {
                    NSArray *lrcs = obj;
                    
                    if (lrcs.count == 0) {
                        callback(nil);
                        return;
                    }
                    for (OnlineLrc *lrc in lrcs) {
                        // 歌手 - 歌名 匹配的话就算找到啦，然后试着把歌词下载下来
                        NSString *title2 = [lrc.singer stringByAppendingString:[NSString stringWithFormat:@" - %@", lrc.title]];
                        if ([title caseInsensitiveCompare:title2] == NSOrderedSame) {
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                NSData *lrcData = [NSData dataWithContentsOfURL:[NSURL URLWithString:lrc.lrcUrl]];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (lrcData) {
                                        [lrcData writeToFile:lrcPath atomically:YES];
                                        callback(lrcPath);
                                    }
                                });
                            });
                            break;
                        }
                    }
                }];
            }
        }];
    }
}


- (BOOL)isCustomGroup:(NSString *)name
{
    NSArray *defaultGroups = @[@"Ipod",@"Love",@"Latest",@"Download"];
    if ([defaultGroups containsObject:name]) {
        return NO;
    }
    
    return YES;
}

- (void)removeGroup:(Group *)group
{
    if (group) {
        
        for (Music *music in group.musics) {
            // 歌曲只在当前要删除的组里，直接删除
            if (music.groups.count == 1 && ![music.path hasPrefix:@"Ipod"]) {
                [self.app.managedObjectContext deleteObject:music];
                [[NSFileManager defaultManager] removeItemAtPath:music.path error:nil];
            }
        }
        
        [self.app.managedObjectContext deleteObject:group];
        [self.app saveContext];
        [self loadGroups];
    }
}

@end
