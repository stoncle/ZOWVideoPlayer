//
//  NSString+Suffix.m
//  ZOWVideoPlayer
//
//  Created by stoncle on 12/11/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "NSString+Suffix.h"

@implementation NSString (Suffix)

- (NSString *)suffix
{
    NSString *suffix = [[self componentsSeparatedByString:@"."] lastObject];
    return suffix;
}

- (NSString *)generateStringWithSuffix:(NSString *)suffix
{
    if(!suffix || [suffix isEqualToString:@""]) {
        NSLog(@"attempt to add blank suffix.");
        return nil;
    }
    NSString *pureString = [self getPureStringWithoutSuffix];
    return [pureString stringByAppendingString:[NSString stringWithFormat:@".%@", suffix]];
}

- (NSString *)getPureStringWithoutSuffix
{
    NSString *pureString = [[self componentsSeparatedByString:@"."] firstObject];
    return pureString;
}

- (BOOL)isVideoSuffix
{
    NSArray<NSString *> *videoSuffixArray = @[@"mp4", @"mov", @"avi", @"rm", @"rmvb"];
    for (NSString *suffix in videoSuffixArray) {
        if([self hasSuffix:suffix]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isImageSuffix
{
    NSArray<NSString *> *imageSuffixArray = @[@"png", @"jpg", @"jpeg", @"gif"];
    for (NSString *suffix in imageSuffixArray) {
        if([self hasSuffix:suffix]) {
            return YES;
        }
    }
    return NO;
}

@end
