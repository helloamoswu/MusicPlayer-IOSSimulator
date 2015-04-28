//
//  WelcomeCollectionViewController.m
//  TMusic
//
//  Created by amos on 15-2-27.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "WelcomeCollectionViewController.h"
#import "MyMusicTableViewController.h"

#import "MPManager.h"
#import "MMProgressHUD.h"

@interface WelcomeCollectionViewController ()

@property (nonatomic, strong)UIPageControl *pageControl;
@property (nonatomic, strong)UIButton *startBtn;

@end

@implementation WelcomeCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self.collectionView setPagingEnabled:YES];
    
    self.collectionView.frame = self.view.frame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 20, self.view.frame.size.width, 20)];
    self.pageControl.numberOfPages = 5;
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.pageControl];
}

- (void)changePage:(id)sender
{
    //得到当前页面的ID
    
    NSInteger page = [sender currentPage];
    NSIndexPath *index = [NSIndexPath indexPathForRow:page inSection:0];
    [self.collectionView selectItemAtIndexPath:index animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Welcome_3.0_%d", (int)indexPath.row+1]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    cell.backgroundView = imageView;
    
    if (self.startBtn) {
        [self.startBtn removeFromSuperview];
    }
    
    if (indexPath.row == 4) {
        self.startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.startBtn.frame = CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height - 110, 100, 40);
        [self.startBtn setTitle:@"进入" forState:UIControlStateNormal];
        self.startBtn.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [self.startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
        [self.startBtn addTarget:self action:@selector(goToMainWindow) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:self.startBtn];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.pageControl.currentPage = indexPath.row;
}

- (void)goToMainWindow
{
    [MMProgressHUD showWithTitle:@"^_^" status:@"请稍等，载入Ipod歌曲中..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MPManager shareManager];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MMProgressHUD dismiss];
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MyMusicTableViewController *mvc = [storyBoard instantiateInitialViewController];
            [self presentViewController:mvc animated:YES completion:nil];
        });
    });
    
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.pageControl.currentPage = indexPath.row;
}
// 分页指示器显示的是最终显示图片的索引
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *index = collectionView.indexPathsForVisibleItems[0];
    self.pageControl.currentPage = index.row;
}

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
