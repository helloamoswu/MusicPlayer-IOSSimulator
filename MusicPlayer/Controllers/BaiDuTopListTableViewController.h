//
//  TopListTableViewController.h
//  MusicPlayer
//
//  Created by amos on 15-4-14.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduMusicUtils.h"



@interface BaiDuTopListTableViewController : UITableViewController

@property (nonatomic)TopListType type;
@property (nonatomic, strong)NSString *keyWord;

@end
