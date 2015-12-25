//
//  ZOWVideoSourceLoader.h
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/12/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

extern const NSString *preDefineCustomScheme;

@class ZOWVideoSourceLoader;

@protocol ZOWVideoSourceLoaderDelegate <NSObject>

- (void)sourceLoader:(ZOWVideoSourceLoader *)loader task:(NSURLSessionTask *)task didSuccessWithData:(NSData *)data;
- (void)sourceLoader:(ZOWVideoSourceLoader *)loader taskDidCancel:(NSURLSessionTask *)task;
- (void)sourceLoader:(ZOWVideoSourceLoader *)loader task:(NSURLSessionTask *)task didFailedWithError:(NSError *)error;

@end

@interface ZOWVideoSourceLoader : NSObject <AVAssetResourceLoaderDelegate>

- (void)stopLoadingURL:(NSURL *)url;

@property (nonatomic, weak) id<ZOWVideoSourceLoaderDelegate> delegate;

@end
