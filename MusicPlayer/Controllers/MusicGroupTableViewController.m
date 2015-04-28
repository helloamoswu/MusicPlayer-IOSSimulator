//
//  MusicGroupTableViewController.m
//  MusicPlayer
//
//  Created by amos wu on 15-3-22.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "MusicGroupTableViewController.h"
#import "MusicListTableViewController.h"
#import "MPManager.h"
#import "Group.h"
#import "Utils.h"

@interface MusicGroupTableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong)MPManager *playerManager;

@end

@implementation MusicGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"我的歌单";
    self.playerManager = [MPManager shareManager];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroupClicked)];
    self.navigationItem.rightBarButtonItems = @[addItem, self.editButtonItem];
    
    // 添加模糊背景
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sky"]];
    bg.frame = self.tableView.frame;
    self.tableView.backgroundView = bg;
    [Utils addBlurToView:self.tableView.backgroundView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addGroupClicked{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Group" message:@"Enter group name:" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) {
        return;
    }
    
    NSString *groupName = [alertView textFieldAtIndex:0].text;
    
    if (groupName.length == 0) {
        return;
    }
    
    if (![self.playerManager addGroupWithName:groupName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The group name has existed,please try another name" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // 去掉all love latest download这4个组
    return self.playerManager.groups.count - 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Group *group = self.playerManager.groups[indexPath.row + 4];
    cell.textLabel.text = group.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d首", (int)group.musics.count];
    cell.backgroundColor = self.cellColor;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.playerManager removeGroup:self.playerManager.groups[indexPath.row + 4]];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MusicListTableViewController *vc = [segue destinationViewController];
    UITableViewCell *cell = sender;
    NSString *groupName = cell.textLabel.text;
    self.playerManager.curViewGroup = groupName;
    //self.playerManager.curMusics = self.playerManager.musicsDict[groupName];
    vc.title = groupName;
    vc.cellColor = cell.backgroundColor;
}


@end
