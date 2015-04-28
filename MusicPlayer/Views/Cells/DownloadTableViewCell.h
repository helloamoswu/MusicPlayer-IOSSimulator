//
//  DownloadTableViewCell.h
//  MusicPlayer
//
//  Created by amos on 15-4-3.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnlineMusic.h"

@interface DownloadTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UIButton *qualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIImageView *checkIV;


@property (strong, nonatomic)UIScrollView *qualitySV;

@property (nonatomic, strong)OnlineMusic *music;

@end
