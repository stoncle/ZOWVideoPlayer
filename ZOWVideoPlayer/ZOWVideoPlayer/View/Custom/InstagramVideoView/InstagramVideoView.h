//
//  InstagramVideoView.h
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/10/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZOWVideoView.h"
#import "ZOWVideoPlayer.h"

@class InstagramVideoView;

@protocol InstagramVideoViewTapDelegate <NSObject>

@optional
- (void)videoViewDidSingleTap:(InstagramVideoView *)view;
- (void)videoViewDidDoubleTap:(InstagramVideoView *)view;

@end

@interface InstagramVideoView : ZOWVideoView

@property (nonatomic, weak) id<InstagramVideoViewTapDelegate> delegate;

@end
