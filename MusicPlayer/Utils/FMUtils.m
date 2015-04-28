//
//  FMUtils.m
//  MusicPlayer
//
//  Created by amos on 15-4-11.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "FMUtils.h"
#import "JsonParser.h"
#import "NSArray+Shuffle.h"

static NSDictionary *settingDict;

@implementation FMUtils

+ (id)objectInSettingDictWithKey:(NSString *)key
{
    if (!settingDict) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FM" ofType:@"plist"];
        settingDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    
    return settingDict[key];
}

+ (NSArray *)douBanChannels
{
    return [FMUtils objectInSettingDictWithKey:@"DouBanChannels"];
}

+ (void)requestDuBanFMMusicsWithChannel:(DouBanChannel)channel Completion:(Completion)callback
{
    NSString *formatePath = [FMUtils objectInSettingDictWithKey:@"DouBanFMMusicsFormatePath"];
    NSString *path = [NSString stringWithFormat:formatePath, channel];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
        
        NSArray *musics = nil;
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            musics = [JsonParser parseDouBanFMMusicsWithDictionary:dict];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            callback(musics);
        });
        
    });
}

+ (NSArray *)baiDuChannels
{
    return [FMUtils objectInSettingDictWithKey:@"BaiDuChannels"];
}

+ (NSString *)baiDuChannelNameForType:(BaiDuChannel)type
{
    NSArray *baiduChs = [FMUtils objectInSettingDictWithKey:@"BaiDuChannels"];
    
    NSDictionary *channelDict = baiduChs[type];
    
    if (!channelDict) {
        return nil;
    }
    
    return channelDict[@(type).stringValue];
}

+ (void)requestBaiDuFMMusicsWithChannel:(BaiDuChannel)channel Completion:(Completion)callback
{
    NSString *formatePath = [FMUtils objectInSettingDictWithKey:@"BaiDuPlayListFormatePath"];
    
    NSString *playListPath = [NSString stringWithFormat:formatePath,[FMUtils baiDuChannelNameForType:channel]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *listData = [NSData dataWithContentsOfURL:[NSURL URLWithString:playListPath]];
        
        if (listData == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:listData options:0 error:nil];
        NSArray *songIds = [JsonParser parseBaiBuFMPlayListWithDictionary:dict];
        // 随机取20首,有可能存在无效的歌曲
        songIds = [songIds bjl_shuffledArrayWithItemLimit:20];
        NSMutableArray *musics = [NSMutableArray array];
        // 9首歌就够了
        int count = songIds.count > 9 ? 9 : (int)songIds.count;
        for (int i = 0; i < songIds.count; i++) {
            [FMUtils requestBaiDuFMMusicWithSongId:songIds[i] Completion:^(id obj) {
                if (obj) {
                    [musics addObject:obj];
                }
                if (musics.count == count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callback(musics);
                    });
                }
            }];
        }
    });
}

+ (void)requestBaiDuFMMusicWithSongId:(NSString *)songId Completion:(Completion)callback
{
    NSString *formatePath = [FMUtils objectInSettingDictWithKey:@"BaiDuFMMusicFormatePath"];
    NSString *songPath = [NSString stringWithFormat:
                      formatePath, songId];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *songData = [NSData dataWithContentsOfURL:[NSURL URLWithString:songPath]];
        OnlineMusic *music = nil;
        if (songData) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:songData options:0 error:nil];
            music = [JsonParser parseBaiBuFMMusicWithDictionary:dict];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(music);
        });
    });
}

@end
