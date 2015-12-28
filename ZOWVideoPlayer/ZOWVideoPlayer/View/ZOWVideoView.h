//
//  ZOWVideoView.h
//  Example
//
//  Created by stoncle on 12/28/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZOWVideoPlayer.h"
#import "ZOWVideoPlayerProtocol.h"

@interface ZOWVideoView : UIView <ZOWVideoPlayerProtocol, ZOWVideoPlayerDataSource, ZOWVideoPlayerDelegate>

@property (nonatomic, strong) ZOWVideoPlayerLayerContainerView *videoLayerContainerView;
@property (nonatomic, strong) ZOWVideoPlayer *videoPlayer;

@property (nonatomic, strong) NSURL *playingURL;

- (void)playVideoWithURL:(NSURL *)url;
- (void)stopVideoPlay;
- (void)pause;
- (void)resume;
- (void)mute;
- (void)unmute;

@end
