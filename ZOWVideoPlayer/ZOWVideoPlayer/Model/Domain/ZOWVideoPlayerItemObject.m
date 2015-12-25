//
//  ZOWVideoPlayerItemObject.m
//  InstaGrab
//
//  Created by stoncle on 12/11/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ZOWVideoPlayerItemObject.h"
#import "ZOWSchemedURL.h"
#import "ZOWVideoSourceLoader.h"

@implementation ZOWVideoPlayerItemObject

+ (instancetype)playerItemWithVideoURL:(NSURL *)originalVideoURL
{
    ZOWVideoPlayerItemObject *item = [[ZOWVideoPlayerItemObject alloc] init];
    item.originalVideoURL = originalVideoURL;
    item.schemedVideoURL = [ZOWSchemedURL getSchemedURLWithOriginalURL:originalVideoURL customScheme:[preDefineCustomScheme copy]];
    item.isItemStartedStreaming = NO;
    item.status = ZOWVideoPlayerItemObjectStatusNormal;
    return item;
}

@end
