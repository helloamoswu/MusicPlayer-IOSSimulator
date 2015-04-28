//
//  JsonParser.m
//  MusicPlayer
//
//  Created by amos on 15-4-2.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "JsonParser.h"
#import "OnlineMusic.h"
#import "DongTingTopList.h"

#define DEFAULT_RATE 128

@implementation JsonParser

+ (NSArray *)parseDouBanFMMusicsWithDictionary:(NSDictionary *)dic
{
    NSArray *results = dic[@"song"];
    NSMutableArray *musics = [NSMutableArray array];
    if (results && [results isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *mDic in results) {
            
            if ([mDic[@"length"] intValue] < 50) {
                continue;
            }
            
            OnlineMusic *m = [[OnlineMusic alloc]init];
            m.title = mDic[@"title"];
            m.musicUrl = mDic[@"url"];
            m.albumUrl = mDic[@"picture"];
            m.singer = mDic[@"artist"];
            m.duration = [mDic[@"length"] intValue];
            [musics addObject:m];
            // 9首歌就够了
            if (musics.count == 9) {
                break;
            }
        }
        
    }
    
    return musics;
}

+ (NSArray *)parseBaiBuFMPlayListWithDictionary:(NSDictionary *)dic
{
    NSArray *lists = dic[@"list"];
    NSMutableArray *songIds = [NSMutableArray array];
    if (lists && [lists isKindOfClass:[NSArray class]]) {
        for (NSDictionary *listDic in lists) {
            NSString *songId = listDic[@"id"];
            [songIds addObject:songId];
        }
    }
    
    return songIds;
}

+ (OnlineMusic *)parseBaiBuFMMusicWithDictionary:(NSDictionary *)dic
{
    NSDictionary *data = dic[@"data"];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *songDict = [data[@"songList"] firstObject];
        OnlineMusic *music = [[OnlineMusic alloc] init];
        music.title = songDict[@"songName"];
        music.singer = songDict[@"artistName"];
        music.duration = [songDict[@"time"] intValue];
        music.musicUrl = songDict[@"songLink"];
        music.albumUrl = songDict[@"songPicBig"];
        
        return music;
    }
    
    return nil;
}

+ (NSArray *)parseDongTingTopListWithDictionary:(NSDictionary *)dic
{
    NSArray *lists = dic[@"data"];
    NSMutableArray *topLists = [NSMutableArray array];
    if (lists && [lists isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in lists) {
            DongTingTopList *topList = [[DongTingTopList alloc]init];
            topList.idStr = dict[@"id"];
            topList.title = dict[@"title"];
            topList.picUrl = dict[@"pic_url"];
            
            [topLists addObject:topList];
        }
        
    }
    return topLists;
}

+ (NSArray *)parseDongTingSongListWithDictionary:(NSDictionary *)dic
{
    NSArray *lists = dic[@"data"];
    NSMutableArray *songLists = [NSMutableArray array];
    if (lists && [lists isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in lists) {
            OnlineMusic *music = [[OnlineMusic alloc]init];
            music.sid = dict[@"song_id"];
            music.title = dict[@"song_name"];
            music.singer = dict[@"singer_name"];
            music.rate = DEFAULT_RATE;
            NSArray *urlList = dict[@"url_list"];
            NSMutableDictionary *rateDict = [NSMutableDictionary dictionary];
            for (NSDictionary *urlDict in urlList) {
                
                if (!music.duration) {
                    NSString *durationStr = urlDict[@"duration"];
                    NSArray *durations = [durationStr componentsSeparatedByString:@":"];
                    int duration = 0;
                    int scale = 1;
                    for (int i = (int)durations.count - 1; i >= 0; i--) {
                        duration += [durations[i] intValue] * scale;
                        scale *= 60;
                    }
                    music.duration = duration;
                }
                
                
                NSString *format = urlDict[@"format"];
                if ([format isEqualToString:@"mp3"]) {
                    
                    NSNumber *rate = urlDict[@"bitrate"];
                    rateDict[rate] = @{@"url":urlDict[@"url"], @"format":format};
                    
                    if ([rate intValue] == DEFAULT_RATE) {
                        music.musicUrl = urlDict[@"url"];
                    }
                }
            }
            
            urlList = dict[@"ll_list"];
            if (urlList) {
                for (NSDictionary *urlDict in urlList) {
                    
                    // BASS提供了ape的静态库，但死活导不进来，哎
                    if ([urlDict[@"format"] isEqualToString:@"ape"] ) {
                        continue;
                    }
                    
                    NSNumber *rate = urlDict[@"bitrate"];
                    rateDict[rate] = @{@"url":urlDict[@"url"], @"format":urlDict[@"format"]};
                }
            }
            
            if (rateDict.allKeys.count == 0) {
                continue;
            }
            
            music.rateUrlDict = rateDict;
            [songLists addObject:music];
        }
    }
    
    return songLists;
}

+ (NSArray *)parseDongTingSongMvListWithDictionary:(NSDictionary *)dic
{
    NSArray *lists = dic[@"data"];
    NSMutableArray *songMvLists = [NSMutableArray array];
    if (lists && [lists isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in lists) {
            OnlineMusic *music = [[OnlineMusic alloc]init];
            music.sid = dict[@"song_id"];
            music.title = dict[@"song_name"];
            music.singer = dict[@"singer_name"];
            NSArray *mvList = dict[@"mv_list"];
            NSMutableArray *mvs = [NSMutableArray array];
            for (NSDictionary *mvDict in mvList) {
                NSMutableDictionary *mvInfo = [NSMutableDictionary dictionary];
                if (!music.duration) {
                    NSString *durationStr = mvDict[@"duration"];
                    NSArray *durations = [durationStr componentsSeparatedByString:@":"];
                    int duration = 0;
                    int scale = 1;
                    for (int i = (int)durations.count - 1; i >= 0; i--) {
                        duration += [durations[i] intValue] * scale;
                        scale *= 60;
                    }
                    music.duration = duration;
                }
                mvInfo[@"type"] = mvDict[@"type_description"];
                mvInfo[@"url"] = mvDict[@"url"];
                
                [mvs addObject:mvInfo];
            }
            
            if (mvs.count == 0) {
                continue;
            }
            
            music.mvList = mvs;
            [songMvLists addObject:music];
        }
    }
    
    return songMvLists;
}

@end
