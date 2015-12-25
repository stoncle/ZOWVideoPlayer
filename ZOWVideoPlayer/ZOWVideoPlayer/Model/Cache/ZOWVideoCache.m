//
//  ZOWVideoCache.m
//  InstaGrab
//
//  Created by stoncle on 11/14/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ZOWVideoCache.h"
#import "NSString+Suffix.h"
#import "NSString+Md5.h"

@implementation ZOWVideoCache

+ (instancetype)sharedVideoCache
{
    static dispatch_once_t once;
    static ZOWVideoCache *instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
        // 1 day
        instance.maxCacheAge = 24 * 60 * 60;
        // 100m
        instance.maxCacheSize = 100 * 1024 * 1024;
        // 150m
        instance.enduranceSize = 150 * 1024 * 1024;
        
        instance.videoCachedDirectoryPath = [self getVideoMediaDownloadCacheDirectory];
    });
    return instance;
}

- (NSUInteger)getCacheCount
{
    NSArray *filelist= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.videoCachedDirectoryPath error:nil];
    NSUInteger filesCount = [filelist count];
    return filesCount;
}

- (NSUInteger)getCacheSize
{
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:self.videoCachedDirectoryPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    NSUInteger fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.videoCachedDirectoryPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}

- (void)cacheVideoWithData:(NSData *)data withOriginalURLString:(NSString *)urlString
{
    if(![self checkIfCacheSpaceAvailable])
    {
        [self cleanCache];
    }
    if([self checkIfCacheOverFlow])
    {
        [self clearAllCache];
    }
   
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.videoCachedDirectoryPath, [urlString.ZOWMD5String generateStringWithSuffix:urlString.suffix]];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:self.videoCachedDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if(error)
    {
        NSLog(@"ZOWVideoCache:write video data error.");
    }
    else
    {
        [data writeToFile:filePath atomically:YES];
    }
}

- (BOOL)ifVideoCacheWithOriginalURLString:(NSString *)urlString
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getVideoCachePathForURLString:urlString]];
}

- (NSString *)getVideoCachePathForURLString:(NSString *)urlString
{
    return [NSString stringWithFormat:@"%@/%@", self.videoCachedDirectoryPath, [urlString.ZOWMD5String generateStringWithSuffix:urlString.suffix]];
}

- (void)clearAllCache
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.videoCachedDirectoryPath error:&error];
    if(error)
    {
        NSLog(@"ZOWVideoCache : clear all cache error.");
    }
}

- (void)cleanCache
{
    [self eliminateToFixCache];
}

#pragma mark - PRIVATE
- (BOOL)checkIfCacheSpaceAvailable
{
    NSUInteger cachedSize = [self getCacheSize];
    if(self.maxCacheSize > 0 && cachedSize >= self.maxCacheSize)
    {
        return NO;
    }
    return YES;
}

- (BOOL)checkIfCacheOverFlow
{
    NSUInteger cachedSize = [self getCacheSize];
    if(cachedSize >= self.enduranceSize)
    {
        return YES;
    }
    return NO;
}

- (void)eliminateToFixCache
{
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.videoCachedDirectoryPath isDirectory:YES];
    NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
    
    // This enumerator prefetches useful properties for our cache files.
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:diskCacheURL
                                               includingPropertiesForKeys:resourceKeys
                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                             errorHandler:NULL];
    
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
    NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
    NSUInteger currentCacheSize = 0;
    
    // Enumerate all of the files in the cache directory.  This loop has two purposes:
    //
    //  1. Removing files that are older than the expiration date.
    //  2. Storing file attributes for the size-based cleanup pass.
    NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        
        // Skip directories.
        if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        
        // Remove files that are older than the expiration date;
        NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
        if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
            [urlsToDelete addObject:fileURL];
            continue;
        }
        
        // Store a reference to this file and account for its total size.
        NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
        currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
        [cacheFiles setObject:resourceValues forKey:fileURL];
    }
    
    for (NSURL *fileURL in urlsToDelete) {
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
    }
    
    
    // If our remaining disk cache exceeds a configured maximum size, perform a second
    // size-based cleanup pass.  We delete the oldest files first.
    if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
        // Target half of our maximum cache size for this cleanup pass.
        const NSUInteger desiredCacheSize = self.maxCacheSize / 2;
        
        // Sort the remaining cache files by their last modification time (oldest first).
        NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                        usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                            return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                        }];
        
        // Delete files until we fall below our desired cache size.
        for (NSURL *fileURL in sortedFiles) {
            if ([[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil]) {
                NSDictionary *resourceValues = cacheFiles[fileURL];
                NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                
                if (currentCacheSize < desiredCacheSize) {
                    break;
                }
            }
        }
    }
}

#pragma mark Getters
- (NSString *)videoCachedDirectoryPath
{
    if (_videoCachedDirectoryPath)
    {
        return _videoCachedDirectoryPath;
    }
    else
    {
        _videoCachedDirectoryPath = [ZOWVideoCache getVideoMediaDownloadCacheDirectory];
        return _videoCachedDirectoryPath;
    }
}


#pragma mark - FILE
+ (NSString *)getVideoMediaDownloadCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:@"com.ZOWVideoCache"];
}

@end
