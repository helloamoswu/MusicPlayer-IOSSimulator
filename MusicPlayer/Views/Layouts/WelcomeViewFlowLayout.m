//
//  WelcomeViewFlowLayout.m
//  TMusic
//
//  Created by amos on 15-2-27.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import "WelcomeViewFlowLayout.h"

@implementation WelcomeViewFlowLayout

- (instancetype)init
{
    if (self = [super init]) {
        self.itemSize = [[UIScreen mainScreen] bounds].size;
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    
    return self;
}

@end
