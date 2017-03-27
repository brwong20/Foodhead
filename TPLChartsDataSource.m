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

typedef void(^WorkerCompletionBlock)(id chartsData);

@interface TPLChartsDataSource ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableArray *placesData;
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic) void (^retrievedPlaces)(NSArray* placesData);//Created a block reference here bc this can either be called right away when response is returned or when a worker finishes (after some time interval)

//@property (nonatomic) void (^retrievedCharts)(id chartsData);
@property (nonatomic, copy) WorkerCompletionBlock chartsCompletion;


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
- (void)retrieveCharts:(void (^)(id chartData))completionHandler
        failureHandler:(void (^)(id error))failureHandler{

    [self.sessionManager GET:API_CHARTS parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];
    
}

- (void)getRestaurantsForCharts:(NSMutableArray *)charts
                  atCoordinate:(CLLocationCoordinate2D)coordinate
             completionHandler:(void (^)(id completeChart))completionHandler
                failureHandler:(void (^)(id error))failureHandler
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 1;
    queue.qualityOfService = NSOperationQualityOfServiceUserInteractive;
    
    NSMutableArray *blockOperations = [NSMutableArray array];
    
    for(Chart *chart in charts){
        NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
        NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:lat forKey:@"lat"];
        [dict setObject:lng forKey:@"lng"];
        [dict setObject:[chart.chart_id stringValue] forKey:@"chart_id"];

        NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
            [self.sessionManager GET:API_PLACES parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                Places *places = [MTLJSONAdapter modelOfClass:[Places class] fromJSONDictionary:responseObject error:nil];
                [chart mergeValuesForKeysFromModel:places];
                
                //Send index along to replace in our original array
                NSDictionary *completeChart = @{@"index" : @([charts indexOfObject:chart]), @"chart" : chart};
                completionHandler(completeChart);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failureHandler(error);
                NSLog(@"Error with getting worker / cached chart: %@", error.localizedDescription);
            }];
        }];
        
        [blockOperations addObject:operation];
    }
    
    for (int i = 0; i < blockOperations.count; ++i) {
        if (i == 0) continue;
    
        NSOperation *curOperation = blockOperations[i];
        NSOperation *prevOperation = blockOperations[i-1];
        [curOperation addDependency:prevOperation];
    }
    
    [queue addOperations:blockOperations waitUntilFinished:NO];
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
        NSLog(@"%@", error);
        failureHandler(error);
    }];
}

#pragma mark - Workers

- (void)runWorkerRecursively:(NSString *)workerId withParams:(NSDictionary *)params
           completionHandler:(void (^)(id chartData))completionHandler
              failureHandler:(void (^)(id error))failureHandler
{
    NSString *workerURL = [NSString stringWithFormat:API_WORKER_PLACES, workerId];
    //Timer will always call this async method which will return multiple times if worker is done
    [self.sessionManager GET:workerURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *workerStatus = responseObject[@"worker_status"];
        if ([workerStatus isEqualToString:@"finished"]) {
            NSMutableArray *chartsInfo = responseObject[@"result"];
            completionHandler(chartsInfo);
            return;
        }else{
            [self runWorkerRecursively:workerId withParams:params completionHandler:completionHandler failureHandler:failureHandler];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error with worker recursion: %@", error.localizedDescription);
    }];

}

@end
