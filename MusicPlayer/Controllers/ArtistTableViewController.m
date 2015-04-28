//
//  ArtistTableViewController.m
//  MusicPlayer
//
//  Created by amos on 15-4-13.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "ArtistTableViewController.h"
#import "BaiDuTopListTableViewController.h"
#import "Artist.h"
#import "BaiduMusicUtils.h"
#import "Utils.h"
#import "MJRefresh.h"

@interface ArtistTableViewController ()

@property (nonatomic, strong)NSArray *artists;

@end

@implementation ArtistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sky"]];
    bg.frame = self.view.frame;
    self.tableView.backgroundView = bg;
    [Utils addBlurToView:self.tableView.backgroundView];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [BaiduMusicUtils searchBaiduMusicWithType:SINGER andParams:nil Completion:^(id obj) {
            weakSelf.artists = obj;
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.header endRefreshing];
            weakSelf.tableView.header.hidden = YES;
        }];
    }];
    [self.tableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.artists.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Artist *artist = self.artists[indexPath.row];
    
    cell.textLabel.text = artist.name;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"GoToArtistViewSegue" sender:self.artists[indexPath.row]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"GoToArtistViewSegue"]) {
        
        Artist *artist = sender;
        
        BaiDuTopListTableViewController *vc = segue.destinationViewController;
        vc.type = SINGER;
        vc.keyWord = artist.name;
    }
}
 

@end
