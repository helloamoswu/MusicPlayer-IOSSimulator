//
// Created by zen on 13/06/14.
// Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import "UIView+MMSnapshot.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

@implementation UIView (MMSnapshot)

- (UIImage *)mm_snapshotInRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:rect afterScreenUpdates:NO];

    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return snapshot;
}

- (UIImage *)mm_snapshot {
    return [self mm_snapshotInRect:self.bounds];
}

@end

#endif