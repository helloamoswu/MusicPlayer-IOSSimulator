//
//  SearchMusicTableViewController.m
//  MusicPlayer
//
//  Created by amos on 15-3-29.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "SearchMusicTableViewController.h"
#import "DownloadTaskTableViewController.h"
#import "MvViewController.h"
#import "OnlineMusic.h"
#import "OnlineLrc.h"
#import "DownloadTableViewCell.h"
#import "MVTableViewCell.h"
#import "Music.h"
#import "DownloadManager.h"
#import "MPManager.h"
#import "TryListenManager.h"
#import "Utils.h"
#import "MJRefresh.h"
#import "DongTingUtils.h"

typedef enum : NSUInteger {
    BaiDu,
    TTDT
} SearchSourch;

@interface SearchMusicTableViewController () <UISearchBarDelegate, TryListenManagerDelegate,
                                                UIAlertViewDelegate, DownloadManagerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong)UIButton *tryListenBtn;

@property (nonatomic, strong)NSMutableArray *musics;
@property (nonatomic, strong)NSMutableDictionary *baiduParams;
@property (nonatomic, strong)NSMutableDictionary *ttdtParams;
@property (nonatomic ,strong)DownloadManager *downloadManager;
@property (nonatomic, strong)MPManager *playerManager;

@property (nonatomic)BOOL isSearchLrc;
@property (nonatomic)BOOL isNoMoreData;
@property (nonatomic)SearchSourch searchSourch;
@property (nonatomic)BOOL isSearchMV;
@property (nonatomic)NSInteger selectedRow;

@end

@implementation SearchMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(qualityChanged:) name:@"QualityChanged" object:nil];
    
    self.downloadManager = [DownloadManager shareManager];
    self.playerManager = [MPManager shareManager];
    
    // 初始化搜索参数
    self.baiduParams = [@{@"s":@"1", @"key":@"菊花台", @"jump":@"0", @"start":@"0",@"size":@"20"} mutableCopy];
    self.ttdtParams = [@{@"q":@"菊花台", @"page":@"1",@"size":@"20"} mutableCopy];
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

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    //self.tableView.footer.hidden = YES;
}

// 选择不同的品质的通知
- (void)qualityChanged:(NSNotification *)notif
{
    DownloadTableViewCell *cell = notif.userInfo[@"cell"];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    OnlineMusic *music = self.musics[indexPath.row];
    music.rate = [notif.userInfo[@"rate"] intValue];
}

- (IBAction)SearchSourceChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.searchBar.scopeButtonTitles = @[@"歌曲", @"歌手", @"歌词"];
        self.searchSourch = BaiDu;
    } else {
        self.searchBar.scopeButtonTitles = @[@"歌曲", @"歌手", @"MV"];
        self.searchSourch = TTDT;
    }
    [self.musics removeAllObjects];
}

#pragma mark - UISearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length == 0) {
        return;
    }
    // 制造一个菊花，让他转动...
    UIView *juhua = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 15,
                                                        self.view.frame.size.height/2 - 30, 30, 30)];
    juhua.backgroundColor = [UIColor clearColor];
    UIImageView *juhuaIV = [[UIImageView alloc]initWithFrame:juhua.bounds];
    NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:12];
    for (int i = 1; i < 13; i++) {
        NSString *juhuaName = [NSString stringWithFormat:@"load%02d", i];
        [imgs addObject:[UIImage imageNamed:juhuaName]];
    }
    juhuaIV.animationImages = imgs;
    juhuaIV.animationDuration = 1.0f;
    juhuaIV.animationRepeatCount = 0;
    [juhuaIV startAnimating];
    [juhua addSubview:juhuaIV];
    [self.view addSubview:juhua];
    
    self.isSearchLrc = NO;
    self.isSearchMV = NO;
    
    if (self.searchSourch == BaiDu) {
        [self searchBaiDuMusicWithSearchText:searchBar.text andStartIndex:@(0) Completion:^(id obj) {
            self.musics = obj;
            [self.tableView reloadData];
            [juhua removeFromSuperview];
        }];
    } else if (self.searchSourch == TTDT) {
        [self searchTTDTMusicWithSearchText:searchBar.text andPageNumber:@(1) Completion:^(id obj) {
            self.musics = obj;
            [self.tableView reloadData];
            [juhua removeFromSuperview];
        }];
    }
    
    
    
    [searchBar resignFirstResponder];
}

- (void)searchBaiDuMusicWithSearchText:(NSString *)searchText andStartIndex:(NSNumber *)index Completion:(Completion)callback
{
    self.isNoMoreData = NO;
    self.baiduParams[@"key"] = searchText;
    self.baiduParams[@"start"] = index.stringValue;
    
    NSLog(@"%d", self.searchBar.selectedScopeButtonIndex);
    
    if (self.searchBar.selectedScopeButtonIndex == 0) {
        self.isSearchLrc = NO;
        [BaiduMusicUtils searchBaiduMusicWithType:SEARCH andParams:self.baiduParams Completion:^(id obj) {
            callback(obj);
        }];
    } else if (self.searchBar.selectedScopeButtonIndex == 2) {
        self.isSearchLrc = NO;
        [BaiduMusicUtils searchSingerWithParams:self.baiduParams Completion:^(id obj) {
            callback(obj);
        }];
    } else {
        self.isSearchLrc = YES;
        [BaiduMusicUtils searchBaiduLrcWithParams:self.baiduParams Completion:^(id obj) {
            callback(obj);
        }];
    }
}

- (void)searchTTDTMusicWithSearchText:(NSString *)searchText andPageNumber:(NSNumber *)page Completion:(Completion)callback
{
    self.isNoMoreData = NO;
    self.ttdtParams[@"q"] = searchText;
    self.ttdtParams[@"page"] = page.stringValue;
    
    if (self.searchBar.selectedScopeButtonIndex == 2) {
        self.isSearchMV = YES;
        [DongTingUtils searchDongTingMVWithParams:self.ttdtParams Completion:^(id obj) {
            callback(obj);
        }];
    } else {
        self.isSearchMV = NO;
        [DongTingUtils searchDongTingMusicWithParams:self.ttdtParams Completion:^(id obj) {
            callback(obj);
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.musics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 显示MV
    if (self.isSearchMV) {
        
        MVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MvCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MVTableViewCell" owner:self options:nil] lastObject];
        }
        
        OnlineMusic *music = self.musics[indexPath.row];
        cell.mvLabel.text = [NSString stringWithFormat:@"%@ - %@", music.singer, music.title];
        
        return cell;
        
    }
    // 显示歌曲
    else {
        
        DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell"];
        
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadCellView" owner:self options:nil] lastObject];
        }
        
        OnlineMusic *music = self.musics[indexPath.row];
        
        cell.music = music;
        cell.downloadBtn.tag = (int)indexPath.row;
        [cell.downloadBtn addTarget:self action:@selector(downloadClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.qualityBtn setTitle:@"品质" forState:UIControlStateNormal];
        
        if (cell.qualitySV) {
            [cell.qualitySV removeFromSuperview];
            cell.qualitySV = nil;
            [cell setNeedsLayout];
        }
        
        if ([self.playerManager isMusicDownloaded:music] && !self.isSearchLrc) {
            cell.checkIV.image = [UIImage imageNamed:@"check"];
        } else {
            cell.checkIV.image = nil;
        }
        
        if (self.isSearchLrc) {
            cell.qualityBtn.hidden = YES;
        }
        // 如果有正在试听的歌曲，显示出来
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OnlineMusic *music = self.musics[indexPath.row];
    // 播放MV
    if (self.isSearchMV) {
        
        self.selectedRow = indexPath.row;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选择播放画质" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        for (NSDictionary *mvInfo in music.mvList) {
            [alertView addButtonWithTitle:mvInfo[@"type"]];
        }
        [alertView show];
        
    }
    // 试听歌曲
    else {
        
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
}
// 选择MV品质并播放
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    OnlineMusic *music = self.musics[self.selectedRow];
    
    NSString *url = music.mvList[buttonIndex - 1][@"url"];
    
    [self performSegueWithIdentifier:@"GoToPlayMvViewSegue" sender:url];
    
}
// 停止试听
- (void)stopPlay:(UIButton *)sender
{
    [[TryListenManager shareManager] stop];
    sender.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark 开始进入刷新状态
- (void)loadMoreData
{
    if (!self.musics || (self.searchBar.text.length == 0)) {
        [self.tableView.footer endRefreshing];
        return;
    }
    
    if (self.searchSourch == BaiDu) {
        int start = [self.baiduParams[@"start"] intValue];
        int size = [self.baiduParams[@"size"] intValue];
        start += size;
        
        [self searchBaiDuMusicWithSearchText:self.searchBar.text andStartIndex:@(start) Completion:^(id obj) {
            if ([obj count] == 0) {
                self.isNoMoreData = YES;
                [self.tableView.footer noticeNoMoreData];
            } else {
                [self.musics addObjectsFromArray:obj];
                [self.tableView reloadData];
                [self.tableView.footer endRefreshing];
            }
        }];
    } else if (self.searchSourch == TTDT) {
        int page = [self.ttdtParams[@"page"] intValue];
        page++;
        [self searchTTDTMusicWithSearchText:self.searchBar.text andPageNumber:@(page) Completion:^(id obj) {
            if ([obj count] == 0) {
                self.isNoMoreData = YES;
                [self.tableView.footer noticeNoMoreData];
            } else {
                [self.musics addObjectsFromArray:obj];
                [self.tableView reloadData];
                [self.tableView.footer endRefreshing];
            }
        }];
    }
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
        //DownloadTaskTableViewController *vc = [self.tabBarController.viewControllers lastObject];
        //NSInteger numOfTasks = self.downloadManager.musicTasks.count;
        //vc.tabBarItem.badgeValue = numOfTasks > 0 ? @(numOfTasks).stringValue : nil;
        //[tempView removeFromSuperview];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToPlayMvViewSegue"]) {
        
        OnlineMusic *music = self.musics[self.selectedRow];
        
        MvViewController *vc = segue.destinationViewController;
        vc.mvUrl = sender;
        vc.title = [NSString stringWithFormat:@"%@-%@", music.singer, music.title];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"QualityChanged" object:nil];
    NSLog(@"dealloc");
}


@end
