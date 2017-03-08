//
//  TPLRestaurantManager.m
//  FoodWise
//
//  Created by Brian Wong on 3/6/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLRestaurantManager.h"

#import "FoodWiseDefines.h"

typedef void(^DetailCompletionBlock)(id restaurantDetails);

@interface TPLRestaurantManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, copy) DetailCompletionBlock detailCompletion;

@end

@implementation TPLRestaurantManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.sessionManager = [[AFHTTPSessionManager alloc]init];
        
    }
    return self;
}

#pragma mark - GET Methods

- (void)getRestaurantDetailsFor:(NSString *)restaurantId
                     atLocation:(CLLocationCoordinate2D)coordinate
              completionHandler:(void (^)(id details))completionHandler
                 failureHandler:(void (^)(id error))failureHandler{
    
    NSString *detailURL = [NSString stringWithFormat:YUM_PLACES_DETAILS, restaurantId];
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    NSDictionary *params = @{@"lat" : lat, @"lng" : lng};
    
    self.detailCompletion = completionHandler;
    
    [self.sessionManager GET:detailURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        NSString *workerId = responseObject[@"worker_id"];
        if (workerId && workerId.length > 0) {
            [self runWorkerRecursively:workerId withParameters:params completionHandler:^(id workerResult) {
                self.detailCompletion(workerResult);
            } failureHandler:^(id error) {
                self.detailCompletion(error);
            }];
        }else{
            self.detailCompletion(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

#pragma mark - POST Methods
- (void)submitReviewForRestaurant:(NSString *)restaurantId
                    overallRating:(NSString *)rating
                      healthScore:(NSString *)health
                            price:(NSString *)price
                            photo:(NSData *)photoData{
    
    NSString *postURL = [NSString stringWithFormat:YUM_PLACES_REVIEWS, restaurantId];
    NSDictionary *ratingsDict = @{@"place_id" : restaurantId};
    
    [self.sessionManager POST:postURL parameters:ratingsDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed to submit review");
    }];
    
}

#pragma mark - Helper Methods

- (void)runWorkerRecursively:(NSString *)worker_id
              withParameters:(NSDictionary *)params
           completionHandler:(void (^)(id workerResult))completionHandler
              failureHandler:(void (^)(id error))failureHandler{
    NSString *workerURL = [NSString stringWithFormat:YUM_WORKER_DETAILS, worker_id];
    [self.sessionManager GET:workerURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *workerStatus = responseObject[@"worker_status"];
        if ([workerStatus isEqualToString:@"finished"]) {
            NSMutableArray *chartsInfo = responseObject[@"result"];
            completionHandler(chartsInfo);
            return;
        }else{
            [self runWorkerRecursively:worker_id withParameters:params completionHandler:completionHandler failureHandler:failureHandler];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error with worker recursion: %@", error.localizedDescription);
    }];
    
}

@end
