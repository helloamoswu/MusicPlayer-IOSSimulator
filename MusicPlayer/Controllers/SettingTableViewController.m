//
//  SettingTableViewController.m
//  MusicPlayer
//
//  Created by amos on 15-4-13.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "SettingTableViewController.h"
#import "ChannelTableViewCell.h"
#import "PathTableViewCell.h"
#import "TopListTableViewCell.h"
#import "FMUtils.h"
#import "BaiduMusicUtils.h"

@interface SettingTableViewController ()

@property (nonatomic, strong)NSMutableArray *douBanChs;
@property (nonatomic, strong)NSMutableArray *baiDuChs;
@property (nonatomic, strong)NSString *baiDuFMMusicFormatePath;
@property (nonatomic, strong)NSString *baiDuPlayListFormatePath;
@property (nonatomic, strong)NSString *douBanFMMusicsFormatePath;

@property (nonatomic, strong)NSArray *topLists;
@property (nonatomic, strong)NSMutableDictionary *baiDuMusicDict;

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.douBanChs = [FMUtils objectInSettingDictWithKey:@"DouBanChannels"];
    self.baiDuChs = [FMUtils objectInSettingDictWithKey:@"BaiDuChannels"];
    self.baiDuFMMusicFormatePath = [FMUtils objectInSettingDictWithKey:@"BaiDuFMMusicFormatePath"];
    self.baiDuPlayListFormatePath = [FMUtils objectInSettingDictWithKey:@"BaiDuPlayListFormatePath"];
    self.douBanFMMusicsFormatePath = [FMUtils objectInSettingDictWithKey:@"DouBanFMMusicsFormatePath"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BaiDuMusic" ofType:@"plist"];
    self.baiDuMusicDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    self.topLists = ((NSDictionary *)self.baiDuMusicDict[@"topLists"]).allKeys;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 保存
- (IBAction)saveClicked:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"^_^" message:@"还没实现此功能，比较麻烦..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return self.douBanChs.count;
    } else if (section == 2) {
        return self.baiDuChs.count;
    } else if (section == 3) {
        return 11;
    } else {
        return self.topLists.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 || indexPath.section == 3) {
        PathTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PathTableViewCell" owner:self options:nil] lastObject];
        }
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.pathNameLabel.text = @"DouBanFMMusicsFormatePath";
                cell.pathTextField.text = self.douBanFMMusicsFormatePath;
            } else if (indexPath.row == 1) {
                cell.pathNameLabel.text = @"BaiDuPlayListFormatePath";
                cell.pathTextField.text = self.baiDuPlayListFormatePath;
            } else {
                cell.pathNameLabel.text = @"BaiDuFMMusicFormatePath";
                cell.pathTextField.text = self.baiDuFMMusicFormatePath;
            }
        } else {
            if (indexPath.row == 0) {
                cell.pathNameLabel.text = @"LrcPath";
                cell.pathTextField.text = self.baiDuMusicDict[@"LrcPath"];
            } else if (indexPath.row == 1) {
                cell.pathNameLabel.text = @"LrcXPath";
                cell.pathTextField.text = self.baiDuMusicDict[@"LrcXPath"];
            } else if (indexPath.row == 2) {
                cell.pathNameLabel.text = @"MusicPath";
                cell.pathTextField.text = self.baiDuMusicDict[@"MusicPath"];
            } else if (indexPath.row == 3) {
                cell.pathNameLabel.text = @"SearchMusicXPath";
                cell.pathTextField.text = self.baiDuMusicDict[@"SearchMusicXPath"];
            } else if (indexPath.row == 4) {
                cell.pathNameLabel.text = @"SearchSingerFirstPageXPath";
                cell.pathTextField.text = self.baiDuMusicDict[@"SearchSingerFirstPageXPath"];
            } else if (indexPath.row == 5) {
                cell.pathNameLabel.text = @"SearchSingerOtherPageXPath";
                cell.pathTextField.text = self.baiDuMusicDict[@"SearchSingerOtherPageXPath"];
            } else if (indexPath.row == 6) {
                cell.pathNameLabel.text = @"SearchPath";
                cell.pathTextField.text = self.baiDuMusicDict[@"SearchPath"];
            } else if (indexPath.row == 7) {
                cell.pathNameLabel.text = @"TopNewXPath";
                cell.pathTextField.text = self.baiDuMusicDict[@"TopNewXPath"];
            } else if (indexPath.row == 8) {
                cell.pathNameLabel.text = @"TopOtherXPath";
                cell.pathTextField.text = self.baiDuMusicDict[@"TopOtherXPath"];
            } else if (indexPath.row == 9) {
                cell.pathNameLabel.text = @"TopArtistXPath1";
                cell.pathTextField.text = self.baiDuMusicDict[@"TopArtistXPath1"];
            } else if (indexPath.row == 10) {
                cell.pathNameLabel.text = @"TopArtistXPath2";
                cell.pathTextField.text = self.baiDuMusicDict[@"TopArtistXPath2"];
            }
        }
        
        return cell;
        
    } else if (indexPath.section == 1 || indexPath.section == 2) {
        ChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ChannelTableViewCell" owner:self options:nil] lastObject];
        }
        if (indexPath.section == 1) {
            cell.channelNameTF.text = self.douBanChs[indexPath.row][@"name"];
            cell.channelParamTF.text = ((NSNumber *)self.douBanChs[indexPath.row][@"type"]).stringValue;
        } else {
            cell.channelNameTF.text = self.baiDuChs[indexPath.row][@"name"];
            cell.channelParamTF.text = self.baiDuChs[indexPath.row][@(indexPath.row).stringValue];
        }
        
        return cell;
    } else {
        TopListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell3"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TopListTableViewCell" owner:self options:nil] lastObject];
        }
        cell.typeTF.text = self.topLists[indexPath.row];
        NSDictionary *dict = self.baiDuMusicDict[@"topLists"][cell.typeTF.text];
        cell.nameTF.text = dict[@"name"];
        cell.pathTF.text = dict[@"path"];
        
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"FM路径";
    } else if (section == 1) {
        return @"豆瓣频道";
    } else if (section == 2) {
        return @"百度频道";
    } else if (section == 3) {
        return @"百度音乐路径";
    } else {
        return @"百度音乐榜单";
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.tableView endEditing:YES];
}

@end
