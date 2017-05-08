//
//  BrowseContentManager.m
//  Foodhead
//
//  Created by Brian Wong on 5/3/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "BrowseContentManager.h"
#import "FoodWiseDefines.h"
#import "BrowseVideo.h"

@interface BrowseContentManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation BrowseContentManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.sessionManager = [[AFHTTPSessionManager alloc]init];
    }
    return self;
}

- (void)getBrowseContentWithCompletion:(void (^)(NSMutableArray *media))completionHandler
                        failureHandler:(void (^)(id))failureHandler{
    [self.sessionManager GET:API_PLACES_BROWSE_POSTS parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *response = responseObject;
        NSMutableArray *content = [NSMutableArray array];
        for (NSDictionary *contentInfo in response) {
            BrowseVideo *video = [MTLJSONAdapter modelOfClass:[BrowseVideo class] fromJSONDictionary:contentInfo error:nil];
            [content addObject:video];
        }
        completionHandler(content);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *userInfo = [error userInfo];
        NSData* errorData = userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (errorData) {
            NSDictionary *err = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
            DLog(@"%@", err[@"error"]);
        }
        failureHandler(error);
    }];
}

@end
