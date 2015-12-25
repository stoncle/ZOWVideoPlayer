//
//  ZOWSchemedURL.h
//  InstaGrab
//
//  Created by stoncle on 11/12/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZOWSchemedURL : NSObject

+ (NSURL *)getSchemedURLWithOriginalURL:(NSURL *)url customScheme:(NSString *)scheme;
+ (NSURL *)getOriginalURLWithSchemedURL:(NSURL *)url customScheme:(NSString *)scheme;

@end
