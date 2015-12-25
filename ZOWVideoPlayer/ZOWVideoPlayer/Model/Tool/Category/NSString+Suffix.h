//
//  NSString+Suffix.h
//  ZOWVideoPlayer
//
//  Created by stoncle on 12/11/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Suffix)

@property (nonatomic, readonly, copy) NSString *suffix;

- (NSString *)generateStringWithSuffix:(NSString *)suffix;
- (NSString *)getPureStringWithoutSuffix;
- (BOOL)isVideoSuffix;
- (BOOL)isImageSuffix;

@end
