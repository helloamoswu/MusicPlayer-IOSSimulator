//
//  Utils.m
//  Day19MusicPlayer
//
//  Created by Tarena on 13-5-2.
//  Copyright (c) 2013年 tarena. All rights reserved.
//

#import "Utils.h"
#import <AVFoundation/AVFoundation.h>
#import "Lrc.h"

@implementation Utils

//获取专辑封面
+(UIImage *)artworkImageWithPath:(NSString *)path{

    if (path == nil) {
        return nil;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSData *albumData = nil;
    
    for (NSString *format in [mp3Asset availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
            if ([metadataItem.commonKey isEqualToString :@"artwork"]) {
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                    albumData = metadataItem.dataValue;
                } else {
                    albumData = [(NSDictionary*)metadataItem.value objectForKey:@"data"];
                }
                break;
            }
        }
    }
        
    if (albumData) {
        return [UIImage imageWithData: albumData];
    }
    
    return nil;
}

//获取歌曲时长

+(float)getMusicDurationByPath:(NSString *)path
{
    NSURL *url;
    if ([path hasPrefix:@"ipod-library:"]) {
        url = [NSURL URLWithString:path];
    } else {
        url = [NSURL fileURLWithPath:path];
    }
    
    AVAudioPlayer *p = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    return p.duration;
//    NSURL *afUrl = [NSURL fileURLWithPath:path];
//    AudioFileID fileID;
//    OSStatus result = AudioFileOpenURL((__bridge CFURLRef)afUrl, kAudioFileReadPermission, 0, &fileID);
//    Float64 outDataSize = 0;
//    UInt32 thePropSize = sizeof(Float64);
//    result = AudioFileGetProperty(fileID, kAudioFilePropertyEstimatedDuration, &thePropSize, &outDataSize);
//    AudioFileClose(fileID);
//    
//    return outDataSize;
}

//获取歌曲信息
+(NSMutableDictionary*)getMusicInfoByPath:(NSString *)directoryPath{
    
    NSURL * fileURL=[NSURL fileURLWithPath:directoryPath];
    NSString *fileExtension = [[fileURL path] pathExtension];
    if ([fileExtension isEqual:@"mp3"]||[fileExtension isEqual:@"m4a"])
    {
        AudioFileID fileID  = nil;
        OSStatus err        = noErr;
        
        err = AudioFileOpenURL( (CFURLRef) CFBridgingRetain(fileURL), kAudioFileReadPermission, 0, &fileID );
        if( err != noErr ) {
            NSLog( @"AudioFileOpenURL failed" );
        }
        UInt32 id3DataSize  = 0;
        err = AudioFileGetPropertyInfo( fileID,   kAudioFilePropertyID3Tag, &id3DataSize, NULL );
        
        if( err != noErr ) {
            NSLog( @"AudioFileGetPropertyInfo failed for ID3 tag" );
        }
        NSDictionary *piDict = nil;
        UInt32 piDataSize   = sizeof( piDict );
        err = AudioFileGetProperty( fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict );
        if( err != noErr ) {
            NSLog( @"AudioFileGetProperty failed for property info dictionary" );
        }
        
        UInt32 picDataSize = sizeof(picDataSize);
        err =AudioFileGetProperty( fileID,   kAudioFilePropertyAlbumArtwork, &picDataSize, nil);
        if( err != noErr ) {
            NSLog( @"Get picture failed" );
        }
        
        NSString * Album = [(NSDictionary*)piDict objectForKey:
                            [NSString stringWithUTF8String: kAFInfoDictionary_Album]];
        NSString * Artist = [(NSDictionary*)piDict objectForKey:
                             [NSString stringWithUTF8String: kAFInfoDictionary_Artist]];
        NSString * Title = [(NSDictionary*)piDict objectForKey:
                            [NSString stringWithUTF8String: kAFInfoDictionary_Title]];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (Title) {
            [dic setObject:Title forKey:@"Title"];
        }
        if (Artist) {
            [dic setObject:Artist forKey:@"Artist"];
        }
        if (Album) {
            [dic setObject:Album forKey:@"Album"];
        }
        NSLog(@"%@",Title);
        
        NSLog(@"%@",Artist);
        
        NSLog(@"%@",Album);

        return dic;
    }
    
    return nil;
}

+(NSArray *)parseLrcWithString:(NSString *)lrcString{
    
    NSMutableArray *lrcs = [NSMutableArray array];
    NSArray *lines = [lrcString componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        
        NSArray *timeAndText = [line componentsSeparatedByString:@"]"];
        
        if (timeAndText.count < 2) {
            continue;
        }
        
        NSString *text = [timeAndText lastObject];
        // 要考虑到一行多个时间的情况
        for (int i = 0; i < timeAndText.count - 1; i++) {
            NSString *timeString = [timeAndText[i] substringFromIndex:1];
            NSArray *times = [timeString componentsSeparatedByString:@":"];
            int time = [times[0]intValue]*60+[times[1]intValue];
            
            Lrc *aLrc = [Lrc lrcWithText:text atTime:time];
            
            [lrcs addObject:aLrc];
        }
    }
    // 按时间升序
    [lrcs sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Lrc *lrc1 = obj1;
        Lrc *lrc2 = obj2;
        
        if (lrc1.time < lrc2.time) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
        
    }];
    
    return lrcs;
}

+ (NSString *)generateSuitablePathForPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:path]) {
        
        long long timeStamp = [NSDate date].timeIntervalSinceReferenceDate;
        NSString *extension = [path pathExtension];
        NSString *tpath = [path stringByDeletingPathExtension];
        path = [tpath stringByAppendingFormat:@"-%llu.%@", timeStamp, extension];
    }
    return path;
}

+ (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize newImageSize = CGSizeMake(MAX(firstImage.size.width, secondImage.size.width), MAX(firstImage.size.height, secondImage.size.height));
    
    firstImage = [Utils imageWithImage:firstImage scaledToSize:newImageSize];
    secondImage = [Utils imageWithImage:secondImage scaledToSize:newImageSize];
    
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(newImageSize);
    }
    [firstImage drawAtPoint:CGPointMake(roundf((newImageSize.width-firstImage.size.width)/2),
                                        roundf((newImageSize.height-firstImage.size.height)/2))];
    [secondImage drawAtPoint:CGPointMake(roundf((newImageSize.width-secondImage.size.width)/2),
                                         roundf((newImageSize.height-secondImage.size.height)/2))];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)addBlurToView:(UIView *)view {
    UIView *blurView = nil;
    
    if([UIBlurEffect class]) { // iOS 8
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.frame = view.frame;
        
    } else { // workaround for iOS 7
        blurView = [[UIToolbar alloc] initWithFrame:view.bounds];
    }
    
    [blurView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [view addSubview:blurView];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(blurView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(blurView)]];
}

+ (UIImage *)playImage
{
    return [UIImage imageNamed:@"playing_btn_play_h"];
}

+ (UIImage *)pauseImage
{
    return [UIImage imageNamed:@"playing_btn_pause_h"];
}

+ (UIImage *) albumPlaceHolderImage
{
    return [UIImage imageNamed:@"album_placeholder.jpg"];
}

+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}

// 在view的底部添加一个显示状态的label，从出现到消失是3秒钟
+ (void)addStatudLabelIntoView:(UIView *)view withText:(NSString *)text
{
    CGRect frame = [text boundingRectWithSize:CGSizeMake(1000, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13] } context: nil];
    
    UILabel *failLabel = [[UILabel alloc]init];
    failLabel.text = text;
    failLabel.backgroundColor = [UIColor blackColor];
    failLabel.textColor = [UIColor whiteColor];
    failLabel.textAlignment = NSTextAlignmentCenter;
    failLabel.font = [UIFont systemFontOfSize:13];
    failLabel.alpha = 0;
    
    CGSize viewSize = view.frame.size;
    frame.size.width += 10;
    frame.size.height = 25;
    frame.origin.y = viewSize.height - 70;
    frame.origin.x = (viewSize.width - frame.size.width)/2;
    if (frame.origin.x < 0) {
        frame.origin.x = 0;
    }
    failLabel.frame = frame;
    
    [view addSubview:failLabel];
    
    [UIView animateWithDuration:1 animations:^{
        failLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
            failLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [failLabel removeFromSuperview];
        }];
    }];
}

@end
