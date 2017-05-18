//
//  TPLRestaurantStore.m
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartsDataSource.h"
#import "FoodWiseDefines.h"
#import "Chart.h"
#import "Places.h"
#import "TPLRestaurant.h"

#import <ReactiveObjC/ReactiveObjC.h>

@interface TPLChartsDataSource ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableArray *placesData;
@property (nonatomic, strong) dispatch_source_t timer;


@end

@implementation TPLChartsDataSource

- (instancetype)init{
    self = [super init];
    if (self) {
        self.sessionManager = [[AFHTTPSessionManager alloc]init];
        self.placesData = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Places

//Get chart info to use with places API
- (void)retrieveChartsForLocation:(CLLocationCoordinate2D)coordinate
                completionHandler:(void (^)(id chartData))completionHandler
                   failureHandler:(void (^)(id error))failureHandler{
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:lat forKey:@"lat"];
    [dict setObject:lng forKey:@"lng"];
    
    [self.sessionManager GET:API_CHARTS parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *userInfo = [error userInfo];
        NSData* errorData = userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (errorData) {
            NSDictionary *err = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", err);
        }
        failureHandler(error);
    }];
    
}

//- (void)getRestaurantsForChart:(Chart *)chart
//                  atCoordinate:(CLLocationCoordinate2D)coordinate
//             completionHandler:(void (^)(id))completionHandler
//                failureHandler:(void (^)(id))failureHandler{
//    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
//    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
//    
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:lat forKey:@"lat"];
//    [dict setObject:lng forKey:@"lng"];
//    [dict setObject:[chart.chart_id stringValue] forKey:@"chart_id"];
//    
//    if (chart.next_page) {
//        [dict setObject:[chart.next_page stringValue] forKey:@"page"];
//    }
//    
//    [self.sessionManager GET:API_PLACES parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSHTTPURLResponse *response = (NSHTTPURLResponse *)[task response];
//        if(response){
//            NSDictionary *httpHeaders = response.allHeaderFields;
//            DLog(@"Chart: %@ | X-APILOG-ID: %@", chart.name, httpHeaders[@"X-APILOG-ID"]);
//        }
//        Places *result = [MTLJSONAdapter modelOfClass:[Places class] fromJSONDictionary:responseObject error:nil];
//        
//        //If we're querying for an exisiting chart, append to the already retrieved places
//        if(chart.places){
//            if (result.places.count > 0) {
//                chart.next_page = result.next_page;
//                chart.places = [chart.places arrayByAddingObjectsFromArray:result.places];
//            }else{
//                chart.next_page = nil;
//            }
//        }else{
//            [chart mergeValuesForKeysFromModel:result];
//        }
//        
//        completionHandler(chart);        
//    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        failureHandler(error);
//    }];
//}

- (void)getRestaurantsForChart:(Chart *)chart
                  atCoordinate:(CLLocationCoordinate2D)coordinate
             completionHandler:(void (^)(id))completionHandler
                failureHandler:(void (^)(id))failureHandler{
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:lat forKey:@"lat"];
    [dict setObject:lng forKey:@"lng"];
    [dict setObject:[chart.chart_id stringValue] forKey:@"chart_id"];

    if (chart.next_page) {
        [dict setObject:[chart.next_page stringValue] forKey:@"page"];
    }

    [self.sessionManager GET:API_PLACES parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)[task response];
        if(response){
            NSDictionary *httpHeaders = response.allHeaderFields;
            DLog(@"Chart: %@ | X-APILOG-ID: %@", chart.name, httpHeaders[@"X-APILOG-ID"]);
        }
        
        Places *places = [MTLJSONAdapter modelOfClass:[Places class] fromJSONDictionary:responseObject error:nil];
        completionHandler(places);
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];
}

- (void)getRecentMediaAtCoordinate:(CLLocationCoordinate2D)coordinate
                              page:(NSString *)pageNum
                     withTimeframe:(NSString *)timeframe
                         limitPerPage:(NSString *)limitPerPage
                   limitMostRecent:(NSString *)limitMostRecent
                 completionHandler:(void (^)(id))completionHandler
                    failureHandler:(void (^)(id))failureHandler{
    
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:lat forKey:@"lat"];
    [dict setObject:lng forKey:@"lng"];
    
    if (pageNum) {
        [dict setObject:pageNum forKey:@"page"];
    }
    
    if (limitPerPage) {
        [dict setObject:limitPerPage forKey:@"per_page"];
    }
    
    if (limitMostRecent){
        [dict setObject:limitMostRecent forKey:@"limit_from_blogger"];
    }
    
    if (timeframe) {
        [dict setObject:timeframe forKey:@"time_group_interval"];
    }
    
    [self.sessionManager GET:API_PLACE_BLOGS parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Places *places = [MTLJSONAdapter modelOfClass:[Places class] fromJSONDictionary:responseObject error:nil];
        completionHandler(places);
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];
    
}


@end
