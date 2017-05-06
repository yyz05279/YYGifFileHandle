//
//  YYGifFileHandle.m
//  DDFood
//
//  Created by YZ Y on 16/12/24.
//  Copyright © 2016年 YZ Y. All rights reserved.
//

#import "YYGifFileHandle.h"
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "YYGifView.h"

#define win_height [UIScreen mainScreen].bounds.size.height
#define win_width [UIScreen mainScreen].bounds.size.width

@interface YYGifFileHandle ()

@end

@implementation YYGifFileHandle

+ (NSDictionary *)getGifInfo:(NSString *)gifName
{
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:gifName withExtension:@"gif"];
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *delays = [NSMutableArray arrayWithCapacity:3];
    NSUInteger loopCount = 0;
    CGFloat totalTime;         // seconds
    CGFloat width;
    CGFloat height;
    
    getFrameInfo((__bridge CFURLRef)fileUrl, frames, delays, &totalTime, &width, &height, loopCount);
    
    NSMutableArray *imageArray = [NSMutableArray array];
    for(int index = 0; index < [frames count]; index++)
    {
        //获取gif每一帧的image
        UIImage *image = frames[index];
        [imageArray addObject:[self imageCompressWithSimple:image]];
    }
    
    NSDictionary *gifDic = @{@"images": frames,          //图片数组
                             @"delays": delays,          //每一帧对应的延迟时间数组
                             @"duration": @(totalTime),  //GIF图播放一遍的总时间
                             @"loopCount": @(loopCount), //GIF图播放次数  0-无限播放
                             @"bounds": NSStringFromCGRect(CGRectMake(0, 0, width, height)),
                             @"width": @(width),
                             @"height": @(height)//GIF图的宽高
                             };
    return gifDic;
}


/*
 * @brief resolving gif information
 */
void getFrameInfo(CFURLRef url, NSMutableArray *frames, NSMutableArray *delayTimes, CGFloat *totalTime, CGFloat *gifWidth, CGFloat *gifHeight, NSUInteger loopCount)
{
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL(url, NULL);
    
    //获取gif的帧数
    size_t frameCount = CGImageSourceGetCount(gifSource);
    
    //获取GfiImage的基本数据
    NSDictionary *gifProperties = (__bridge NSDictionary *) CGImageSourceCopyProperties(gifSource, NULL);
    //由GfiImage的基本数据获取gif数据
    NSDictionary *gifDictionary = [gifProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
    //获取gif的播放次数 0-无限播放
    loopCount = [[gifDictionary objectForKey:(NSString*)kCGImagePropertyGIFLoopCount] integerValue];
    CFRelease((__bridge CFTypeRef)(gifProperties));
    
    for (size_t i = 0; i < frameCount; ++ i) {
        //得到每一帧的CGImage
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [frames addObject:[UIImage imageWithCGImage:frame]];
        CGImageRelease(frame);
        
        //获取每一帧的图片信息
        NSDictionary *frameDict = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL);
        
        //获取Gif图片尺寸
        if (gifWidth != NULL && gifHeight != NULL) {
            *gifWidth = [[frameDict valueForKey:(NSString *)kCGImagePropertyPixelWidth] floatValue];
            *gifHeight = [[frameDict valueForKey:(NSString *)kCGImagePropertyPixelHeight] floatValue];
        }
        
        //由每一帧的图片信息获取gif信息
        NSDictionary *gifDict = [frameDict valueForKey:(NSString *)kCGImagePropertyGIFDictionary];
        //取出每一帧的delaytime
        [delayTimes addObject:[gifDict valueForKey:(NSString *)kCGImagePropertyGIFDelayTime]];
        
        if (totalTime) {
            *totalTime = *totalTime + [[gifDict valueForKey:(NSString *)kCGImagePropertyGIFDelayTime] floatValue];
        }
        CFRelease((__bridge CFTypeRef)(frameDict));
    }
    CFRelease(gifSource);
}

+ (UIImage *)imageCompressWithSimple:(UIImage *)image{
    CGSize size = image.size;
    CGFloat scale = 1.0;
    if (size.width > win_width || size.height > win_height) {
        if (size.width > size.height) {
            scale = win_width / size.width;
        } else {
            scale = win_height / size.height;
        }
    }
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    CGSize secSize = CGSizeMake(scaledWidth, scaledHeight);
    //设置新图片的宽高
    UIGraphicsBeginImageContext(secSize); // this will crop
    [image drawInRect:CGRectMake(0, 0, scaledWidth, scaledHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSArray *)getGifImage:(NSString *)gifName
{
    NSDictionary *dic = [self getGifInfo:gifName];
    NSMutableArray *imageArray = [NSMutableArray array];
    for(int index = 0; index < [dic[@"images"] count]; index++)
    {
        //获取gif每一帧的image
        UIImage *image = dic[@"images"][index];
        [imageArray addObject:[self imageCompressWithSimple:image]];
    }
    return imageArray;
}

+ (NSArray *)getGifImage:(NSString *)gifName text:(NSString *)text
{
    NSDictionary *dic = [self getGifInfo:gifName];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    //在gif图的每一帧上面添加一段文字
    for(int index = 0; index < [dic[@"images"] count]; index ++)
    {
        //绘制view 已GIf图中的某一帧为背景并在view上添加文字
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectFromString(dic[@"bounds"])];
        tempView.backgroundColor = [UIColor colorWithPatternImage:dic[@"images"][index]];
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 40)];
        tempLabel.text = text;
        tempLabel.textColor = [UIColor redColor];
        tempLabel.backgroundColor = [UIColor clearColor];
        tempLabel.font = [UIFont boldSystemFontOfSize:28];
        [tempView addSubview:tempLabel];
        
        //将UIView转换为UIImage
        UIGraphicsBeginImageContextWithOptions(tempView.bounds.size, NO, tempView.layer.contentsScale);
        [tempView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        [imageArray addObject:image];
        UIGraphicsEndImageContext();  
    }
    return imageArray;
}

+ (UIView *)gifView:(NSString *)gifName text:(NSString *)text
{
    if (text == nil || [text isEqualToString:@""]) {
        NSArray *imageArr = [self getGifImage:gifName];
        NSDictionary *dic = [self getGifInfo:gifName];
        NSDictionary *changedDic = @{@"images": imageArr,
                                     @"delays": dic[@"delays"],
                                     @"duration": dic[@"duration"],
                                     @"loopCount": dic[@"loopCount"],
                                     @"bounds": NSStringFromCGRect(CGRectMake(0, 0, [dic[@"width"] doubleValue], [dic[@"height"] doubleValue])),
                                     @"width": dic[@"width"],
                                     @"height": dic[@"height"]
                                     };
        YYGifView *view = [[YYGifView alloc] initWithCenter:CGPointMake(win_width / 2, 0) gifInfo:changedDic];
        return view;
    } else {
        NSArray *imageArr = [self getGifImage:gifName text:text];
        NSDictionary *dic = [self getGifInfo:gifName];
        NSDictionary *changedDic = @{@"images": imageArr,
                                     @"delays": dic[@"delays"],
                                     @"duration": dic[@"duration"],
                                     @"loopCount": dic[@"loopCount"],
                                     @"bounds": NSStringFromCGRect(CGRectMake(0, 0, [dic[@"width"] doubleValue], [dic[@"height"] doubleValue])),
                                     @"width": dic[@"width"],
                                     @"height": dic[@"height"]
                                     };
        YYGifView *view = [[YYGifView alloc] initWithCenter:CGPointMake(win_width / 2, 0) gifInfo:changedDic];
        return view;
    }
    return nil;
}

@end
