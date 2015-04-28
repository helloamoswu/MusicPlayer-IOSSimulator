//
//  AddMusicTableViewController.m
//  MusicPlayer
//
//  Created by amos on 15-3-31.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "AddMusicTableViewController.h"
#import "MPManager.h"
#import "MusicTableViewCell.h"
#import "Utils.h"

@interface AddMusicTableViewController ()

@property (nonatomic, strong)NSArray *allMusics;
@property (nonatomic, strong)NSMutableArray *selectedMusic;
@property (nonatomic, strong)MPManager *playerManager;

@end

@implementation AddMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerManager = [MPManager shareManager];
    self.selectedMusic = [self.playerManager.musicsDict[self.groupName] mutableCopy];
    self.allMusics = [self.playerManager.musicsDict[@"Ipod"] arrayByAddingObjectsFromArray:self.playerManager.musicsDict[@"Download"]];
    
    // 添加模糊背景
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sky"]];
    bg.frame = self.tableView.frame;
    self.tableView.backgroundView = bg;
    [Utils addBlurToView:self.tableView.backgroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)okClicked:(id)sender {

    [self.playerManager addMusics:self.selectedMusic intoGroup:self.groupName];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allMusics.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicCell"];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MusicCell" owner:self options:nil] lastObject];
    }
    
    cell.music = self.allMusics[indexPath.row];
    if ([self.selectedMusic containsObject:cell.music]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicTableViewCell *cell = (MusicTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedMusic removeObject:self.allMusics[indexPath.row]];
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedMusic addObject:self.allMusics[indexPath.row]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.7]];
    okBtn.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    [okBtn addTarget:self action:@selector(okClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return okBtn;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
