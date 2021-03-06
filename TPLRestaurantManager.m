//
//  TPLRestaurantManager.m
//  FoodWise
//
//  Created by Brian Wong on 3/6/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLRestaurantManager.h"
#import "FoodWiseDefines.h"
#import "Category.h"
#import "TPLDetailedRestaurant.h"

#import <SAMKeychain/SAMKeychain.h>

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
    
    NSString *detailURL = [NSString stringWithFormat:API_PLACE_DETAIL, restaurantId];
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    NSDictionary *params = @{@"lat" : lat, @"lng" : lng};
    
    self.detailCompletion = completionHandler;
    [self.sessionManager GET:detailURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *workerId = responseObject[@"worker_id"];
        if (workerId && workerId.length > 0) {
            [self runWorkerRecursively:workerId withParameters:params completionHandler:^(id workerResult) {
                self.detailCompletion(workerResult);
            } failureHandler:^(id error) {
                failureHandler(error);
            }];
        }else{
            self.detailCompletion(responseObject);
        }
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

- (void)getReviewsForRestaurant:(NSString *)restaurantId
              completionHandler:(void (^)(id reviews))completionHandler
                 failureHandler:(void (^)(id error))failureHandler{
    NSString *getURL = [NSString stringWithFormat:API_REVIEW, restaurantId];
    [self.sessionManager GET:getURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *userInfo = [error userInfo];
        NSData* errorData = userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (errorData) {
            NSDictionary *err = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
            DLog(@"%@", err);
        }
        failureHandler(error);
    }];
}

- (void)getMediaForRestaurant:(TPLRestaurant *)restaurant
                         page:(NSString *)pageNumber
            completionHandler:(void (^)(id mediaData))completionHandler
               failureHandler:(void (^)(id error))failureHandler{
    NSString *getURL = [NSString stringWithFormat:API_PLACE_MEDIA, restaurant.foursqId];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    //All necessary to potentially find instagram images using FB API.
    [params setObject:[restaurant.latitude stringValue] forKey:@"place_lat"];
    [params setObject:[restaurant.longitude stringValue] forKey:@"place_lng"];
    [params setObject:restaurant.name forKey:@"place_name"];
    if (pageNumber) {
        [params setObject:pageNumber forKey:@"page"];
    }
    
    [self.sessionManager GET:getURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *userInfo = [error userInfo];
        NSData* errorData = userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (errorData) {
            NSDictionary *err = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
            DLog(@"Failed to retrieve restaurant media: %@", err[@"error"]);
        }
        failureHandler(error);
    }];
}

- (void)getRestaurantsWithQuery:(NSString *)query
                     atLocation:(CLLocationCoordinate2D)coordinate
                        filters:(NSMutableDictionary *)filterParams
                           page:(NSString *)pageNum
              completionHandler:(void (^)(NSDictionary *restaurants))completionHandler
                 failureHandler:(void (^)(id))failureHandler{
    
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:query forKey:@"query"];
    [params setValue:lat forKey:@"lat"];
    [params setValue:lng forKey:@"lng"];
    [params setValue:pageNum forKey:@"page"];
    [params addEntriesFromDictionary:filterParams];
    
    [self.sessionManager GET:API_PLACES parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *result = [NSMutableArray array];
        NSNumber *nextPg = responseObject[@"next_page"];
        NSString *nextPgStr = [nextPg stringValue];
        for (NSDictionary *restDict in responseObject[@"result"]) {
            TPLRestaurant *restaurant = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:restDict error:nil];
            TPLDetailedRestaurant *details = [MTLJSONAdapter modelOfClass:[TPLDetailedRestaurant class] fromJSONDictionary:restDict error:nil];
            [restaurant mergeValuesForKeysFromModel:details];
            [result addObject:restaurant];
        }
        if (result.count == 0) {
            nextPgStr = @"";
        }
        NSDictionary *parsedResults = @{@"nextPage" : nextPgStr, @"results" : result};
        completionHandler(parsedResults);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *userInfo = [error userInfo];
        NSData* errorData = userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (errorData) {
            //NSDictionary *err = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
            //DLog(@"Failed to retrieve restaurant media: %@", err[@"error"]);
        }
        failureHandler(error);
    }];
}

#pragma mark - Autocomplete

- (void)searchRestaurantsWithQuery:(NSString *)queryStr
                        atLocation:(CLLocationCoordinate2D)coordinate
                 completionHandler:(void (^)(id results))completionHandler
                    failureHandler:(void (^)(id error))failureHandler
{
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    NSDictionary *params = @{@"query" : queryStr, @"lat" : lat, @"lng" : lng};
    [self.sessionManager GET:API_PLACE_SUGGESTIONS parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *userInfo = [error userInfo];
        NSData* errorData = userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (errorData) {
            NSDictionary *err = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
            DLog(@"%@", err);
        }
        failureHandler(error);
    }];
}

- (void)fullRestaurantSearchWithQuery:(NSString *)queryStr
                           atLocation:(CLLocationCoordinate2D)coordinate
                    completionHandler:(void (^)(id))completionHandler
                       failureHandler:(void (^)(id))failureHandler
{
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:queryStr forKey:@"query"];
    [paramDict setValue:lat forKey:@"lat"];
    [paramDict setValue:lng forKey:@"lng"];
    
    [self.sessionManager GET:API_PLACE_SEARCH parameters:paramDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *result = [NSMutableArray array];
        //Parse categories first b/c we want to show them first;
        NSArray *categories = responseObject[@"categories"];
        for (NSDictionary *cat in categories) {
            Category *category = [MTLJSONAdapter modelOfClass:[Category class] fromJSONDictionary:cat error:nil];
            [result addObject:category];
        }
        NSArray *suggestions = responseObject[@"suggestions"];
        for (NSDictionary *sug in suggestions) {
            TPLRestaurant *suggestion = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:sug error:nil];
            [result addObject:suggestion];
        }
        completionHandler(result);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *userInfo = [error userInfo];
        NSData* errorData = userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (errorData) {
            NSDictionary *err = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
            DLog(@"%@", err);
        }
        failureHandler(error);
    }];
}

#pragma mark - POST Methods
- (void)submitReviewForRestaurant:(NSString *)restaurantId
                    overallRating:(NSString *)rating
                      healthScore:(NSString *)health
                            price:(NSString *)price
                            photo:(NSData *)photoData
                completionHandler:(void (^)(id success))completionHandler
                   failureHandler:(void (^)(id error))failureHandler
{
    NSString *postURL = [NSString stringWithFormat:API_REVIEW, restaurantId];
    NSString *auth_token = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    
    [self.sessionManager.requestSerializer setValue:auth_token forHTTPHeaderField:@"AUTHTOKEN"];
    [self.sessionManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    NSURLRequest *request = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:postURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFormData:[restaurantId dataUsingEncoding:NSUTF8StringEncoding] name:@"place_id"];
        if (rating) {
            [formData appendPartWithFormData:[rating dataUsingEncoding:NSUTF8StringEncoding] name:@"like"];
        }
        if (price) {
            [formData appendPartWithFormData:[price dataUsingEncoding:NSUTF8StringEncoding] name:@"price"];
        }
        if (health) {
            [formData appendPartWithFormData:[health dataUsingEncoding:NSUTF8StringEncoding] name:@"healthiness"];
        }
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss a"];
        [formData appendPartWithFileData:photoData name:@"shot" fileName:[NSString stringWithFormat:@"img_%@", [dateFormatter stringFromDate:[NSDate date]]] mimeType:@"image/png"];
    } error:nil];

    NSURLSessionDataTask *task = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSDictionary *userInfo = [error userInfo];
            NSData* errorData = userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            if (errorData) {
                NSDictionary *err = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
                DLog(@"%@", err);
            }
            failureHandler(error);
        }else{
            completionHandler(response);

        }
    }];
    [task resume];
}

#pragma mark - Helper Methods

- (void)runWorkerRecursively:(NSString *)worker_id
              withParameters:(NSDictionary *)params
           completionHandler:(void (^)(id workerResult))completionHandler
              failureHandler:(void (^)(id error))failureHandler{
    NSString *workerURL = [NSString stringWithFormat:API_WORKER_DETAILS, worker_id];
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
        DLog(@"Error with worker recursion: %@", error.localizedDescription);
    }];
    
}

@end
