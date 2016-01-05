//
//  InstagramViewController.m
//  Example
//
//  Created by stoncle on 1/5/16.
//  Copyright © 2016 stoncle. All rights reserved.
//

#import "InstagramViewController.h"
#import "ZOWVideoView.h"
#import "InstagramVideoView.h"

@interface InstagramViewController ()

@property (nonatomic, strong) ZOWVideoView *videoView;

@end

@implementation InstagramViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    _videoView = [[InstagramVideoView alloc] initWithFrame:CGRectMake(20, 20+64, 300, 300)];
    _videoView.backgroundColor = [UIColor grayColor];
    
    UIButton *pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 400+64, 100, 30)];
    pauseButton.backgroundColor = [UIColor yellowColor];
    [pauseButton setTitle:@"stuck" forState:UIControlStateNormal];
    [pauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pauseVideo:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 400+64, 100, 30)];
    [playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    playButton.backgroundColor = [UIColor greenColor];
    [playButton setTitle:@"play" forState:UIControlStateNormal];
    [playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIButton *muteButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 400+64, 100, 30)];
    [muteButton addTarget:self action:@selector(muteVideo:) forControlEvents:UIControlEventTouchUpInside];
    muteButton.backgroundColor = [UIColor redColor];
    [muteButton setTitle:@"mute" forState:UIControlStateNormal];
    [muteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:pauseButton];
    [self.view addSubview:playButton];
    [self.view addSubview:muteButton];
    [self.view addSubview:_videoView];
}

- (void)pauseVideo:(id)sender {
    [_videoView pause];
    [_videoView performSelector:@selector(videoPlayerDidStuck:) withObject:nil];
}

- (void)playVideo:(id)sender {
    [_videoView resume];
}

- (void)muteVideo:(id)sender {
    if (_videoView.videoPlayer.mute) {
        [_videoView unmute];
    } else {
        [_videoView mute];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_videoView playVideoWithURL:[NSURL URLWithString:@"https://mvvideo5.meitudata.com/5678f6d2adf115463.mp4"]];
}

@end
