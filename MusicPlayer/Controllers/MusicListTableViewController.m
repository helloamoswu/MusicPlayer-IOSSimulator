//
//  MusicListTableViewController.m
//  TMusic
//
//  Created by amos on 15-3-20.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "MusicListTableViewController.h"
#import "PlayMusicViewController.h"
#import "Music.h"
#import "Utils.h"
#import "MusicTableViewCell.h"
#import "AddMusicTableViewController.h"
#import "MPManager.h"
#import "MMProgressHUD.h"

@interface MusicListTableViewController () <UISearchBarDelegate>

@property (nonatomic, strong)MPManager *playerManager;
@property (nonatomic, strong)NSArray *musics;
@property (nonatomic, strong)NSMutableArray *searchResults;
@property (nonatomic, strong)NSArray *displayMusics;
@property (nonatomic, strong)UISearchBar *searchBar;

@end

@implementation MusicListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerManager = [MPManager shareManager];
    
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playClicked)];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMusics)];
    
    // 自定义的歌单显示添加按钮
    if ([self.playerManager isCustomGroup:self.title]) {
        self.navigationItem.rightBarButtonItems = @[playItem, self.editButtonItem, addItem];
    } else {
        // Ipod歌单显示更新按钮
        if ([self.playerManager.curViewGroup isEqualToString:@"Ipod"]) {
            UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshIpodMusics)];
            self.navigationItem.rightBarButtonItems = @[playItem, self.editButtonItem, refreshItem];
        }
        // Latest歌单显示清空按钮
        else if ([self.playerManager.curViewGroup isEqualToString:@"Latest"]) {
            UIBarButtonItem *cleanItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(cleanLatestMusics)];
            self.navigationItem.rightBarButtonItems = @[playItem, self.editButtonItem, cleanItem];
        }
        else {
            self.navigationItem.rightBarButtonItems = @[playItem, self.editButtonItem];
        }
    }
    
    // 添加模糊背景
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sky"]];
    bg.frame = self.tableView.frame;
    self.tableView.backgroundView = bg;
    [Utils addBlurToView:self.tableView.backgroundView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.musics = self.playerManager.curViewMusics;
    self.searchResults = [NSMutableArray array];
    self.displayMusics = self.musics;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playClicked
{
    PlayMusicViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"PlayMusicViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)addMusics
{
    AddMusicTableViewController *addVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"AddMusicTableViewController"];
    addVC.groupName = self.title;
    [self presentViewController:addVC animated:YES completion:^{
        
    }];
}

- (void)refreshIpodMusics
{
    [MMProgressHUD showWithTitle:@"^_^" status:@"请稍等，更新Ipod歌曲中..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.playerManager reLoadIpoadMusics];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MMProgressHUD dismiss];
            self.musics = self.playerManager.curViewMusics;
            self.displayMusics = self.musics;
            [self.tableView reloadData];
        });
    });
}

- (void)cleanLatestMusics
{
    [self.playerManager removeAllMusicInGroup:@"Latest"];
    self.musics = self.playerManager.curViewMusics;
    self.displayMusics = self.musics;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.displayMusics.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicCell"];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MusicCell" owner:self options:nil] lastObject];
    }
    
    cell.backgroundColor = self.cellColor;

    cell.music = self.displayMusics[indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       
        [self.playerManager removeMusicAtIndex:indexPath.row inGroup:self.title];
        self.musics = self.playerManager.curViewMusics;
        self.displayMusics = self.musics;

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.playerManager.curPlayGroup = self.playerManager.curViewGroup;
    [self performSegueWithIdentifier:@"GoToPlayMusicViewSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.searchBar) {
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        self.searchBar.backgroundColor = [UIColor clearColor];
        self.searchBar.tintColor = [UIColor whiteColor];
        self.searchBar.barTintColor = [UIColor colorWithWhite:0.2 alpha:0.3];
        self.searchBar.delegate = self;
    }
    return self.searchBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    self.displayMusics = self.musics;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchResults removeAllObjects];
    for (Music *music in self.musics) {
        NSRange range = [music.title rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
        if (range.length > 0) {
            [self.searchResults addObject:music];
        }
    }
    
    self.displayMusics = self.searchResults;
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToPlayMusicViewSegue"]) {
        
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSInteger index;
        if (self.displayMusics == self.searchResults) {
            index = [self.musics indexOfObject:self.searchResults[indexPath.row]];
        } else {
            index = indexPath.row;
        }
        
        [self.playerManager playMusicWithIndex:index];
    }
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
