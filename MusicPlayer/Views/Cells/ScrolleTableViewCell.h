//
//  ScrolleTableViewCell.h
//  MusicPlayer
//
//  Created by amos on 15-3-31.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrolleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (weak, nonatomic) IBOutlet UILabel *lrcLabel;

@property (nonatomic, strong)NSString *lrc;

@end
