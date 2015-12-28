//
//  ZOWVideoPlayerProtocol.h
//  Example
//
//  Created by stoncle on 12/28/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#ifndef ZOWVideoPlayerProtocol_h
#define ZOWVideoPlayerProtocol_h

@class ZOWVideoPlayer;
@class ZOWVideoPlayerLayerContainerView;

@protocol ZOWVideoPlayerProtocol <NSObject>

@property (nonatomic, strong) ZOWVideoPlayer *videoPlayer;
@property (nonatomic, strong) ZOWVideoPlayerLayerContainerView *videoLayerContainerView;

@optional
- (void)notifyLoadingVideoSuccessed;
- (void)notifyLoadingVideoFailed;
- (void)notifyCancelLoadingVideo;

@end

#endif /* ZOWVideoPlayerProtocol_h */
