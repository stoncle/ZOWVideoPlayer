//
//  ZOWVideoIndicator.m
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/14/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ZOWVideoIndicator.h"

@implementation ZOWVideoIndicator
{
    CALayer *_animatingDot;
    NSTimeInterval _currentCycleTime;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _cycleDuration = 0.75;
    _color = [UIColor whiteColor];
}

- (void)startAnimating
{
    if (self.superview) {
        if (!_isAnimating) {
            if (!_animatingDot) {
                [self createDot];
            }
            [self scheduleDisplayLink];
        }
    }
}

- (void)stopAnimating
{
    if(_isAnimating)
    {
        [self invalidateDisplayLink];
    }
}

#pragma mark - PRIVATE
- (void)createDot
{
    CALayer *borderLayer = [CALayer layer];
    borderLayer.frame = self.bounds;
    UIImage *borderImage = [UIImage imageNamed:@"video_loading"];
    UIImageView *tempView = [[UIImageView alloc] initWithImage:borderImage];
//    tempView.tintColor= _color;
    borderLayer.contents = tempView.layer.contents;
    
    [self.layer addSublayer:borderLayer];
    
    _animatingDot = [CALayer layer];
    CGRect dotRect = CGRectMake(9.5, 12.5, 7, 7);
    _animatingDot.frame = dotRect;
    _animatingDot.cornerRadius = _animatingDot.frame.size.width/2;
    _animatingDot.borderWidth = 0.5;
    _animatingDot.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    
    UIImage *resultingImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(dotRect.size, NO, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(ctx, (CGRect){CGPointZero, dotRect.size});
    CGContextSetFillColorWithColor(ctx, _color.CGColor);
    CGContextFillPath(ctx);
    
    resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    _animatingDot.contents = (id)resultingImage.CGImage;
    [borderLayer addSublayer:_animatingDot];
}

- (void)scheduleDisplayLink {
    if(![_animatingDot animationForKey:@"animation"])
    {
        CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        animation.duration = _cycleDuration;
        animation.autoreverses = YES;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        
        NSMutableArray *values = [NSMutableArray array];
        NSMutableArray *timings = [NSMutableArray array];
        NSMutableArray *keytimes = [NSMutableArray array];
        
        [timings addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        
        [values addObject:[NSNumber numberWithFloat:0.0]];
        [keytimes addObject:[NSNumber numberWithFloat:0.0]];
        
        [values addObject:[NSNumber numberWithFloat:1.0]];
        [keytimes addObject:[NSNumber numberWithFloat:_cycleDuration]];
        
        animation.values = values;
        animation.timingFunctions = timings;
        animation.keyTimes = keytimes;
        [_animatingDot addAnimation:animation forKey:@"animation"];
    }
    
    _isAnimating = YES;
    NSLog(@"start animating...");
}



- (void)invalidateDisplayLink {
    [_animatingDot removeAllAnimations];
    
    _isAnimating = NO;
    NSLog(@"stop animating....");
}

@end
