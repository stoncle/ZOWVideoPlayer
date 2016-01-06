//
//  CommonVideoViewController.m
//  Example
//
//  Created by stoncle on 1/6/16.
//  Copyright © 2016 stoncle. All rights reserved.
//

#import "CommonVideoViewController.h"
#import "ZOWVideoView.h"
#import "CommonVideoView.h"

@interface CommonVideoViewController ()

@property (nonatomic, strong) CommonVideoView *videoView;

@end

@implementation CommonVideoViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    _videoView = [[CommonVideoView alloc] initWithFrame:CGRectMake(20, 20+64, 300, 300)];
    _videoView.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:_videoView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_videoView playVideoWithURL:[NSURL URLWithString:@"https://mvvideo5.meitudata.com/5678f6d2adf115463.mp4"]];
}

@end
