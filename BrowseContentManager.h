//
//  BrowseContentManager.h
//  Foodhead
//
//  Created by Brian Wong on 5/3/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>

@interface BrowseContentManager : NSObject

//GET Methods
- (void)getBrowseContentWithCompletion:(void (^)(NSMutableArray* media))completionHandler
                 failureHandler:(void (^)(id error))failureHandler;

@end
