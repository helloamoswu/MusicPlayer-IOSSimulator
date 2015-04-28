//
//  DownloadTaskTableViewCell.h
//  MusicPlayer
//
//  Created by amos on 15-4-7.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadTaskTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UIButton *processBtn;
@property (weak, nonatomic) IBOutlet UILabel *processLabel;


@end
