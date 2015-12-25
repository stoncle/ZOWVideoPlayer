//
//  ZOWVideoPlayerItemObject.h
//  InstaGrab
//
//  Created by stoncle on 12/11/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZOWVideoPlayerItemStatus) {
    ZOWVideoPlayerItemObjectStatusNormal,
    ZOWVideoPlayerItemObjectStatusFailed,
};

@interface ZOWVideoPlayerItemObject : NSObject

@property (nonatomic, strong) NSURL *originalVideoURL;
@property (nonatomic, strong) NSURL *schemedVideoURL;
@property (nonatomic, assign) BOOL isItemStartedStreaming;
@property (nonatomic, assign) ZOWVideoPlayerItemStatus status;

+ (instancetype)playerItemWithVideoURL:(NSURL *)originalVideoURL;

@end
