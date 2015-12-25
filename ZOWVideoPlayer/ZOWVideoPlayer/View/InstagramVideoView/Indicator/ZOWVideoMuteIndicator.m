//
//  ZOWVideoMuteIndicator.m
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/23/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ZOWVideoMuteIndicator.h"

#define kFadeAnimationKey   @"fadeAnimation"

@implementation ZOWVideoMuteIndicator

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
    _imageView = [[UIImageView alloc] init];
    [self addSubview:_imageView];
    [self configureConstraints];
}

- (void)configureConstraints
{
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_imageView]|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_imageView)]];
    [self addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_imageView]|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_imageView)]];
}

#pragma mark Synthesize
- (void)setMute:(BOOL)mute
{
    if(mute)
    {
        _imageView.image = [UIImage imageNamed:@"voice_off"];
    }
    else
    {
        _imageView.image = [UIImage imageNamed:@"voice_on"];
    }
    [self animate];
}

#pragma mark Animation
- (void)animate
{
    [self.layer removeAnimationForKey:kFadeAnimationKey];
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 3.0;
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *timings = [NSMutableArray array];
    NSMutableArray *keytimes = [NSMutableArray array];
    
    [values addObject:[NSNumber numberWithFloat:1.0]];
    [keytimes addObject:[NSNumber numberWithFloat:0.0]];
    
    [values addObject:[NSNumber numberWithFloat:1.0]];
    [keytimes addObject:[NSNumber numberWithFloat:0.7]];
    
    [values addObject:[NSNumber numberWithFloat:0]];
    [keytimes addObject:[NSNumber numberWithFloat:1.0]];
    
    animation.values = values;
    animation.timingFunctions = timings;
    animation.keyTimes = keytimes;
    
    [self.layer addAnimation:animation forKey:kFadeAnimationKey];
    self.layer.opacity = 0;
}

@end
