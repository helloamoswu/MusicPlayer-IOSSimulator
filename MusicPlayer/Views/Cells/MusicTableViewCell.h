//
//  MusicTableViewCell.h
//  MusicPlayer
//
//  Created by amos on 15-3-24.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Music.h"

@interface MusicTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *albumIV;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (nonatomic, strong)Music *music;

@end
