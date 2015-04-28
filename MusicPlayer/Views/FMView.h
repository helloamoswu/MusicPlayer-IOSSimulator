//
//  FMView.h
//  MusicPlayer
//
//  Created by amos on 15-4-2.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *albumIV;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *changeRadioBtn;
@property (weak, nonatomic) IBOutlet UIButton *changeFMBtn;
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;


@end
