//
//  PathTableViewCell.m
//  MusicPlayer
//
//  Created by amos on 15-4-13.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "PathTableViewCell.h"

@implementation PathTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)returnClicked:(id)sender {
    [sender resignFirstResponder];
}


@end
