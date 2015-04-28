//
//  FMUtils.h
//  MusicPlayer
//
//  Created by amos on 15-4-11.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^Completion) (id obj);

#define CHANNEL_COUNT 17
typedef enum DouBanChannel
{
    DBHUAYU = 1,
    DBOUMEI = 2,
    DB80 = 4,
    DB90 = 5,
    DBYUEYU = 6,
    DBROCK = 7,
    DBFOLK = 8,
    DBSOFT = 9,
    DBMOVIE = 10,
    DBCOFFEE = 32,
    DBJAZE = 13,
    DBELECTRON = 14,
    DBNEW = 61,
    DBFRESH = 76,
    DBWORKSTUDY = 153,
    DBCLASSIC = 187,
    DBBILLBOARD = 1000559
}DouBanChannel;

typedef enum BaiDuChannel
{
    BDSUIBIAN,
    BDOUMEI,
    BDCLASSIC,
    BDDJ,
    BDREGE,
    BDNET,
    BDCHENGMINGQU,
    BDNEW,
    BDPOP,
    BDHAPPY,
    BDKTV,
    BDSAD,
    BD80,
    BD90
}BaiDuChannel;

typedef enum FMSource
{
    DOUBAN,
    BAIDU
}FMSource;

@interface FMUtils : NSObject

+ (NSArray *)douBanChannels;
+ (void)requestDuBanFMMusicsWithChannel:(DouBanChannel)channel Completion:(Completion)callback;
+ (NSArray *)baiDuChannels;
+ (void)requestBaiDuFMMusicsWithChannel:(BaiDuChannel)channel Completion:(Completion)callback;
+ (id)objectInSettingDictWithKey:(NSString *)key;

@end
