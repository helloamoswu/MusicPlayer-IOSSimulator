//
//  BaiduMusicUtils.h
//  MusicPlayer
//
//  Created by amos on 15-4-12.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>

// 默认下载的音乐品质是128kbp
#define DEFAULT_RATE 128

typedef enum TopListType
{
    SEARCH = 0,
    HOT,
    NEW,
    HUAYU,
    OUMEI,
    NET,
    CLASSIC,
    ROCK,
    MOVIE,
    BILLBOARD,
    UK,
    LOVE,
    KTV,
    SINGER
}TopListType;

typedef void (^Completion) (id obj);

@interface BaiduMusicUtils : NSObject

+ (void)searchBaiduLrcWithParams:(NSDictionary *)params Completion:(Completion)callback;
+ (void)searchBaiduMusicWithType:(TopListType)type andParams:(NSDictionary *)params Completion:(Completion)callback;
+(void) searchSingerWithParams:(NSDictionary *)params Completion:(Completion)callback;
+ (NSString *)nameWithTopListType:(TopListType)type;
+ (NSDictionary *)topList;

@end
