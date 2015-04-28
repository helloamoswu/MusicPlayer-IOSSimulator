//
//  OnlineMusic.h
//  MusicPlayer
//
//  Created by amos on 15-3-29.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnlineMusic : NSObject

@property (nonatomic ,strong)NSString *sid;
@property (nonatomic ,strong)NSString *title;
@property (nonatomic ,strong)NSString *singer;
@property (nonatomic, strong)NSString *musicUrl;
@property (nonatomic, strong)NSString *albumUrl;
@property (nonatomic)int duration;
@property (nonatomic)int rate;
// 以下两个属性主要针对天天动听的数据
// 不同码率的链接，格式等信息
@property (nonatomic, strong)NSDictionary *rateUrlDict;
// mv列表信息
@property (nonatomic, strong)NSArray *mvList;

@end
