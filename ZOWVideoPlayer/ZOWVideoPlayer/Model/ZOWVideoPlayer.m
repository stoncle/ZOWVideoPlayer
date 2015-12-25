//
//  ZOWVideoPlayer.m
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/10/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ZOWVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>

#import "ZOWVideoSourceLoader.h"
#import "ZOWVideoCache.h"
#import "ZOWVideoPlayerItemObject.h"
#import "ZOWVideoPlayerLayerContainerView.h"

static const CGFloat defaultPreBufferSeconds = 2.0;

@interface ZOWVideoPlayer () <ZOWVideoSourceLoaderDelegate>

@property (nonatomic, strong) AVPlayer *videoPlayer;

@property (nonatomic, strong) ZOWVideoPlayerItemObject *playerItemObject;
@property (nonatomic, strong) ZOWVideoSourceLoader *videoLoader;

@property (nonatomic, strong) NSMutableArray<AVPlayerItem *> *observingItem;

@end

@implementation ZOWVideoPlayer

- (instancetype)init
{
    if(self = [super init])
    {
        _observingItem = [NSMutableArray array];
        _playerItemObject = [[ZOWVideoPlayerItemObject alloc] init];
        _preloadBufferSecondsWhenStucked = defaultPreBufferSeconds;
    }
    return self;
}

#pragma mark - PUBLIC
- (BOOL)playVideoWithURL:(NSURL *)url
{
    if(!url)
    {
        NSLog(@"stoncle debug : video url nil.");
        return NO;
    }
    
    if ([url isEqual:_playerItemObject.originalVideoURL])
    {
        if (_playerItemObject.status != ZOWVideoPlayerItemObjectStatusFailed)
        {
            if ([self isPlaying])
            {
                NSLog(@"stoncle debug : requested video is playing, rate:%f. Ignored.", _videoPlayer.rate);
                return NO;
            }
            else {}
        }
        else
        {
            NSLog(@"stoncle debug : replay a failed video");
        }
    }
    else {}
    
    _playerItemObject = [ZOWVideoPlayerItemObject playerItemWithVideoURL:url];
    [self configurePlayerItem];
    [self addResumeFromBackgroundNotification];
    [self addResignActiveNotification];
    return YES;
}

- (void)stopVideoPlay
{
    [self removeResumeFromBackgroundNotification];
    [self removeResignActiveNotification];
    
    if(_videoPlayer)
    {
        NSLog(@"pause video player");
        [self pause];
        [self removePlayerDidReachEndNotification];
        [self removeObservationOnPlayerItem:_videoPlayer.currentItem];
    }
    else
    {
        NSLog(@"attempt to stop a nil video player.");
    }
    
    [_videoLoader stopLoadingURL:_playerItemObject.originalVideoURL];
}

- (void)pause
{
    [self pauseVideo];
}

- (void)resume
{
    [self resumePlay];
}

#pragma mark - PRIVATE
- (void)configurePlayerItem
{
    AVPlayerItem *playerItem;
    if([[ZOWVideoCache sharedVideoCache] ifVideoCacheWithOriginalURLString:_playerItemObject.originalVideoURL.absoluteString])
    {
        AVURLAsset *asset;
        NSString *cachedFilePath = [[ZOWVideoCache sharedVideoCache] getVideoCachePathForURLString:_playerItemObject.originalVideoURL.absoluteString];
        asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:cachedFilePath] options:nil];
        playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        [self launchPlayerWithItem:playerItem];
        
        // call start play manually
        if([self.delegate respondsToSelector:@selector(videoPlayerDidStartPlayVideo:)])
        {
            [self.delegate videoPlayerDidStartPlayVideo:self];
        }
        if([self.delegate respondsToSelector:@selector(videoPlayerDidStartStreamVideo:)])
        {
            [self.delegate videoPlayerDidStartStreamVideo:self];
        }
    }
    else
    {
        [self initVideoLoader];
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_playerItemObject.schemedVideoURL options:nil];
        [[asset resourceLoader] setDelegate:_videoLoader queue:dispatch_get_main_queue()];
        
        __weak ZOWVideoPlayer *wself = self;
        
        [asset loadValuesAsynchronouslyForKeys:@[@"duration", @"playable", @"tracks"] completionHandler:^{
            if(!wself || wself.playerItemObject.schemedVideoURL != asset.URL)
            {
                NSLog(@"ready asset : %@ not in current playing context.", asset);
                return;
            }
            
            NSError *error1 = nil;
            NSError *error2 = nil;
            NSError *error3 = nil;
            AVKeyValueStatus playableStatus = [asset statusOfValueForKey:@"playable" error:&error1];
            AVKeyValueStatus durationStatus = [asset statusOfValueForKey:@"duration" error:&error2];
            AVKeyValueStatus tracksStatus = [asset statusOfValueForKey:@"tracks" error:&error3];
            if(error1 || error2 || error3)
            {
                NSLog(@"error loading asset status : %@", asset);
                wself.playerItemObject.status = ZOWVideoPlayerItemObjectStatusFailed;
                if([wself.dataSource respondsToSelector:@selector(videoPlayerView)] && [[wself.dataSource videoPlayerView] respondsToSelector:@selector(notifyLoadingVideoFailed)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                       [[wself.dataSource videoPlayerView] notifyLoadingVideoFailed];
                    });
                }
                return;
            }
            
            if(playableStatus == AVKeyValueStatusLoaded && durationStatus == AVKeyValueStatusLoaded && tracksStatus == AVKeyValueStatusLoaded)
            {
                NSLog(@"asset ready");
                AVPlayerItem *newItem = [[AVPlayerItem alloc] initWithAsset:asset];
                [wself observePlayerItem:newItem];
                /**
                 *  need to dispatch to main queue when in a block invoke.
                 */
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself launchPlayerWithItem:newItem];
                });
            }
        }];
    }
}

- (void)observePlayerItem:(AVPlayerItem *)item
{
    [item addObserver:self
           forKeyPath:@"status"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [item addObserver:self
           forKeyPath:@"playbackBufferEmpty"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [item addObserver:self
           forKeyPath:@"loadedTimeRanges"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [self.observingItem addObject:item];
}

- (void)initVideoLoader
{
    if(!_videoLoader)
    {
        _videoLoader = [[ZOWVideoSourceLoader alloc] init];
        _videoLoader.delegate = self;
    }
}

- (void)launchPlayerWithItem:(AVPlayerItem *)item
{
    [self configurePlayerWithItem:item];
    [self playVideo];
}

- (BOOL)prepareVideoLayer
{
    if([self isVideoViewAvailable])
    {
        UIView<ZOWVideoPlayerProtocol> *view = [self.dataSource videoPlayerView];
        if(!((AVPlayerLayer *)view.videoLayerContainerView.layer).player)
        {
            [(AVPlayerLayer *)view.videoLayerContainerView.layer setPlayer:_videoPlayer];
        }
        return YES;
    }
    else
    {
        NSLog(@"stoncle debug : could not find a view to play video on. Don't forget to set a data source");
        return NO;
    }
}

- (void)configurePlayerWithItem:(AVPlayerItem *)item
{
    if (_videoPlayer) {
        // remove item observer for current item, prepare for the new item.
        [self removeObservationOnPlayerItem:_videoPlayer.currentItem];
        [_videoPlayer replaceCurrentItemWithPlayerItem:item];
    }
    else
    {
        _videoPlayer = [AVPlayer playerWithPlayerItem:item];
        [_videoPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
        [self prepareVideoLayer];
    }
    [self addPlayerDidReachEndNotification];
}

- (BOOL)isVideoViewAvailable
{
    if([self.dataSource respondsToSelector:@selector(videoPlayerView)] && [self.dataSource videoPlayerView])
    {
        if([self.dataSource videoPlayerView].superview)
        {
            return YES;
        }
        else
        {
            NSLog(@"stoncle debug : video view need a superview");
            return NO;
        }
    }
    else
    {
        NSLog(@"stoncle debug : no video datasource");
        return NO;
    }
}

#pragma mark Observation
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object != [_videoPlayer currentItem]) {
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay:
                NSLog(@"video status ready to play");
                if([self.delegate respondsToSelector:@selector(videoPlayerDidStartPlayVideo:)])
                {
                    [self.delegate videoPlayerDidStartPlayVideo:self];
                }
                [self pause];
                break;
            case AVPlayerStatusFailed:
                // TODO:
                [self removeObservationOnPlayerItem:self.videoPlayer.currentItem];
                //                self.videoPlayer = nil;
                NSLog(@"video player status failed");
                if([self.delegate respondsToSelector:@selector(videoPlayerDidFailedPlayVideo:)])
                {
                    [self.delegate videoPlayerDidFailedPlayVideo:self];
                }
                break;
            case AVPlayerStatusUnknown:
                break;
        }
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"] && _videoPlayer.currentItem.playbackBufferEmpty) {
        [self pause];
        if([self.delegate respondsToSelector:@selector(videoPlayerDidStuck:)])
        {
            [self.delegate videoPlayerDidStuck:self];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        float bufferTime = [self availableDuration];
        double time = CMTimeGetSeconds([_videoPlayer currentTime]);
        
        if(time + _preloadBufferSecondsWhenStucked <= bufferTime || fabs(CMTimeGetSeconds(_videoPlayer.currentItem.duration) - (double)bufferTime) < 0.001)
        {
            if (![self isPlaying])
            {
                if(!_playerItemObject.isItemStartedStreaming)
                {
                    _playerItemObject.isItemStartedStreaming = YES;
                    if([self.delegate respondsToSelector:@selector(videoPlayerDidStartStreamVideo:)])
                    {
                        [self.delegate videoPlayerDidStartStreamVideo:self];
                    }
                }
                [self resumePlay];
            }
        }
        else
        {
            
        }
    }
    
    return;
}

- (void)removeObservationOnPlayerItem:(AVPlayerItem *)item
{
    if([_observingItem containsObject:item])
    {
        [item removeObserver:self forKeyPath:@"status"];
        [item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_observingItem removeObject:item];
    }
}

#pragma mark Notification
- (void)addPlayerDidReachEndNotification
{
    NSLog(@"stoncle debug : add player did reach end notification.");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.videoPlayer.currentItem];
}

- (void)removePlayerDidReachEndNotification
{
    NSLog(@"stoncle debug : remove player did reach end notification.");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.videoPlayer.currentItem];
}

- (void)addResignActiveNotification
{
    NSLog(@"stoncle debug : add video resign active notification.");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeResignActiveNotification
{
    NSLog(@"stoncle debug : remove video resign active notification.");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)addResumeFromBackgroundNotification
{
    NSLog(@"stoncle debug : add video background notification.");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResumeFromBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeResumeFromBackgroundNotification
{
    NSLog(@"stoncle debug : remove video background notification");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)willEnterBackground:(NSNotification *)note
{
    [self pause];
    NSLog(@"stoncle debug : will enter background, stop video play.");
}

- (void)didResumeFromBackground:(NSNotification *)note
{
    [self playVideo];
    NSLog(@"stoncle debug : did receive resume from background notification. replay video");
}

#pragma mark Video Play
- (float)availableDuration
{
    NSArray *loadedTimeRanges = [[self.videoPlayer currentItem] loadedTimeRanges];
    
    // Check to see if the timerange is not an empty array, fix for when video goes on airplay
    // and video doesn't include any time ranges
    if ([loadedTimeRanges count] > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        return (startSeconds + durationSeconds);
    } else {
        return 0.0f;
    }
}

- (BOOL)isPlaying
{
    if(!_videoPlayer)
    {
        NSLog(@"stoncle debug : attempt to access nil videoplayer");
        return NO;
    }
    else
    {
        return [_videoPlayer rate] != 0.0;
    }
}

- (void)resumePlay
{
    if([self.delegate respondsToSelector:@selector(videoPlayerDidResume:)])
    {
        [self.delegate videoPlayerDidResume:self];
    }
    [self playVideo];
}

- (void)playVideo
{
    if(_videoPlayer)
    {
        if ([self isVideoViewAvailable]) {
            // Configuration is done, ready to start.
            if([[NSThread currentThread] isMainThread])
            {
               [self.videoPlayer play];
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.videoPlayer play];
                });
            }
        }
    }
    else
    {
        NSLog(@"stoncle debug : attempt to play video from nil video player.");
    }
}

- (void)pauseVideo
{
    if(_videoPlayer)
    {
        if([[NSThread currentThread] isMainThread])
        {
            [self.videoPlayer pause];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.videoPlayer pause];
            });
        }
    }
    else
    {
        NSLog(@"stoncle debug : attempt to pause video from nil video player.");
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)note
{
    NSLog(@"play did reach end");
    if([self.delegate respondsToSelector:@selector(videoPlayerDidEndPlayVideo:)])
    {
        [self.delegate videoPlayerDidEndPlayVideo:self];
    }
    switch (self.endAction) {
        case ZOWVideoPlayerEndActionReset: {
            AVPlayerItem *p = [note object];
            [p seekToTime:kCMTimeZero];
            [_videoPlayer pause];
            if([self.delegate respondsToSelector:@selector(videoPlayerDidReset:)])
            {
                [self.delegate videoPlayerDidReset:self];
            }
            break;
        }
        case ZOWVideoPlayerEndActionPause: {
            [_videoPlayer pause];
            break;
        }
        case ZOWVideoPlayerEndActionRePlay: {
            AVPlayerItem *p = [note object];
            [p seekToTime:kCMTimeZero];
            [_videoPlayer play];
            break;
        }
    }
}

#pragma mark ZOWVideoSourceLoaderDelegate
- (void)sourceLoader:(ZOWVideoSourceLoader *)loader task:(NSURLSessionTask *)task didSuccessWithData:(NSData *)data
{
    if([self.dataSource respondsToSelector:@selector(videoPlayerView)] && [[self.dataSource videoPlayerView] respondsToSelector:@selector(notifyLoadingVideoSuccessed)])
    {
        [[self.dataSource videoPlayerView] notifyLoadingVideoSuccessed];
    }
}

- (void)sourceLoader:(ZOWVideoSourceLoader *)loader task:(NSURLSessionTask *)task didFailedWithError:(NSError *)error
{
    _playerItemObject.status = ZOWVideoPlayerItemObjectStatusFailed;
    if([self.dataSource respondsToSelector:@selector(videoPlayerView)] && [[self.dataSource videoPlayerView] respondsToSelector:@selector(notifyLoadingVideoFailed)])
    {
        [[self.dataSource videoPlayerView] notifyLoadingVideoFailed];
    }
}

- (void)sourceLoader:(ZOWVideoSourceLoader *)loader taskDidCancel:(NSURLSessionTask *)task
{
    if([self.dataSource respondsToSelector:@selector(videoPlayerView)] && [[self.dataSource videoPlayerView] respondsToSelector:@selector(notifyCancelLoadingVideo)])
    {
        [[self.dataSource videoPlayerView] notifyCancelLoadingVideo];
    }
}

#pragma mark - SETTER
- (void)setMute:(BOOL)mute
{
    if(_videoPlayer)
    {
        [_videoPlayer setMuted:mute];
        NSLog(@"stoncle debug : set player mute %d", mute);
        _mute = mute;
        if([self.delegate respondsToSelector:@selector(videoPlayer:didMuted:)])
        {
            [self.delegate videoPlayer:self didMuted:mute];
        }
        else
        {
            NSLog(@"stoncle debug : player delegate nil.");
        }
    }
    else
    {
        NSLog(@"stoncle debug : set player mute but player nil.");
    }
}

#pragma mark - Getter
- (NSString *)videoCachedDirectory
{
    if (_videoCachedDirectory)
    {
        return _videoCachedDirectory;
    }
    else
    {
        _videoCachedDirectory = [ZOWVideoCache sharedVideoCache].videoCachedDirectoryPath;
        return _videoCachedDirectory;
    }
}

#pragma mark - OVERIDE
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObservationOnPlayerItem:self.videoPlayer.currentItem];
    if(_observingItem.count)
    {
        for(AVPlayerItem *item in _observingItem)
        {
            [self removeObservationOnPlayerItem:item];
            [_observingItem removeObject:item];
        }
    }
}

@end
