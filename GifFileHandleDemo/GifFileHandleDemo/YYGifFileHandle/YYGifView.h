//
//  YYGifView.h
//  GifFileHandleDemo
//
//  Created by YZ Y on 17/5/6.
//  Copyright © 2017年 YYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYGifView : UIView

- (id)initWithCenter:(CGPoint)center gifInfo:(NSDictionary *)gifInfo;
- (void)initGifInfo:(NSDictionary *)gifInfo;

/**开始gif动画 */
- (void)startGif;
- (void)startGifAnimation;

/**停止Gif动画*/
- (void)stopGif;

@end
