//
//  DongTingUtils.m
//  MusicPlayer
//
//  Created by amos on 15/4/23.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "DongTingUtils.h"
#import "AFNetworking.h"
#import "JsonParser.h"
#import "Utils.h"

static NSMutableDictionary *settingDict;

@implementation DongTingUtils

+ (id)objectInSettingDictWithKey:(NSString *)key
{
    if (!settingDict) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DongTing" ofType:@"plist"];
        settingDict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
    }
    
    return settingDict[key];
}

+ (void)requestDongTingTopListsWithCompletion:(Completion)callback
{
    NSString *path = [DongTingUtils objectInSettingDictWithKey:@"MusicPath"];
    NSString *topListId = [DongTingUtils objectInSettingDictWithKey:@"TopListId"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    [manager GET:path parameters:@{@"id":topListId} success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (responseObject) {
            NSDictionary *topListDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            NSArray *topLists = [JsonParser parseDongTingTopListWithDictionary:topListDict];
            callback(topLists);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"DongTing:获取榜单失败");
        callback(nil);
    }];
}

+ (void)requestDongTingTopListWithParams:(NSDictionary *)params Completion:(Completion)callback
{
    NSString *path = [DongTingUtils objectInSettingDictWithKey:@"MusicPath"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    [manager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject) {
             NSDictionary *songListDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
             NSArray *songLists = [JsonParser parseDongTingSongListWithDictionary:songListDict];
             callback(songLists);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"DongTing:获取榜单失败");
         callback(nil);
     }];
}

+ (void)searchDongTingMusicWithParams:(NSDictionary *)params Completion:(Completion)callback
{
    NSString *path = [DongTingUtils objectInSettingDictWithKey:@"SearchPath"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    [manager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject) {
             NSDictionary *songListDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
             NSArray *songLists = [JsonParser parseDongTingSongListWithDictionary:songListDict];
             callback(songLists);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"DongTing:搜索失败");
         callback(nil);
     }];
}

+ (void)searchDongTingMVWithParams:(NSDictionary *)params Completion:(Completion)callback
{
    NSString *path = [DongTingUtils objectInSettingDictWithKey:@"SearchPath"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    [manager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject) {
             NSDictionary *songListDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
             NSArray *songMvLists = [JsonParser parseDongTingSongMvListWithDictionary:songListDict];
             callback(songMvLists);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"DongTing:搜索失败");
         callback(nil);
     }];
}

+ (void)searchDongTingLrcWithParams:(NSDictionary *)params Completion:(Completion)callback
{
    NSString *path = [DongTingUtils objectInSettingDictWithKey:@"LrcPath"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    [manager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject) {
             NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
             NSDictionary *lrcDict = resultDict[@"data"];
             if (lrcDict && [lrcDict isKindOfClass:[NSDictionary class]]) {
                 NSString *lrcStr = lrcDict[@"lrc"];
                 if (lrcDict) {
                     NSString *formatStr = [[[Utils applicationDocumentsDirectory]
                                             stringByAppendingPathComponent: @"Lrcs"] stringByAppendingString:@"/%@ - %@.lrc"];
                     NSString *savePath = [NSString stringWithFormat:formatStr, params[@"artist"], params[@"title"]];
                     [lrcStr writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                     
                     callback(savePath);
                     return;
                 }
             }
         }
         callback(nil);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"DongTing:搜索失败");
         callback(nil);
     }];
}

@end
