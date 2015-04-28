//
//  DownloadTaskTableViewController.m
//  MusicPlayer
//
//  Created by amos on 15-4-7.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "DownloadTaskTableViewController.h"
#import "DownloadTaskTableViewCell.h"
#import "DownloadManager.h"
#import "MPManager.h"
#import "OnlineMusic.h"
#import "OnlineLrc.h"
#import "Utils.h"
#import "Music.h"

@interface DownloadTaskTableViewController () <DownloadManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong)NSArray *musicTasks;
@property (nonatomic, strong)DownloadManager *downloadManager;
@property (nonatomic, strong)MPManager *playerManager;
@property (nonatomic, strong)NSArray *downloadHistory;

@property (nonatomic)NSInteger selectedRow;

@end

@implementation DownloadTaskTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.downloadManager = [DownloadManager shareManager];
    self.downloadManager.delegate = self;
    self.musicTasks = self.downloadManager.musicTasks;
    self.playerManager = [MPManager shareManager];
    
    // 添加模糊背景
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sky"]];
    bg.frame = self.tableView.frame;
    self.tableView.backgroundView = bg;
    [Utils addBlurToView:self.tableView.backgroundView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.downloadManager.delegate = self;
    
    [self updateData];
    //[self updateBadgeValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateData
{
    self.downloadHistory = self.playerManager.musicsDict[@"Download"];
    [self.tableView reloadData];
}

- (void)updateBadgeValue
{
    NSInteger numOfTasks = self.musicTasks.count;
    // 大于0才显示
    if (numOfTasks > 0) {
        self.tabBarItem.badgeValue = @(numOfTasks).stringValue;
    } else {
        self.tabBarItem.badgeValue = nil;
    }
}

#pragma mark - DownloadManager Delegate
// 下载完成
- (void)downloadSuccessWithMusicTask:(DownloadMusicTask *)musicTask
{
    // 更新界面
    [self updateData];
    //[self updateBadgeValue];
}

- (void)downloadFailWithMusicTask:(DownloadMusicTask *)musicTask
{
    NSInteger index = [self.musicTasks indexOfObject:musicTask];
    DownloadTaskTableViewCell *cell = (DownloadTaskTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] ];
    cell.processLabel.hidden = YES;
    [cell.processBtn setTitle:@"❌" forState:UIControlStateNormal];
}

- (void)musicTask:(DownloadMusicTask *)musicTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //NSLog(@"%lld  %lld  %lld",bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    
    // 更新下载进度
    NSInteger index = [self.musicTasks indexOfObject:musicTask];
    DownloadTaskTableViewCell *cell = (DownloadTaskTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] ];
    
    cell.processLabel.text = [NSString stringWithFormat:@"%.f%%", totalBytesWritten * 1.0 / totalBytesExpectedToWrite * 100];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return self.musicTasks.count;
    } else {
        return self.downloadHistory.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"正在下载";
    } else {
        return @"下载历史";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTaskTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"DownloadTaskCellView" owner:self options:nil]lastObject];
    }
    // 必须移除
    [cell.processBtn removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.section == 0) {
        DownloadMusicTask *musicTask = self.musicTasks[indexPath.row];
        OnlineMusic *music = musicTask.music;
        cell.titleLabel.text = music.title;
        cell.singerLabel.text = music.singer;
        cell.processBtn.tag = indexPath.row;
        if (musicTask.state == Fail) {
            [cell.processBtn setTitle:@"❌" forState:UIControlStateNormal];
            cell.processLabel.text = @"";
        } else {
            [cell.processBtn setTitle:@"" forState:UIControlStateNormal];
        }
        
        [cell.processBtn addTarget:self action:@selector(processBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        Music *music = self.downloadHistory[indexPath.row];
        cell.titleLabel.text = music.title;
        cell.singerLabel.text = music.artist;
        cell.processLabel.text = @"";
        cell.processBtn.tag = indexPath.row;
        [cell.processBtn setTitle:@"✔️" forState:UIControlStateNormal];
        [cell.processBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.transform = CGAffineTransformMakeScale(1.0, 1.0);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
    DownloadTaskTableViewCell *cell = (DownloadTaskTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"任务正在下载，确定删除吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = -1;
        [alertView show];
        
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            cell.transform = CGAffineTransformMakeScale(1.02, 1.2);
        } completion:^(BOOL finished) {
            self.playerManager.curPlayGroup = @"Download";
            [self performSegueWithIdentifier:@"GoToPlayMusicViewSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
        }];
    }
    
    
}



// 下载进度按钮触摸事件,根据任务的状态进行切换
- (void)processBtnClicked:(UIButton *)sender
{
    NSInteger index = sender.tag;
    NSURLSessionDownloadTask *task = [self.downloadManager downloadTaskWithMusicTask:self.musicTasks[index]];
    // 确保任务存在
    if (!task) {
        return;
    }
    
    DownloadMusicTask *musicTask = self.musicTasks[index];
    // 将失败的任务移除
    if (musicTask.state == Fail) {
        [self.downloadManager cleanMusicTask:musicTask];
        [self.tableView reloadData];
        //[self updateBadgeValue];
        return;
    }
    // 正在进行的任务
    DownloadTaskTableViewCell *cell = (DownloadTaskTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    // 根据当前的任务状态进行切换
    switch (task.state) {
        case NSURLSessionTaskStateRunning: // 暂停
            [task suspend];
            [sender setTitle:@"🕒" forState:UIControlStateNormal];
            cell.processLabel.hidden =YES;
            break;
        case NSURLSessionTaskStateSuspended: // 恢复
            [task resume];
            [sender setTitle:@"" forState:UIControlStateNormal];
            cell.processLabel.hidden =NO;
            break;
        case NSURLSessionTaskStateCompleted: // 完成
            [sender setTitle:@"✔️" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}
// 删除歌曲
- (void)deleteBtnClicked:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"确定删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = sender.tag;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    // 删除下载任务
    if (alertView.tag == -1) {
        DownloadMusicTask *task = self.musicTasks[self.selectedRow];
        [self.downloadManager cleanMusicTask:task];
        [self.tableView reloadData];
    } else {
        Music *music = self.downloadHistory[alertView.tag];
        [self.playerManager removeMusic:music inGroup:@"Download"];
        
        [self updateData];
    }
    
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToPlayMusicViewSegue"]) {
        
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        [self.playerManager playMusicWithIndex:indexPath.row];
    }
}

@end
