//
//  TopListViewController.m
//  MusicPlayer
//
//  Created by amos on 15-4-9.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "TopListViewController.h"
#import "BaiDuTopListTableViewController.h"
#import "DongTingTopListTableViewController.h"
#import "Utils.h"
#import "BaiduMusicUtils.h"
#import "DongTingUtils.h"
#import "DongTingTopList.h"
#import "UIButton+AFNetworking.h"

@interface TopListViewController ()

@property (nonatomic, strong)UIScrollView *baiDuTopListSV;
@property (nonatomic, strong)UIScrollView *dongTingTopListSV;
@property (weak, nonatomic) IBOutlet UISegmentedControl *topListSegment;
@property (nonatomic)BOOL isRefresh;

@end

@implementation TopListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createBaiDuTopListView];
    [self createDongTingTopListView];
    
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sky"]];
    bg.frame = self.view.frame;
    [self.view insertSubview:bg atIndex:0];
    [Utils addBlurToView:bg];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBaiDuTopListView
{
    CGRect frame = self.view.frame;
    frame.origin.y += self.topListSegment.frame.size.height + 10 + 64;
    self.baiDuTopListSV = [[UIScrollView alloc]initWithFrame:frame];
    self.baiDuTopListSV.backgroundColor = [UIColor clearColor];
    
    NSDictionary *topList = [BaiduMusicUtils topList];
    NSArray *types = topList.allKeys;
    float width = self.baiDuTopListSV.frame.size.width;
    float itemWidth = (width - 10 - 20)/3;
    for (int i = 0; i < topList.count; i++) {
        NSDictionary *dict = topList[types[i]];
        int type = [types[i] intValue];
        NSString *name = dict[@"name"];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(5 + (i%3) * (itemWidth+10), 10 + (i/3) * 60, itemWidth, 50);
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag = type;
        [btn addTarget:self action:@selector(baiDuTopListClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.baiDuTopListSV addSubview:btn];
        
    }
    
    [self.view addSubview:self.baiDuTopListSV];
}

- (void)createDongTingTopListView
{
    CGRect frame = self.view.frame;
    frame.origin.y += self.topListSegment.frame.size.height + 10 + 64;
    self.dongTingTopListSV = [[UIScrollView alloc]initWithFrame:frame];
    self.dongTingTopListSV.backgroundColor = [UIColor clearColor];
    self.dongTingTopListSV.hidden = YES;
    self.dongTingTopListSV.alpha = 0;
    [self.view addSubview:self.dongTingTopListSV];
    
    [DongTingUtils requestDongTingTopListsWithCompletion:^(id obj) {
        
        NSArray *topLists = obj;
        if (!topLists || topLists.count == 0) {
            UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            refreshBtn.frame = CGRectMake(self.view.frame.size.width/2 - 25, self.dongTingTopListSV.frame.size.height/2 - 100, 50, 30);
            [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [refreshBtn setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
            [refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
            [refreshBtn addTarget:self action:@selector(refreshDongTingTopList:) forControlEvents:UIControlEventTouchUpInside];
            [self.dongTingTopListSV addSubview:refreshBtn];
            
        } else {
            float width = self.dongTingTopListSV.frame.size.width;
            float itemWidth = (width - 10 - 20)/3;
            for (int i = 0; i < topLists.count; i++) {
                DongTingTopList *list = topLists[i];
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                btn.frame = CGRectMake(5 + (i%3) * (itemWidth+10), 10 + (i/3) * (itemWidth+10), itemWidth, itemWidth);
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:list.picUrl]];
                btn.tag = [list.idStr integerValue];
                [btn addTarget:self action:@selector(dongTingTopListClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.dongTingTopListSV addSubview:btn];
                
                if (i == topLists.count - 1) {
                    self.dongTingTopListSV.contentSize = CGSizeMake(width, btn.frame.origin.y + itemWidth*3);
                }
            }
        }
    }];
}

- (void)refreshDongTingTopList:(UIButton *)sender
{
    [self.dongTingTopListSV removeFromSuperview];
    self.dongTingTopListSV = nil;
    [self createDongTingTopListView];
    self.dongTingTopListSV.hidden = NO;
    self.dongTingTopListSV.alpha = 1;
}

- (IBAction)topListSourceChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.baiDuTopListSV.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.baiDuTopListSV.alpha = 1;
            self.dongTingTopListSV.alpha = 0;
        } completion:^(BOOL finished) {
            self.dongTingTopListSV.hidden = YES;
        }];
    } else {
        self.dongTingTopListSV.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.baiDuTopListSV.alpha = 0;
            self.dongTingTopListSV.alpha = 1;
        } completion:^(BOOL finished) {
            self.baiDuTopListSV.hidden = YES;
        }];
    }
}


- (void)baiDuTopListClicked:(UIButton *)sender
{
    // 跳到歌手榜单
    if (sender.tag == SINGER) {
        [self performSegueWithIdentifier:@"GoToArtistTableViewSegue" sender:nil];
    }
    // 跳到其他榜单
    else {
        [self performSegueWithIdentifier:@"GoBaiDuToTopListViewSegue" sender:@(sender.tag)];
    }
}

- (void)dongTingTopListClicked:(UIButton *)sender
{
    NSString *idStr = @(sender.tag).stringValue;
    
    [self performSegueWithIdentifier:@"GoToDongTingTopListTableViewSegue" sender:idStr];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoBaiDuToTopListViewSegue"]) {
        BaiDuTopListTableViewController *vc = segue.destinationViewController;
        vc.type = [sender intValue];
        vc.hidesBottomBarWhenPushed = YES;
    } else if ([segue.identifier isEqualToString:@"GoToDongTingTopListTableViewSegue"]) {
        DongTingTopListTableViewController *vc = segue.destinationViewController;
        vc.idStr = sender;
        vc.hidesBottomBarWhenPushed = YES;
    }
}

@end
