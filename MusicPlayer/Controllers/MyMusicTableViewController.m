//
//  MyMusicTableViewController.m
//  TMusic
//
//  Created by amos on 15-2-27.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "MyMusicTableViewController.h"
#import "MusicListTableViewController.h"
#import "MusicGroupTableViewController.h"
#import "Music.h"
#import "PlayView.h"
#import "FMView.h"
#import "Utils.h"
#import "MPManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface MyMusicTableViewController () <UIGestureRecognizerDelegate, MPMediaPickerControllerDelegate>

@property (nonatomic, strong)MPManager *playerManager;
@property (nonatomic, strong)PlayView *headerView;
@property (nonatomic, strong)FMView *footerView;

@property (nonatomic)BOOL isShowPlayView;
@property (nonatomic)BOOL isShowFMView;

@end

@implementation MyMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerManager = [MPManager shareManager];
 
    [self setupUI];
    [self addGesture];
    
    
    UIImageView *splashScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%02d.jpg", arc4random_uniform(9)]]];
    CGRect frame = [UIScreen mainScreen].bounds;
    splashScreen.frame = frame;
    [self.tabBarController.view addSubview:splashScreen];
    [UIView animateWithDuration:3 animations:^{splashScreen.alpha = 0.0;}
                     completion:(void (^)(BOOL)) ^{
                         [splashScreen removeFromSuperview];
                     }
     ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    // 更新播放器的代理，控制权交给playview
    self.playerManager.delegate = self.headerView;
    [self.headerView updateMusicUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupUI{
    
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    self.headerView = [[[NSBundle mainBundle]loadNibNamed:@"PlayView" owner:self options:0] lastObject];
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
    self.headerView.backgroundColor = [UIColor blackColor];
    self.headerView.alpha = 0.6;
    
    [self.view addSubview:self.headerView];
    
    self.footerView = [[[NSBundle mainBundle]loadNibNamed:@"FMView" owner:self options:0] lastObject];
    self.footerView.frame = CGRectMake(0, self.view.frame.size.height - 104, self.view.frame.size.width, 0);
    self.footerView.backgroundColor = [UIColor blackColor];
    self.footerView.alpha = 0.6;

    [self.view addSubview:self.footerView];
    
    // 添加模糊背景
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sky"]];
    bg.frame = self.tableView.frame;
    self.tableView.backgroundView = bg;
    [Utils addBlurToView:self.tableView.backgroundView];

}
// 添加swipe手势
- (void)addGesture
{
    UISwipeGestureRecognizer *swipeDownGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    swipeDownGR.numberOfTouchesRequired = 1;
    swipeDownGR.direction = UISwipeGestureRecognizerDirectionDown;
    [self.tableView addGestureRecognizer:swipeDownGR];
    
    UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    swipeUpGR.numberOfTouchesRequired = 1;
    swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
    [self.tableView addGestureRecognizer:swipeUpGR];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
// 使用swipe手势收起playview或fmview
- (void)swipe:(UISwipeGestureRecognizer *)gr
{
    // 收起playview
    if (gr.direction == UISwipeGestureRecognizerDirectionUp) {
        if (self.tableView.scrollEnabled == NO && self.headerView.frame.size.height > 0) {
            self.tableView.scrollEnabled = YES;
            [self hideView];
        }
    }
    // 收起fmview
    else if (gr.direction == UISwipeGestureRecognizerDirectionDown) {
        if (self.tableView.scrollEnabled == NO && self.footerView.frame.size.height > 0) {
            self.tableView.scrollEnabled = YES;
            [self hideView];
        }
    }
    
}
- (IBAction)importIpodMusics:(UIButton *)sender {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.prompt = @"Select songs to play";
    
    [self presentViewController:mediaPicker animated:YES completion:^{
        
    }];
}
// 收起playview或fmview
- (void)hideView{
    // 重新打开表格的滚动功能
    self.tableView.scrollEnabled = YES;
    // 收起playview
    if (self.isShowPlayView) {
        self.isShowPlayView = NO;
        [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut animations:^{
            // 表格的内容偏移恢复原值
            self.tableView.contentOffset = CGPointMake(0, -64);
            self.headerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.headerView.alpha = 1;
            // 高度置零，避免露出马脚。。。
            CGRect frame = self.headerView.frame;
            frame.size.height = 0;
            self.headerView.frame = frame;
        }];
    }
    // 收起fmview
    else if (self.isShowFMView) {
        self.isShowFMView = NO;
        [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut animations:^{
            self.tableView.contentOffset = CGPointMake(0, -64);
            self.footerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.footerView.alpha = 1;
            CGRect frame = self.footerView.frame;
            frame.size.height = 0;
            self.footerView.frame = frame;
        }];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 4;
    } else {
        return 1;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d首",(int)((NSArray*)self.playerManager.musicsDict[@"Ipod"]).count ];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d首",(int)((NSArray*)self.playerManager.musicsDict[@"Download"]).count ];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d首",(int)((NSArray*)self.playerManager.musicsDict[@"Love"]).count ];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d首",(int)((NSArray*)self.playerManager.musicsDict[@"Latest"]).count ];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        exit(0);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([[UIScreen mainScreen] bounds].size.height > 567) {
            return 60;
        } else {
            return 48;
        }
    } else {
        return 50;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.contentOffset = CGPointMake(0, -64);
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (self.isShowPlayView) {
        self.tableView.scrollEnabled = NO;
        scrollView.contentOffset = CGPointMake(0, -144);
        self.headerView.frame = CGRectMake(0, -80, self.headerView.frame.size.width, 80);
        return;
    } else if (self.isShowFMView) {
        self.tableView.scrollEnabled = NO;
        scrollView.contentOffset = CGPointMake(0, 24);
        self.footerView.frame = CGRectMake(0, self.footerView.frame.origin.y, self.footerView.frame.size.width, 80);
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < -144) {
        self.isShowPlayView = YES;
        return;
    } else if (offsetY > 16) {
        self.isShowFMView = YES;
        return;
    }
    if (offsetY < -64) {
        CGRect frame = self.headerView.frame;
        frame.size.height = -(scrollView.contentOffset.y + 64);
        frame.origin.y = scrollView.contentOffset.y + 64;
        self.headerView.frame = frame;
    } else if (offsetY > -64) {
        CGRect frame = self.footerView.frame;
        frame.size.height = (scrollView.contentOffset.y + 64);
        self.footerView.frame = frame;
    }
    
    if (CGPointEqualToPoint(self.tableView.contentOffset, CGPointMake(0, -64))) {
        self.headerView.alpha = 0;
        self.footerView.alpha = 0;
    } else {
        self.headerView.alpha = 1;
        self.footerView.alpha = 1;
    }
    
    //NSLog(@"%@", NSStringFromCGPoint(self.tableView.contentOffset));
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MusicListTableViewController *vc = [segue destinationViewController];
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"GoToAllMusicsTableViewSegue"]) {
        //self.playerManager.curMusics = self.playerManager.musicsDict[@"all"];
        self.playerManager.curViewGroup = @"Ipod";
        
        vc.title = @"Ipod";
        vc.cellColor = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].backgroundColor;
    } else  if ([identifier isEqualToString:@"GoToLoveMusicsTableViewSegue"]) {
        //self.playerManager.curMusics = self.playerManager.musicsDict[@"love"];
        self.playerManager.curViewGroup = @"Love";
        vc.title = @"Love";
        vc.cellColor = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].backgroundColor;
    } else  if ([identifier isEqualToString:@"GoToLatestMusicsTableViewSegue"]) {
        //self.playerManager.curMusics = self.playerManager.musicsDict[@"latest"];
        self.playerManager.curViewGroup = @"Latest";
        vc.title = @"Latest";
        vc.cellColor = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]].backgroundColor;
    } else if ([identifier isEqualToString:@"GoToDownloadMusicsTableViewSegue"]) {
        //self.playerManager.curMusics = self.playerManager.musicsDict[@"download"];
        self.playerManager.curViewGroup = @"Download";
        vc.title = @"Download";
        vc.cellColor = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]].backgroundColor;
    }else if ([identifier isEqualToString:@"GoToMusicGroupTableViewSegue"]) {
        MusicGroupTableViewController *vc = segue.destinationViewController;
        vc.cellColor = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]].backgroundColor;
    }
}

// 手动添加ipod library中的歌曲
// 本程序没有使用
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    for (int i = 0; i < [mediaItemCollection.items count]; i++) {
        
        [self exportAssetAsSourceFormat:[[mediaItemCollection items] objectAtIndex:i]];
    }
    
    [self dismissViewControllerAnimated:YES completion: nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion: nil];
}

- (void)exportAssetAsSourceFormat:(MPMediaItem *)item {
    
    NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    if(assetURL != nil &&  ![assetURL isKindOfClass:[NSNull class]])
    {
        //NSString *songTitle = [item valueForProperty:MPMediaItemPropertyTitle];
        
    }
    
}


@end
