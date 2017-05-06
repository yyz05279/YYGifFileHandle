//
//  ViewController.m
//  GifFileHandleDemo
//
//  Created by YZ Y on 17/5/6.
//  Copyright © 2017年 YYZ. All rights reserved.
//

#import "ViewController.h"
#import "YYGifFileHandle.h"

#define win_height [UIScreen mainScreen].bounds.size.height
#define win_width [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *gifImages = [YYGifFileHandle getGifImage:@"load_image"];
    UIImage *image = [gifImages firstObject];
    UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, image.size.width, image.size.height)];
    gifView.animationImages = gifImages;
    gifView.animationDuration = gifImages.count * 0.1;
    [gifView startAnimating];
//    UIView *gifView = [YYGifFileHandle gifView:@"load_image" text:nil];
    [self.view addSubview:gifView];
    
//    NSArray *gifWithTextArray = [YYGifFileHandle getGifImage:@"load_image" text:@"GIF"];
    
    //UIImage *image2 = [gifImages firstObject];
//    UIImageView *gifView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50 + image.size.height, image2.size.width, image2.size.height)];
//    gifView2.animationImages = gifWithTextArray;
//    gifView2.animationDuration = gifWithTextArray.count * 0.1;
//    [gifView2 startAnimating];
    UIView *gifView2 = [YYGifFileHandle gifView:@"load_image" text:@"GIF"];
    gifView2.frame = CGRectMake(0, gifView.frame.size.height + 30, win_width, gifView.frame.size.height);
    [self.view addSubview:gifView2];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
