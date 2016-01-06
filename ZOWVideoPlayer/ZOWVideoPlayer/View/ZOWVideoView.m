//
//  ZOWVideoView.m
//  Example
//
//  Created by stoncle on 12/28/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ZOWVideoView.h"
#import "ZOWVideoPlayerLayerContainerView.h"

@implementation ZOWVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initVideoPlayer];
    }
    return self;
}

- (void)playVideoWithURL:(NSURL *)url {
    [self initVideoLayerContainerView];
    if([self.videoPlayer playVideoWithURL:url])
    {
        _playingURL = url;
    }
}

- (void)stopVideoPlay {
    [self hideVideoLayer];
    [self.videoPlayer stopVideoPlay];
}

- (void)pause {
    [self.videoPlayer pause];
}

- (void)resume {
    [self.videoPlayer resume];
}

- (void)mute {
    [self.videoPlayer setMute:YES];
}

- (void)unmute {
    [self.videoPlayer setMute:NO];
}

#pragma mark - Private
- (void)initVideoPlayer
{
    if(!self.videoPlayer)
    {
        self.videoPlayer = [[ZOWVideoPlayer alloc] init];
        self.videoPlayer.dataSource = self;
        self.videoPlayer.delegate = self;
        self.videoPlayer.endAction = ZOWVideoPlayerEndActionReset;
    }
}

- (void)initVideoLayerContainerView
{
    if(!self.videoLayerContainerView)
    {
        self.videoLayerContainerView = [[ZOWVideoPlayerLayerContainerView alloc] initWithFrame:self.bounds];
        [self addSubview:self.videoLayerContainerView];
    }
}

- (void)hideVideoLayer
{
    [self.videoLayerContainerView.layer removeAllAnimations];
    self.videoLayerContainerView.layer.opacity = 0;
}

#pragma mark - Delegate
#pragma mark ZOWVideoPlayerDataSource
- (UIView<ZOWVideoPlayerProtocol> *)videoPlayerView {
    return self;
}

#pragma mark ZOWVideoPlayerDelegate

#pragma mark ZOWVideoPlayerProtocol
- (void)notifyCancelLoadingVideo {
    
}

- (void)notifyLoadingVideoSuccessed {
    
}

- (void)notifyLoadingVideoFailed {
    [self hideVideoLayer];
}

- (void)dealloc
{
    [self.videoPlayer stopVideoPlay];
}

@end
