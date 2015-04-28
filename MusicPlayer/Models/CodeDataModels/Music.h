//
//  Music.h
//  MusicPlayer
//
//  Created by amos on 15/4/16.
//  Copyright (c) 2015年 amos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface Music : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSSet *groups;
@end

@interface Music (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
