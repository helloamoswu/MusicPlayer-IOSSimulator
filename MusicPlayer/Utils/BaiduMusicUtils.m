//
//  BaiduMusicUtils.m
//  MusicPlayer
//
//  Created by amos on 15-4-12.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "BaiduMusicUtils.h"
#import "TFHpple.h"
#import "OnlineMusic.h"
#import "OnlineLrc.h"
#import "JsonParser.h"
#import "Artist.h"

static NSMutableDictionary *settingDict;

@implementation BaiduMusicUtils

+ (id)objectInSettingDictWithKey:(NSString *)key
{
    if (!settingDict) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"BaiDuMusic" ofType:@"plist"];
        settingDict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
    }
    
    return settingDict[key];
}

+ (void)searchBaiduMusicTopArtistWithCompletion:(Completion)callback;
{
    NSString *path = [BaiduMusicUtils pathWithTopListType:SINGER];
    
    NSString *xPath1 = [BaiduMusicUtils objectInSettingDictWithKey:@"TopArtistXPath1"];
    NSString *xPath2 = [BaiduMusicUtils objectInSettingDictWithKey:@"TopArtistXPath2"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSData *data = [NSData  dataWithContentsOfURL:[NSURL URLWithString:path]];
        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:data];
        NSArray *musicNodes = [htmlParser searchWithXPathQuery:xPath1];
        NSMutableArray *artists = [NSMutableArray array];
        for (TFHppleElement *element in musicNodes) {
            @try {
                NSString *href = [element objectForKey:@"href"];
                NSString *url = [@"http://music.baidu.com" stringByAppendingString:href];
                NSString *name = [element objectForKey:@"title"];
                
                Artist *artist = [[Artist alloc]init];
                
                artist.url = url;
                artist.name = name;
                
                [artists addObject:artist];
            }
            @catch (NSException *exception) {}@finally {}
        }
        
        musicNodes = [htmlParser searchWithXPathQuery:xPath2];
        for (TFHppleElement *element in musicNodes) {
            @try {
                NSString *href = [element objectForKey:@"href"];
                NSString *url = [@"http://music.baidu.com" stringByAppendingString:href];
                NSString *name = element.text;
                
                Artist *artist = [[Artist alloc]init];
                
                artist.url = url;
                artist.name = name;
                
                [artists addObject:artist];
            }
            @catch (NSException *exception) {}@finally {}
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(artists);
        });
        
    });
}

+ (NSString *)pathSerializerWithPath:(NSString *)path andParam:(NSDictionary *)params
{
    NSMutableArray *paramsArr = [NSMutableArray array];
    for (NSString *key in params.allKeys) {
        [paramsArr addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    path = [path stringByAppendingString:[paramsArr componentsJoinedByString:@"&"]];
    
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return path;
}

+ (void)searchBaiduMusicWithType:(TopListType)type andParams:(NSDictionary *)params Completion:(Completion)callback;
{
    NSString *path = [BaiduMusicUtils pathWithTopListType:type];
    NSString *xPath;
    if (type != SEARCH) {
        // 新歌榜
        if (type == NEW) {
            xPath = [BaiduMusicUtils objectInSettingDictWithKey:@"TopNewXPath"];
        }
        // 歌手榜
        else if (type == SINGER) {
            [BaiduMusicUtils searchBaiduMusicTopArtistWithCompletion:^(id obj) {
                callback(obj);
            }];
            return;
        }
        // 其他榜单
        else {
            xPath = [BaiduMusicUtils objectInSettingDictWithKey:@"TopOtherXPath"];
        }
        
    }
    // 搜索
    else {
        xPath = [BaiduMusicUtils objectInSettingDictWithKey:@"SearchMusicXPath"];
        
        path = [BaiduMusicUtils pathSerializerWithPath:path andParam:params];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData  dataWithContentsOfURL:[NSURL URLWithString:path]];
        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:data];
        NSArray *musicNodes = [htmlParser searchWithXPathQuery:xPath];
        NSMutableArray *musics = [NSMutableArray array];
        NSString *formateStr = [BaiduMusicUtils objectInSettingDictWithKey:@"MusicPath"];
        for (TFHppleElement *element in musicNodes) {
            @try {
                OnlineMusic *music = [[OnlineMusic alloc]init];
                NSString *songItem = [element objectForKey:@"data-songitem"];
                NSDictionary *songDict = [NSJSONSerialization JSONObjectWithData:[songItem dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                songDict = songDict[@"songItem"];
                music.sid = songDict[@"sid"];
                music.title = [BaiduMusicUtils removeEmTagWithStr:songDict[@"sname"]];
                music.singer = [BaiduMusicUtils removeEmTagWithStr:songDict[@"author"]];
                music.musicUrl = [NSString stringWithFormat:formateStr, music.sid];
                music.rate = DEFAULT_RATE;
                
                [musics addObject:music];
            }
            @catch (NSException *exception) {
                NSLog(@"搜索:出错啦");
            }
            @finally {}
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(musics);
        });
    });
}

+(void) searchSingerWithParams:(NSDictionary *)params Completion:(Completion)callback;
{
    NSString *path = [BaiduMusicUtils objectInSettingDictWithKey:@"SearchPath"];
    NSString *xPath;
    // 搜索歌手时，第一页与其他页内容有点不同，导致歌曲的xPath不太一样
    BOOL isFirstLoad = [params[@"start"] isEqualToString:@"0"];
    if (isFirstLoad) {
        xPath = [BaiduMusicUtils objectInSettingDictWithKey:@"SearchSingerFirstPageXPath"];
    } else {
        xPath = [BaiduMusicUtils objectInSettingDictWithKey:@"SearchSingerOtherPageXPath"];
    }
    
    path = [BaiduMusicUtils pathSerializerWithPath:path andParam:params];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData  dataWithContentsOfURL:[NSURL URLWithString:path]];
        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:data];
        NSArray *musicNodes = [htmlParser searchWithXPathQuery:xPath];
        NSMutableArray *musics = [NSMutableArray array];
        NSString *formateStr = [BaiduMusicUtils objectInSettingDictWithKey:@"MusicPath"];
        for (TFHppleElement *element in musicNodes) {
            @try {
                OnlineMusic *music = [[OnlineMusic alloc]init];
                NSString *songItem = [element objectForKey:@"data-songitem"];
                NSDictionary *songDict = [NSJSONSerialization JSONObjectWithData:[songItem dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                songDict = songDict[@"songItem"];
                music.sid = songDict[@"sid"];
                NSString *title = [BaiduMusicUtils removeEmTagWithStr:songDict[@"sname"]];
                title = [BaiduMusicUtils removeParenthesesWithStr:title];
                if (title.length == 0) {
                    continue;
                }
                
                music.title = title;
                NSString *author = [BaiduMusicUtils removeEmTagWithStr:songDict[@"author"]];
                music.singer = author;
                
                if (author.length == 0) {
                    continue;
                }
                
                music.musicUrl = [NSString stringWithFormat:formateStr, music.sid];
                music.rate = DEFAULT_RATE;
                
                [musics addObject:music];
            }
            @catch (NSException *exception) {
                NSLog(@"歌手:获取歌曲错误");
            }
            @finally {}
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(musics);
        });
    });
}

+ (void)searchBaiduLrcWithParams:(NSDictionary *)params Completion:(Completion)callback;
{
    NSString *path = [BaiduMusicUtils objectInSettingDictWithKey:@"LrcPath"];
    path = [BaiduMusicUtils pathSerializerWithPath:path andParam:params];
    
    NSString *xPath = [BaiduMusicUtils objectInSettingDictWithKey:@"LrcXPath"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSData *data = [NSData  dataWithContentsOfURL:[NSURL URLWithString:path]];
        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:data];
        NSArray *lrcNodes = [htmlParser searchWithXPathQuery:xPath];
        NSMutableArray *lrcs = [NSMutableArray array];
        for (TFHppleElement *element in lrcNodes) {
            @try {
                OnlineLrc *lrc = [[OnlineLrc alloc]init];
                TFHppleElement *songContentElement = [element childrenWithClassName:@"song-content"][0];
                
                TFHppleElement *songIdElement = [[songContentElement childrenWithClassName:@"fun-icon"][0] childrenWithClassName:@"music-icon-hook"][0];
                NSString *dataMusicicon = [songIdElement objectForKey:@"data-musicicon"];
                NSDictionary *songDict = [NSJSONSerialization JSONObjectWithData:[dataMusicicon dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                lrc.sid = songDict[@"id"];
                //lrc.musicUrl = [NSString stringWithFormat:@"http://music.baidu.com/data/music/file?link=&song_id=%@", lrc.sid];
                
                TFHppleElement *titleElement = [songContentElement childrenWithClassName:@"song-title"][0];
                lrc.title = [[titleElement childrenWithTagName:@"a"][0] objectForKey:@"title"];
                
                TFHppleElement *authorElement = [songContentElement childrenWithClassName:@"artist-title"][0];
                lrc.singer = [[authorElement childrenWithTagName:@"span"][0] objectForKey:@"title"];
                
                TFHppleElement *lrcContentElement = [element childrenWithClassName:@"lrc-content"][0];
                lrcContentElement = [lrcContentElement childrenWithClassName:@"lyric-action"][0];
                NSString *text = [[lrcContentElement childrenWithTagName:@"a"][0] objectForKey:@"class"];
                text = [[text componentsSeparatedByString:@":"] lastObject];
                text = [text componentsSeparatedByString:@"'"][1];
                lrc.lrcUrl = [@"http://music.baidu.com" stringByAppendingString:text];
                
                [lrcs addObject:lrc];
            }
            @catch (NSException *exception) {
                NSLog(@"歌词:获取歌词错误");
            }
            @finally {}
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(lrcs);
        });
    });
}

+ (NSString *)pathWithTopListType:(TopListType)type
{
    if (type == SEARCH) {
        return [BaiduMusicUtils objectInSettingDictWithKey:@"SearchPath"];
    }
    NSDictionary *topListDict = [BaiduMusicUtils objectInSettingDictWithKey:@"topLists"];
    return topListDict[@(type).stringValue][@"path"];
}

+ (NSString *)nameWithTopListType:(TopListType)type
{
    if (type == SEARCH) {
        return @"";
    }
    NSDictionary *topListDict = [BaiduMusicUtils objectInSettingDictWithKey:@"topLists"];
    return topListDict[@(type).stringValue][@"name"];
}

+ (NSDictionary *)topList
{
    return [BaiduMusicUtils objectInSettingDictWithKey:@"topLists"];;
}

+ (NSString *)removeEmTagWithStr:(NSString *)str
{
    // 判断有没有<em></em>，有的话去掉
    if ([str containsString:@"<em>"]) {
        str = [[[str substringFromIndex:4] componentsSeparatedByString:@"</em>"]firstObject];
    }
    // 如果还有<em>,用空字符串代替
    if ([str containsString:@"<em>"]) {
        str = [str stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
    }
    // 如果还有em>,用空字符串代替
    if ([str containsString:@"em>"]) {
        str = [str stringByReplacingOccurrencesOfString:@"em>" withString:@""];
    }
    
    return str;
}

+ (NSString *)removeParenthesesWithStr:(NSString *)str
{
    // 判断有没有()，用空字符串代替
    if ([str containsString:@"( )"]) {
        str = [str stringByReplacingOccurrencesOfString:@"( )" withString:@""];
    }
    
    return str;
}

@end
