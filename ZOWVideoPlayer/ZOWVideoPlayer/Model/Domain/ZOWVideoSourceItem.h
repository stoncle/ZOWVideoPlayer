//
//  ZOWVideoSourceItem.h
//  InstaGrab
//
//  Created by stoncle on 11/12/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVAssetResourceLoadingRequest;

@interface ZOWVideoSourceItem : NSObject

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableArray<AVAssetResourceLoadingRequest*> *requests;
@property (nonatomic, strong) NSURLSessionTask *task;

@end
