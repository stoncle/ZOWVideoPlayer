//
//  ZOWSchemedURL.m
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/12/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ZOWSchemedURL.h"

@implementation ZOWSchemedURL

+ (NSURL *)getSchemedURLWithOriginalURL:(NSURL *)url customScheme:(NSString *)scheme
{
    if(!url)
    {
        return nil;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = [scheme stringByAppendingString:components.scheme];
    return components.URL;
}

+ (NSURL *)getOriginalURLWithSchemedURL:(NSURL *)url customScheme:(NSString *)scheme
{
    if(!url)
    {
        return nil;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = [components.scheme stringByReplacingOccurrencesOfString:scheme withString:@""];
    return components.URL;
}

@end
