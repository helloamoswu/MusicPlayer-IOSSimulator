//
//  Utils.h
//  Day19MusicPlayer
//
//  Created by Tarena on 13-5-2.
//  Copyright (c) 2013年 tarena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface Utils : NSObject

+(UIImage *)artworkImageWithPath:(NSString *)path;
+(float)getMusicDurationByPath:(NSString *)path;
+(NSMutableDictionary*)getMusicInfoByPath:(NSString *)directoryPath;
+(NSArray *)parseLrcWithString:(NSString *)lrcString;


+ (NSString *)generateSuitablePathForPath:(NSString *)path;
+ (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;
+ (void)addBlurToView:(UIView *)view;
+ (UIImage *)playImage;
+ (UIImage *)pauseImage;
+ (UIImage *) albumPlaceHolderImage;
+ (NSString *) applicationDocumentsDirectory;
+ (void)addStatudLabelIntoView:(UIView *)view withText:(NSString *)text;

@end
