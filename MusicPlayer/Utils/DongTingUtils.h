//
//  DongTingUtils.h
//  MusicPlayer
//
//  Created by amos on 15/4/23.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Completion)(id obj);

@interface DongTingUtils : NSObject

+ (void)requestDongTingTopListsWithCompletion:(Completion)callback;
+ (void)requestDongTingTopListWithParams:(NSDictionary *)params Completion:(Completion)callback;
+ (void)searchDongTingMusicWithParams:(NSDictionary *)params Completion:(Completion)callback;
+ (void)searchDongTingMVWithParams:(NSDictionary *)params Completion:(Completion)callback;
+ (void)searchDongTingLrcWithParams:(NSDictionary *)params Completion:(Completion)callback
;

@end
