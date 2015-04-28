//
//  BaiDuTopListTableViewController.m
//  MusicPlayer
//
//  Created by amos on 15-4-14.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "BaiDuTopListTableViewController.h"
#import "DownloadTableViewCell.h"
#import "MJRefresh.h"
#import "MPManager.h"
#import "DownloadManager.h"
#import "Utils.h"
#import "TryListenManager.h"
#import "DownloadTaskTableViewController.h"

@interface BaiDuTopListTableViewController () <TryListenManagerDelegate, DownloadManagerDelegate>

@property (nonatomic, strong)UIButton *tryListenBtn;

@property (nonatomic, strong)NSMutableArray *musics;
@property (nonatomic, strong)NSMutableDictionary *params;
@property (nonatomic ,strong)DownloadManager *downloadManager;
@property (nonatomic, strong)MPManager *playerManager;

@property (nonatomic)BOOL isSearchLrc;
@property (nonatomic)BOOL isNoMoreData;

@end

@implementation BaiDuTopListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(qualityChanged:) name:@"QualityChanged" object:nil];
    
    self.downloadManager = [DownloadManager shareManager];
    self.playerManager = [MPManager shareManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.downloadManager.delegate = self;
}

- (void)initUI
{
    // 添加模糊背景
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sky"]];
    bg.frame = self.tableView.frame;
    self.tableView.backgroundView = bg;
    [Utils addBlurToView:self.tableView.backgroundView];
    
    // 添加试听按钮
    self.tryListenBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.tryListenBtn.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
    [self.tryListenBtn setTitle:@"STOP" forState:UIControlStateNormal];
    [self.tryListenBtn addTarget:self action:@selector(stopPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.tryListenBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.tryListenBtn.hidden = YES;
    
    [self.tableView addSubview:self.tryListenBtn];
    
    [self setupRefresh];
}

- (void)setupRefresh
{
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.tableView.header beginRefreshing];
    
    if (self.type == SINGER) {
        [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        self.tableView.footer.hidden = YES;
    }
}
// 进页面时首次加载数据
- (void)loadNewData
{
    // 初始化搜索参数
    self.params = [@{@"s":@"1", @"key":@"", @"jump":@"0", @"start":@"0",@"size":@"20"} mutableCopy];
    // 歌手榜单
    if (self.type == SINGER) {
        self.params[@"key"] = self.keyWord;
        [BaiduMusicUtils searchSingerWithParams:self.params Completion:^(id obj) {
            self.musics = obj;
            [self.tableView reloadData];
            [self.tableView.header endRefreshing];
            self.tableView.header.hidden = YES;
            self.tableView.footer.hidden = NO;
        }];
    }
    // 其他榜单
    else {
        [BaiduMusicUtils searchBaiduMusicWithType:self.type andParams:nil Completion:^(id obj) {
            self.musics = obj;
            [self.tableView reloadData];
            [self.tableView.header endRefreshing];
            self.tableView.header.hidden = YES;
        }];
    }
}
// 加载更多数据
- (void)loadMoreData
{
    int start = [self.params[@"start"] intValue];
    int size = [self.params[@"size"] intValue];
    start += size;
    self.params[@"start"] = @(start).stringValue;
    
    [BaiduMusicUtils searchSingerWithParams:self.params Completion:^(id obj) {
        if (!obj || [obj count] == 0) {
            self.isNoMoreData = YES;
            [self.tableView.footer noticeNoMoreData];
        } else {
            [self.musics addObjectsFromArray:obj];
            [self.tableView reloadData];
            [self.tableView.footer endRefreshing];
        }
    }];
}
// 停止试听
- (void)stopPlay:(UIButton *)sender
{
    [[TryListenManager shareManager] stop];
    sender.hidden = YES;
}

// 选择不同的品质的通知
- (void)qualityChanged:(NSNotification *)notif
{
    DownloadTableViewCell *cell = notif.userInfo[@"cell"];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    OnlineMusic *music = self.musics[indexPath.row];
    music.rate = [notif.userInfo[@"rate"] intValue];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.musics.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadCellView" owner:self options:nil] lastObject];
    }
    
    OnlineMusic *music = self.musics[indexPath.row];
    
    cell.music = music;
    cell.downloadBtn.tag = (int)indexPath.row;
    [cell.downloadBtn addTarget:self action:@selector(downloadClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.qualityBtn setTitle:@"品质" forState:UIControlStateNormal];
    
    if ([self.playerManager isMusicDownloaded:music]) {
        cell.checkIV.image = [UIImage imageNamed:@"check"];
    } else {
        cell.checkIV.image = nil;
    }

    if ([TryListenManager shareManager].isPlaying) {
        NSString *musicName = [NSString stringWithFormat:@"%@ - %@", music.singer, music.title];
        NSString *curMusicName = [TryListenManager shareManager].curMusicName;
        if ([curMusicName isEqualToString:musicName]) {
            self.tryListenBtn.hidden = NO;
            CGRect frame = cell.frame;
            frame.origin.y = indexPath.row * cell.frame.size.height;
            self.tryListenBtn.frame = frame;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OnlineMusic *music = self.musics[indexPath.row];
    TryListenManager *manager = [TryListenManager shareManager];
    
    NSString *musicPath = [self.playerManager musicPathWithTitle:music.title andArtist:music.singer];
    BOOL isLocalFile = NO;
    if (musicPath) {
        isLocalFile = YES;
    } else {
        musicPath = music.musicUrl;
    }
    NSString *musicName = [NSString stringWithFormat:@"%@ - %@", music.singer, music.title];
    [manager playMusicWithUrlPath:musicPath isLocalFile:isLocalFile];
    manager.delegate = self;
    manager.curMusicName = musicName;
    
    DownloadTableViewCell *cell = (DownloadTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    self.tryListenBtn.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.tryListenBtn.frame = cell.frame;
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - TryListenManagerDelegate

- (void)didFinishedPlay
{
    self.tryListenBtn.hidden = YES;
}

// 下载歌曲
- (void)downloadClicked:(UIButton *)sender
{
    // 添加下载任务
    NSInteger index = sender.tag;
    OnlineMusic *music = self.musics[index];
    [self.downloadManager addDownloadTaskWithMusic:music];
    
    // 加了一点小动画：生成一个带下载图片的ImageView，从点击的按钮的地方放大一倍后消失
    UIImageView *tempView = [[UIImageView alloc] initWithImage:[sender imageForState:UIControlStateNormal]];
    CGRect frame = [sender convertRect:sender.bounds toView:self.view];
    frame.origin.x += (frame.size.width - frame.size.height)/2;
    frame.size.width = frame.size.height;
    tempView.frame = frame;
    [self.view addSubview:tempView];
    
    tempView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut animations:^{
        tempView.transform = CGAffineTransformMakeScale(2, 2);
        tempView.alpha = 0;
    } completion:^(BOOL finished) {
        // 更新下载管理器的徽标值
//        DownloadTaskTableViewController *vc = [self.tabBarController.viewControllers lastObject];
//        NSInteger numOfTasks = self.downloadManager.musicTasks.count;
//        vc.tabBarItem.badgeValue = numOfTasks > 0 ? @(numOfTasks).stringValue : nil;
//        [tempView removeFromSuperview];
    }];
}

#pragma mark DownloadManagerDelegate

- (void)downloadSuccessWithMusicTask:(DownloadMusicTask *)musicTask
{
    OnlineMusic *music = musicTask.music;
    
    NSString *status = [NSString stringWithFormat:@"下载成功:%@-%@", music.singer, music.title];
    
    [Utils addStatudLabelIntoView:self.tabBarController.view withText:status];
}

- (void)downloadFailWithMusicTask:(DownloadMusicTask *)musicTask
{
    OnlineMusic *music = musicTask.music;
    
    NSString *status = [NSString stringWithFormat:@"下载失败:%@-%@", music.singer, music.title];
    
    [Utils addStatudLabelIntoView:self.tabBarController.view withText:status];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"QualityChanged" object:nil];
    NSLog(@"dealloc");
}

@end
