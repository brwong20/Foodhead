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

#import <ReactiveObjC/ReactiveObjC.h>

@interface TPLChartsDataSource ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableArray *placesData;
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic) void (^retrievedPlaces)(NSArray* placesData);//Created a block reference here bc this can either be called right away when response is returned or when a worker finishes (after some time interval)

//@property (nonatomic) void (^retrievedCharts)(id chartsData);


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
            //NSDictionary *err = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
        }
        failureHandler(error);
    }];
    
}

- (void)getRestaurantsForCharts:(NSMutableArray *)charts
                  atCoordinate:(CLLocationCoordinate2D)coordinate
             completionHandler:(void (^)(id completeChart))completionHandler
                failureHandler:(void (^)(id error))failureHandler
{
    //Run chart requests serially so they load in the order they're presented (makes loading look faster and more intutive) - TODO: Request and load in batches of 2/3.
    dispatch_queue_t serialQ = dispatch_queue_create("com.Taplet.Foodhead.Charts", DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);//Important: Must default init with a counter of 1 to allow first request to process
    
    for (Chart *chart in charts) {
        dispatch_async(serialQ, ^{
            NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
            NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];

            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:lat forKey:@"lat"];
            [dict setObject:lng forKey:@"lng"];
            [dict setObject:[chart.chart_id stringValue] forKey:@"chart_id"];

            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//Waits for previous request to finish before starting a new one in queue (Block the thread and wait for queue to finish task)
            [self.sessionManager GET:API_PLACES parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)[task response];
                if(response){
                    NSDictionary *httpHeaders = response.allHeaderFields;
                    //NSLog(@"Chart: %@ | X-APILOG-ID: %@", chart.name, httpHeaders[@"X-APILOG-ID"]);
                    DLog(@"Chart: %@ | X-APILOG-ID: %@", chart.name, httpHeaders[@"X-APILOG-ID"]);
                }
                Places *places = [MTLJSONAdapter modelOfClass:[Places class] fromJSONDictionary:responseObject error:nil];
                [chart mergeValuesForKeysFromModel:places];
                //Send index along to replace in our original array
                NSDictionary *completeChart = @{@"index" : @([charts indexOfObject:chart]), @"chart" : chart};
                dispatch_semaphore_signal(semaphore);//Signal that task has finished and unblock the thread
                completionHandler(completeChart);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSDictionary *userInfo = [error userInfo];
                NSData* errorData = userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                if (errorData) {
                    NSDictionary *err = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
                    NSString *errorStr = err[@"error"];
                    NSLog(@"%@", errorStr);
                }
                dispatch_semaphore_signal(semaphore);
                failureHandler(error);
            }];
        });
    }
}


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
    
    [self.sessionManager GET:API_PLACES parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)[task response];
        if(response){
            NSDictionary *httpHeaders = response.allHeaderFields;
            DLog(@"Chart: %@ | X-APILOG-ID: %@", chart.name, httpHeaders[@"X-APILOG-ID"]);
        }
        Places *places = [MTLJSONAdapter modelOfClass:[Places class] fromJSONDictionary:responseObject error:nil];
        [chart mergeValuesForKeysFromModel:places];
        completionHandler(chart);
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];
}

- (void)getMoreRestaurantsForChart:(Chart *)chart
                      atCoordinate:(CLLocationCoordinate2D)coordinate
                 completionHandler:(void (^)(id))completionHandler
                    failureHandler:(void (^)(id))failureHandler{
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    NSNumber *nextPg = chart.next_page;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:lat forKey:@"lat"];
    [dict setObject:lng forKey:@"lng"];
    [dict setObject:[chart.chart_id stringValue] forKey:@"chart_id"];
    [dict setObject:[nextPg stringValue] forKey:@"page"];
    
    [self.sessionManager GET:API_PLACES parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];
}

@end
