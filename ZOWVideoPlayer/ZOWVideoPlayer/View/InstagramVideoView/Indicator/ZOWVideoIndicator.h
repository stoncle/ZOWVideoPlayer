//
//  ZOWVideoIndicator.h
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/14/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZOWVideoIndicator : UIView

@property (nonatomic) NSTimeInterval cycleDuration;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, readonly) BOOL isAnimating;

- (void)startAnimating;

- (void)stopAnimating;

@end
