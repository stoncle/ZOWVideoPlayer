# ZOWVideoPlayer


# Usage
Drag ZOWVideoPlayer folder into your project, then link **MobileCoreServices.framework**, **CoreMedia.framework** and **AVFoundation.framework** in your project Build Phases.

## Play Videos
You can **#import "ZOWVideoPlayer.h"** and call

    [self.videoPlayer playVideoWithURL:url];
    
to play a web video. In this way, you need to build video view yourself to sync the video behavior, for example, show loading indicator when video stucked. You can provide video view through a ZOWVideoPlayer.datasource, and receive event in ZOWVideoPlayer.delegate.
### Play video through a established view(Recomended)
A ZOWVideoPlayerView is designed to handle the view issue besides the main video play process. You can subclass it to customize your own view behaviors.

You can play video through a ZOWVideoPlayerView subclass with 

    [self.videoView playVideoWithURL:url];
    
and the view itself will handle the video behaviors.
Check the **InstagramVideoView** implementation example in the project to learn more about the subclassing.

## Features
### Preload Buffer
  if video play stuck when loading, the player will pause and prebuffer a few seconds to provide a merely smooth video play.
### Cache
  when a web video finishes play, the video will be auto cached. And when the next time you play the video through the **same url**, the cached video will be played. You can customize the video cached path through the **videoCachedDirectory** property.
### End Action
  provide end action to define the behavior of the video when video play reaching the end. You can reset the video status or replay it or just pause it at the end.
### Background Resume
  on default, the video play will auto pause when enter background, and auto resume when enter foreground. Set **autoResumeFromBackground** to NO to avoid auto resume. 
