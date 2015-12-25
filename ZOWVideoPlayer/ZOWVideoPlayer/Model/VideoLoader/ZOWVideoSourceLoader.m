//
//  ZOWVideoSourceLoader.m
//  ZOWVideoPlayer
//
//  Created by stoncle on 11/12/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ZOWVideoSourceLoader.h"
#import "ZOWSchemedURL.h"
#import "ZOWThreadDictionary.h"
#import "ZOWVideoSourceItem.h"
#import "ZOWVideoCache.h"

#import <MobileCoreServices/MobileCoreServices.h>

const NSString *preDefineCustomScheme = @"ZOW";

@interface ZOWVideoSourceLoader () <NSURLSessionDataDelegate>

@property (nonatomic, strong) ZOWThreadDictionary *processingItems;

@property (nonatomic, strong) ZOWThreadDictionary *launchedTasks;

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ZOWVideoSourceLoader

- (instancetype)init
{
    if(self = [super init])
    {
        _processingItems = [[ZOWThreadDictionary alloc] init];
        _launchedTasks = [[ZOWThreadDictionary alloc] init];
        [self configureSession];
    }
    return self;
}

- (void)stopLoadingURL:(NSURL *)url
{
    NSLog(@"stop loading url");
    if(_launchedTasks[url])
    {
        NSURLSessionTask *task = _launchedTasks[url];
        NSLog(@"canel loading task : %@", task);
        [task cancel];
    }
}

#pragma mark - DELEGATE
#pragma mark AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *originalURL = [ZOWSchemedURL getOriginalURLWithSchemedURL:loadingRequest.request.URL customScheme:[preDefineCustomScheme copy]];
    ZOWVideoSourceItem *item = _processingItems[originalURL];
    if(!item)
    {
        item = [[ZOWVideoSourceItem alloc] init];
        item.requests = [NSMutableArray array];
        _processingItems[originalURL] = item;
    }
    
    [item.requests addObject:loadingRequest];
    if(!item.task)
    {
        item.task = [self launchTaskWithURL:originalURL];
    }
    [self processRequestWithURL:originalURL];
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"canceled");
    NSURL *schemedURL = loadingRequest.request.URL;
    NSURL *originalURL = [ZOWSchemedURL getOriginalURLWithSchemedURL:schemedURL customScheme:[preDefineCustomScheme copy]];
    ZOWVideoSourceItem *item = _processingItems[originalURL];
    [item.requests removeObject:loadingRequest];
}

#pragma mark NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"did receive responce");
    
    ZOWVideoSourceItem *item = _processingItems[dataTask.originalRequest.URL];
    item.receivedData = [NSMutableData data];
    item.response = response;
    [self processRequestWithURL:dataTask.originalRequest.URL];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
//    NSLog(@"did receive data");
    ZOWVideoSourceItem *item = _processingItems[dataTask.originalRequest.URL];
    [item.receivedData appendData:data];
    [self processRequestWithURL:dataTask.originalRequest.URL];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    ZOWVideoSourceItem *item = _processingItems[task.originalRequest.URL];
    [self processRequestWithURL:task.originalRequest.URL];
    if(!error)
    {
        NSLog(@"Download complete");
        if([self.delegate respondsToSelector:@selector(sourceLoader:task:didSuccessWithData:)])
        {
            [self.delegate sourceLoader:self task:task didSuccessWithData:item.receivedData];
        }
        [[ZOWVideoCache sharedVideoCache] cacheVideoWithData:item.receivedData withOriginalURLString:task.originalRequest.URL.absoluteString];
    }
    else if(error && error.code == -999)
    {
        NSLog(@"Download canceled");
        if([self.delegate respondsToSelector:@selector(sourceLoader:taskDidCancel:)])
        {
            [self.delegate sourceLoader:self taskDidCancel:task];
        }
    }
    else{
        NSLog(@"%@", error);
        if([self.delegate respondsToSelector:@selector(sourceLoader:task:didFailedWithError:)])
        {
            [self.delegate sourceLoader:self task:task didFailedWithError:error];
        }
    }
    [_launchedTasks removeObjectForKey:task.originalRequest.URL];
    [_processingItems removeObjectForKey:task.originalRequest.URL];
}

#pragma mark - NETWORK
#pragma mark Session
- (void)configureSession
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPMaximumConnectionsPerHost = 1;
    config.timeoutIntervalForResource = 0;
    config.timeoutIntervalForRequest = 100;
    _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
}

- (void)processRequestWithURL:(NSURL *)originalURL
{
    NSMutableArray *requestsCompleted = [NSMutableArray array];
    ZOWVideoSourceItem *processingRequest = self.processingItems[originalURL];
    for(int i=0; i<processingRequest.requests.count; i++)
    {
        AVAssetResourceLoadingRequest *loadingRequest = processingRequest.requests[i];
        [self fillInContentInformation:loadingRequest inItem:processingRequest];
        
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest inItem:processingRequest];
        
        if (didRespondCompletely){
            [requestsCompleted addObject:loadingRequest];
            if(!loadingRequest.isFinished)
            {
                [loadingRequest finishLoading];
            }
        }
    }
    
    for(AVAssetResourceLoadingRequest *request in requestsCompleted)
    {
       [processingRequest.requests removeObject:request];
    }
    
}

- (void)fillInContentInformation:(AVAssetResourceLoadingRequest *)request inItem:(ZOWVideoSourceItem *)item {
    if (item == nil || item.response == nil){
        return;
    }
    
    NSString *mimeType = [item.response MIMEType];
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    
    request.contentInformationRequest.byteRangeAccessSupported = YES;
    request.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    request.contentInformationRequest.contentLength = [item.response expectedContentLength];
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingRequest *)request inItem:(ZOWVideoSourceItem *)item{
    long long startOffset = request.dataRequest.requestedOffset;
    if (request.dataRequest.currentOffset != 0){
        startOffset = request.dataRequest.currentOffset;
    }
    
    // Don't have any data at all for this request
    if (item.receivedData.length < startOffset){
        return NO;
    }
    
    // This is the total data we have from startOffset to whatever has been downloaded so far
    NSUInteger unreadBytes = item.receivedData.length - (NSUInteger)startOffset;
    // Respond with whatever is available if we can't satisfy the request fully yet
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)request.dataRequest.requestedLength, unreadBytes);
    
//    NSLog(@"data:%lu,,,(%lld,%lu)",(unsigned long)item.receivedData.length,startOffset,(unsigned long)numberOfBytesToRespondWith);
    [request.dataRequest respondWithData:[item.receivedData subdataWithRange:NSMakeRange((NSUInteger)startOffset, numberOfBytesToRespondWith)]];
    
    long long endOffset = startOffset + request.dataRequest.requestedLength;
    BOOL didRespondFully = item.receivedData.length >= endOffset;
    
    return didRespondFully;
}

#pragma mark SessionTask
- (NSURLSessionTask *)launchTaskWithURL:(NSURL *)url
{
    NSURLSessionTask *task;
    if(!_launchedTasks[url])
    {
        NSLog(@"fuck launch task ing.....");
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        task = [_session dataTaskWithRequest:request];
        _launchedTasks[url] = task;
        [task resume];
    }
    else
    {
        task = _launchedTasks[url];
    }
    return task;
}

@end
