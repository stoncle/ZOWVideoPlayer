//
//  ZOWThreadDictionary.h
//  AVPlayerTest
//
//  Created by stoncle on 11/12/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZOWThreadDictionary : NSObject

@property (readonly, copy) NSArray *allKeys;
@property (readonly, copy) NSArray *allValues;

- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;

@end
