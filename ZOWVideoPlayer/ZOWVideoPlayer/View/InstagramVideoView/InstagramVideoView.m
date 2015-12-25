//
//  InstagramVideoView.m
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/10/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "InstagramVideoView.h"
#import <AVFoundation/AVFoundation.h>
#import "ZOWVideoIndicator.h"
#import "ZOWVideoMuteIndicator.h"
#import "ZOWVideoPlayerLayerContainerView.h"

@interface InstagramVideoView () <ZOWVideoPlayerDataSource, ZOWVideoPlayerDelegate>

@end

@implementation InstagramVideoView
{
    ZOWVideoIndicator *_videoIndicator;
    ZOWVideoMuteIndicator *_muteIndicator;
    ZOWVideoPlayerLayerContainerView *_videoLayerContainerView;
    
    ZOWVideoPlayer *_videoPlayer;
    UIButton *_retryButton;
    NSURL *_playingURL;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initVideoPlayer];
        [self addTapGesture];
    }
    return self;
}

#pragma mark - PUBLIC
- (void)playVideoWithURL:(NSURL *)url
{
    if(!url)
    {
        NSLog(@"stoncle debug : video url is nil.");
        return;
    }
    
    [self initVideoLayerContainerView];
    [self initIndicator];
    [self initMuteIndicator];
    
    [self showIndicator];
    
    self.hidden = NO;
    if([self.videoPlayer playVideoWithURL:url])
    {
        _playingURL = url;
    }
}

- (void)stopVideoPlay
{
    [_videoPlayer stopVideoPlay];
    [self hideIndicator];
    [self hidesRetryButton];
    [self removeVideoLayer];
    self.hidden = YES;
}

#pragma mark - PRIVATE
- (void)initVideoPlayer
{
    if(!_videoPlayer)
    {
        _videoPlayer = [[ZOWVideoPlayer alloc] init];
        _videoPlayer.dataSource = self;
        _videoPlayer.delegate = self;
        _videoPlayer.endAction = ZOWVideoPlayerEndActionRePlay;
    }
}

- (void)initIndicator
{
    if(!_videoIndicator)
    {
        _videoIndicator = [[ZOWVideoIndicator alloc] initWithFrame:CGRectMake(self.bounds.size.width-32-4, 4, 32, 32)];
        [self addSubview:_videoIndicator];
    }
}

- (void)initVideoLayerContainerView
{
    if(!_videoLayerContainerView)
    {
        _videoLayerContainerView = [[ZOWVideoPlayerLayerContainerView alloc] initWithFrame:self.bounds];
        _videoLayerContainerView.layer.opacity = 0;
        [self addSubview:_videoLayerContainerView];
    }
}

- (void)initMuteIndicator
{
    if(!_muteIndicator)
    {
        _muteIndicator = [[ZOWVideoMuteIndicator alloc] initWithFrame:CGRectMake(11, self.bounds.size.height-32-11, 32, 32)];
    }
}

- (void)removeVideoLayer
{
    [_videoLayerContainerView.layer removeAllAnimations];
    _videoLayerContainerView.layer.opacity = 0;
}

#pragma mark - ZOWVideoPlayerDataSource
- (UIView<ZOWVideoPlayerProtocol> *)videoPlayerView
{
    return self;
}

#pragma mark - ZOWVideoPlayerDelegate
- (void)videoPlayerDidStartPlayVideo:(ZOWVideoPlayer *)player
{
    [player setMute:YES];
    [self hidesRetryButton];
}

- (void)videoPlayerDidStartStreamVideo:(ZOWVideoPlayer *)player
{
    [self hideIndicator];
    [self hidesRetryButton];
    [self animateVideoLayer];
}

- (void)videoPlayerDidStuck:(ZOWVideoPlayer *)player
{
    [self showIndicator];
}

- (void)videoPlayerDidResume:(ZOWVideoPlayer *)player
{
    [self hideIndicator];
    [self hidesRetryButton];
}

- (void)videoPlayerDidEndPlayVideo:(ZOWVideoPlayer *)player
{
    [self hideIndicator];
    [self hidesRetryButton];
}

- (void)videoPlayerDidFailedPlayVideo:(ZOWVideoPlayer *)player
{
    
}

- (void)videoPlayer:(ZOWVideoPlayer *)player didMuted:(BOOL)mute
{
    if(!_muteIndicator.superview)
    {
        [self addSubview:_muteIndicator];
    }
    else
    {
        
    }
    
    _muteIndicator.mute = mute;
}

#pragma mark synthesize
- (void)setVideoPlayer:(ZOWVideoPlayer *)videoPlayer
{
    _videoPlayer = videoPlayer;
}

- (ZOWVideoPlayer *)videoPlayer
{
    return _videoPlayer;
}

- (void)setVideoLayerContainerView:(ZOWVideoPlayerLayerContainerView *)videoLayerContainerView
{
    _videoLayerContainerView = videoLayerContainerView;
}

- (UIView *)videoLayerContainerView
{
    return _videoLayerContainerView;
}

#pragma mark Animation
- (void)animateVideoLayer
{
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"opacity"];
    ani.fromValue = [NSNumber numberWithFloat:0.0];
    ani.toValue = [NSNumber numberWithFloat:1.0];
    ani.duration = 0.5;
    ani.removedOnCompletion = NO;
    ani.fillMode = kCAFillModeForwards;
    [_videoLayerContainerView.layer removeAnimationForKey:@"fadeAnimation"];
    [_videoLayerContainerView.layer addAnimation:ani forKey:@"fadeAnimation"];
}

#pragma mark Indicator
- (void)hideIndicator
{
    if(_videoIndicator)
    {
        _videoIndicator.hidden = YES;
        [_videoIndicator stopAnimating];
    }
}

- (void)showIndicator
{
    if(_videoIndicator)
    {
        _videoIndicator.hidden = NO;
        [_videoIndicator startAnimating];
    }
}

#pragma mark Retry
- (void)initRetryButton
{
    if(!_retryButton)
    {
        _retryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _retryButton.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [_retryButton setImage:[[UIImage imageNamed:@"refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _retryButton.tintColor = [UIColor whiteColor];
        _retryButton.alpha = 0.7;
        [_retryButton addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)showsRetryButton
{
    [self initRetryButton];
    [self addSubview:_retryButton];
}

- (void)hidesRetryButton
{
    if(_retryButton && _retryButton.superview)
    {
        [_retryButton removeFromSuperview];
    }
}

- (void)retry:(id)sender
{
    if(!_playingURL)
    {
        NSLog(@"stoncle debug : nothing to retry");
        return;
    }
    [self playVideoWithURL:_playingURL];
    [self hidesRetryButton];
}

#pragma mark Gesture
- (void)addTapGesture
{
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    [self addGestureRecognizer:singleTapGesture];
    [self addGestureRecognizer:doubleTapGesture];
}

- (void)singleTap:(id)sender
{
    NSLog(@"single tap on player view");
    if(_videoPlayer)
    {
        if(_videoPlayer.mute)
        {
            _videoPlayer.mute = NO;
        }
        else
        {
            _videoPlayer.mute = YES;
        }
    }
    else
    {
        NSLog(@"stoncle debug : video player nil.");
    }
    
    if([self.delegate respondsToSelector:@selector(videoViewDidSingleTap:)])
    {
        [self.delegate videoViewDidSingleTap:self];
    }
}

- (void)doubleTap:(id)sender
{
    NSLog(@"double tap on player view");
    if([self.delegate respondsToSelector:@selector(videoViewDidDoubleTap:)])
    {
        [self.delegate videoViewDidDoubleTap:self];
    }
}

#pragma mark ZOWVideoPlayerProtocol
- (void)notifyLoadingVideoSuccessed
{
    
}

- (void)notifyLoadingVideoFailed
{
    [self hideIndicator];
    [self showsRetryButton];
    [self removeVideoLayer];
}

- (void)notifyCancelLoadingVideo
{
    
}

- (void)dealloc
{
    [_videoPlayer stopVideoPlay];
}

@end
