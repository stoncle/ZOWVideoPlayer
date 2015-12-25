//
//  ZOWVideoPlayerLayerContainerView.m
//  ZOWVideoPlayer
//
//  Created by stoncle on 12/10/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ZOWVideoPlayerLayerContainerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation ZOWVideoPlayerLayerContainerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

@end
