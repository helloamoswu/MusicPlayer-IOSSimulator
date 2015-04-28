//
// Created by zen on 13/06/14.
// Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

#import <UIKit/UIKit.h>

@interface UIView (MMSnapshot)

- (UIImage *)mm_snapshotInRect:(CGRect)rect;
- (UIImage *)mm_snapshot;

@end

#endif