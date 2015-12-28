//
//  ViewController.m
//  Example
//
//  Created by stoncle on 12/18/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ViewController.h"
#import "InstagramVideoView.h"

@interface ViewController ()

@property (nonatomic, strong) ZOWVideoView *videoView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _videoView = [[InstagramVideoView alloc] initWithFrame:CGRectMake(20, 20, 300, 300)];
    
    UIButton *pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 400, 100, 30)];
    pauseButton.backgroundColor = [UIColor yellowColor];
    [pauseButton setTitle:@"pause" forState:UIControlStateNormal];
    [pauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pauseVideo:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 400, 100, 30)];
    [playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    playButton.backgroundColor = [UIColor greenColor];
    [playButton setTitle:@"play" forState:UIControlStateNormal];
    [playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIButton *stopButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 400, 100, 30)];
    [stopButton addTarget:self action:@selector(stopVideo:) forControlEvents:UIControlEventTouchUpInside];
    stopButton.backgroundColor = [UIColor redColor];
    [stopButton setTitle:@"stop" forState:UIControlStateNormal];
    [stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:pauseButton];
    [self.view addSubview:playButton];
    [self.view addSubview:stopButton];
    [self.view addSubview:_videoView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)pauseVideo:(id)sender {
    [_videoView pause];
}

- (void)playVideo:(id)sender {
    [_videoView resume];
}

- (void)stopVideo:(id)sender {
    [_videoView stopVideoPlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_videoView playVideoWithURL:[NSURL URLWithString:@"https://mvvideo5.meitudata.com/5678f6d2adf115463.mp4"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
