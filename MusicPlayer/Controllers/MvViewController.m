//
//  MvViewController.m
//  MusicPlayer
//
//  Created by amos on 15/4/23.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "MvViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Utils.h"
#import "PlayerManagerUtils.h"

@interface MvViewController ()

@property (nonatomic, strong)MPMoviePlayerController *player;

@end

@implementation MvViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PlayerManagerUtils pauseAllPlayerExcept:nil];
    
    // 添加模糊背景
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sky"]];
    bg.frame = self.view.frame;
    [self.view insertSubview:bg atIndex:0];
    [Utils addBlurToView:bg];
    
    NSURL *url = [NSURL URLWithString:self.mvUrl];
    self.player = [[MPMoviePlayerController alloc]initWithContentURL:url];
    
    self.player.view.frame = CGRectMake(0, 100, self.view.frame.size.width, 200);
    [self.view addSubview:self.player.view];
    
    [self.player setControlStyle:MPMovieControlStyleDefault];
    [self.player play];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
