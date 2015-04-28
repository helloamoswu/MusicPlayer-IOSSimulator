//
//  PlayView.h
//  MusicPlayer
//
//  Created by amos on 15-4-1.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPManager.h"

@interface PlayView : UIView <MPManagerDelegate>

- (void)updateMusicUI;

@end

