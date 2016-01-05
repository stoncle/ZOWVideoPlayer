//
//  ZOWVideoPlayer.h
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/10/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZOWVideoPlayerProtocol.h"
@import UIKit;

@class ZOWVideoPlayer;
@class ZOWVideoPlayerLayerContainerView;
@class AVPlayerLayer;

@protocol ZOWVideoPlayerDataSource <NSObject>

- (UIView<ZOWVideoPlayerProtocol> *)videoPlayerView;

@end

@protocol ZOWVideoPlayerDelegate <NSObject>

@optional
- (void)videoPlayerDidStartPlayVideo:(ZOWVideoPlayer *)player;
- (void)videoPlayerDidStartStreamVideo:(ZOWVideoPlayer *)player;
- (void)videoPlayerDidEndPlayVideo:(ZOWVideoPlayer *)player;
- (void)videoPlayerDidStuck:(ZOWVideoPlayer *)player;
- (void)videoPlayerDidResume:(ZOWVideoPlayer *)player;
- (void)videoPlayerDidReset:(ZOWVideoPlayer *)player;
- (void)videoPlayerDidFailedPlayVideo:(ZOWVideoPlayer *)player;
- (void)videoPlayer:(ZOWVideoPlayer *)player didMuted:(BOOL)mute;

@end

typedef NS_ENUM(NSUInteger, ZOWVideoPlayerEndAction) {
    ZOWVideoPlayerEndActionReset,
    ZOWVideoPlayerEndActionPause,
    ZOWVideoPlayerEndActionRePlay,
};

@interface ZOWVideoPlayer : NSObject

/**
 *  play video with specific url.
 *
 *  @param url video url on internet.
 *
 *  @return YES if video can play. NO if video url nil or url already playing.
 */
- (BOOL)playVideoWithURL:(NSURL *)url;

- (void)stopVideoPlay;

- (void)pause;
- (void)resume;

@property (nonatomic, weak) id<ZOWVideoPlayerDataSource> dataSource;
@property (nonatomic, weak) id<ZOWVideoPlayerDelegate> delegate;

@property (nonatomic) BOOL mute;

/**
 *  set endAction to define the player behavior when play reach end.
 */
@property (nonatomic) ZOWVideoPlayerEndAction endAction;

/**
 *  if video play stuck when loading, the player will pause and prebuffer a few seconds to provide a merely smooth video play.
 */
@property (nonatomic, assign) CGFloat preloadBufferSecondsWhenStucked;

/**
 *  when YES, video will resume play when enter foreground from background.
 */
@property (nonatomic, assign) BOOL autoResumeFromBackground;

/**
 *  directory to save video caches.
 */
@property (nonatomic, copy) NSString *videoCachedDirectory;

@end
