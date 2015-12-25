//
//  InstagramVideoView.h
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/10/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZOWVideoPlayer.h"

@class InstagramVideoView;

@protocol ZOWVideoPlayerViewDelegate <NSObject>

@optional
- (void)videoViewDidSingleTap:(InstagramVideoView *)view;
- (void)videoViewDidDoubleTap:(InstagramVideoView *)view;

@end

@interface InstagramVideoView : UIView <ZOWVideoPlayerProtocol>

@property (nonatomic, weak) id<ZOWVideoPlayerViewDelegate> delegate;

- (void)playVideoWithURL:(NSURL *)url;
- (void)stopVideoPlay;

@end
