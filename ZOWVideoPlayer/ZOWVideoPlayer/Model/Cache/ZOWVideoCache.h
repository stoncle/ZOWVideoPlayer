//
//  ZOWVideoCache.h
//  InstaGrab
//
//  Created by stoncle on 11/14/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZOWVideoCache : NSObject

+ (instancetype)sharedVideoCache;

/**
 *  The video cache path, set it in correct context to hit the cache.
 */
@property (nonatomic, copy) NSString *videoCachedDirectoryPath;

/**
 * The maximum length of time to keep an video in the cache, in seconds
 */
@property (assign, nonatomic) NSInteger maxCacheAge;

/**
 * The maximum size of the cache, in bytes.
 */
@property (assign, nonatomic) NSUInteger maxCacheSize;

/**
 *  The endurance size that cache can hold. If cached size reach it, then all the cache would be cleared.
 */
@property (assign, nonatomic) NSUInteger enduranceSize;

/**
 * Get the size used by the disk cache
 */
- (NSUInteger)getCacheSize;

/**
 * Get the number of images in the disk cache
 */
- (NSUInteger)getCacheCount;

- (void)cacheVideoWithData:(NSData *)data withOriginalURLString:(NSString *)urlString;
- (BOOL)ifVideoCacheWithOriginalURLString:(NSString *)urlString;
- (NSString *)getVideoCachePathForURLString:(NSString *)urlString;

- (void)clearAllCache;
- (void)cleanCache;

@end
