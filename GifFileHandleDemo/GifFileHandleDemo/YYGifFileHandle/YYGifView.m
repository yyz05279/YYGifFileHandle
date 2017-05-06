//
//  YYGifView.m
//  GifFileHandleDemo
//
//  Created by YZ Y on 17/5/6.
//  Copyright © 2017年 YYZ. All rights reserved.
//

#import "YYGifView.h"

@interface YYGifView ()
{
    NSMutableArray *_frames;
    NSMutableArray *_frameDelayTimes;
    
    CGPoint frameCenter;
    CADisplayLink *displayLink;
    int frameIndex;
    double frameDelay;
    
    NSUInteger _loopCount;
    NSUInteger _currentLoop;
    CGFloat _totalTime;         // seconds
    CGFloat _width;
    CGFloat _height;
}

@end

@implementation YYGifView
- (id)initWithCenter:(CGPoint)center gifInfo:(NSDictionary *)gifInfo;
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        _frames = [[NSMutableArray alloc] init];
        _frameDelayTimes = [[NSMutableArray alloc] init];
        
        _width = 0;
        _height = 0;
        frameCenter = center;
        [self initGifInfo:gifInfo];
    }
    return self;
}

- (void)initGifInfo:(NSDictionary *)gifInfo
{
    if (gifInfo) {
        _frames = [NSMutableArray arrayWithArray:gifInfo[@"images"]];
        _frameDelayTimes = [NSMutableArray arrayWithArray:gifInfo[@"delays"]];
        _totalTime = [gifInfo[@"duration"] doubleValue];
        _loopCount = [gifInfo[@"loopCount"] integerValue];
        _width = [gifInfo[@"width"] doubleValue];
        _height = [gifInfo[@"height"] doubleValue];
    }
    self.frame = CGRectMake(0, 0, _width, _height);
    self.center = frameCenter;
    self.backgroundColor = [UIColor clearColor];
    if(_frames && _frames[0]){
        self.layer.contents = (__bridge id)([_frames[0] CGImage]);
    }
}

//使用displayLink播放
- (void)startGif
{
    frameIndex = 0;
    _currentLoop = 1;
    frameDelay =[_frameDelayTimes[0] doubleValue];
    
    [self stopGif];
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
//每秒60帧刷新视图
- (void)updateDisplay:(CADisplayLink *)link
{
    if(frameDelay <= 0){
        frameIndex ++;
        if(_loopCount != 0){
            if (_currentLoop >= _loopCount) {
                [self stopGif];
            }else{
                _currentLoop ++;
            }
        }
        if(frameIndex>=_frames.count){
            frameIndex = 0;
        }
        frameDelay = [_frameDelayTimes[frameIndex] doubleValue]+frameDelay;
        self.layer.contents = (__bridge id)([_frames[frameIndex] CGImage]);
    }
    frameDelay -= fmin(displayLink.duration, 1);   //To avoid spiral-o-death
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if(newSuperview){
        [self startGif];
    }else{
        [self stopGif];  //视图将被移除
    }
}

//使用Animation方式播放Gif
- (void)startGifAnimation
{
    [self stopGif];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:3];
    CGFloat currentTime = 0;
    NSInteger count = _frameDelayTimes.count;
    for (int i = 0; i < count; ++i) {
        [times addObject:[NSNumber numberWithFloat:(currentTime / _totalTime)]];
        currentTime += [[_frameDelayTimes objectAtIndex:i] floatValue];
    }
    [animation setKeyTimes:times];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < count; ++i) {
        [images addObject:(__bridge id)[[_frames objectAtIndex:i] CGImage]];
    }
    
    [animation setValues:images];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    animation.duration = _totalTime;
    [UIView setAnimationDelegate:self];
    if(_loopCount <= 0){
        animation.repeatCount = INFINITY;
    }else{
        animation.repeatCount = _loopCount;
    }
    [self.layer addAnimation:animation forKey:@"gifAnimation"];
}

- (void)stopGif
{
    [self.layer removeAllAnimations];
    [self removeDisplayLink];
    
    if(_frames && _frames[0]){
        self.layer.contents = (__bridge id)([_frames[0] CGImage]);
    }
}

- (void)removeDisplayLink
{
    [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [displayLink invalidate];
    displayLink = nil;
}

// remove contents when animation end
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(_frames && _frames[0]){
        self.layer.contents = (__bridge id)([_frames[0] CGImage]);
    }
}


- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

@end
