//
//  JsonParser.h
//  MusicPlayer
//
//  Created by amos on 15-4-2.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OnlineMusic;

@interface JsonParser : NSObject

+ (NSArray *)parseDouBanFMMusicsWithDictionary:(NSDictionary *)dic;
+ (NSArray *)parseBaiBuFMPlayListWithDictionary:(NSDictionary *)dic;
+ (OnlineMusic *)parseBaiBuFMMusicWithDictionary:(NSDictionary *)dic;
+ (NSArray *)parseDongTingTopListWithDictionary:(NSDictionary *)dic;
+ (NSArray *)parseDongTingSongListWithDictionary:(NSDictionary *)dic;
+ (NSArray *)parseDongTingSongMvListWithDictionary:(NSDictionary *)dic;

@end

