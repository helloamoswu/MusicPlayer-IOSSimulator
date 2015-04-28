//
//  Group.h
//  MusicPlayer
//
//  Created by amos wu on 15-3-22.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Music;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *musics;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addMusicsObject:(Music *)value;
- (void)removeMusicsObject:(Music *)value;
- (void)addMusics:(NSSet *)values;
- (void)removeMusics:(NSSet *)values;

@end
