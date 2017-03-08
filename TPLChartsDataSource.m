//
//  TPLRestaurantStore.m
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartsDataSource.h"
#import "FoodWiseDefines.h"

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

- (void)retrieveRestaurantsForCategory:(NSString *)category
                          withCoordinate:(CLLocationCoordinate2D)coordinate
                       completionHandler:(void (^)(id))completionHandler
                          failureHandler:(void (^)(id))failureHandler {
    
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    
    NSString *completeURL = [NSString string];
    if([category isEqualToString:@"Thai"]){
        completeURL = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/explore?client_id=%@&client_secret=%@&v=%@&ll=37.764908,-122.485663&section=food&venuePhotos=1&limit=20", FOURSQ_CLIENT_ID, FOURSQ_SECRET, @"20170125"];
    }else{
        completeURL = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/explore?client_id=%@&client_secret=%@&v=%@&ll=%@,%@&query=%@&venuePhotos=1&limit=20", FOURSQ_CLIENT_ID, FOURSQ_SECRET, @"20170125", lat, lng, category];
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:completeURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

        //Pass to completion handler once all calls have finished
        if(json){
            completionHandler(json);
        }
        
        if (error) {
            failureHandler(error);
        }
    }];
    [task resume];
}

- (void)getNearbyRestaurantsAtCoordinate:(CLLocationCoordinate2D)coordinate
                         retrievedPlaces:(void (^) (NSArray *))placesData
                          failureHandler:(void (^)(id))failureHandler {
    //    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    //    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    
    self.retrievedPlaces = placesData;
    
    NSString *lat = [[NSNumber numberWithDouble:37.713521]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:-122.470192]stringValue];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:lat forKey:@"lat"];
    [dict setObject:lng forKey:@"lng"];
    
    [self.sessionManager GET:YUM_PLACES_GENERAL parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDict = responseObject;
        NSString *workerId = responseDict[@"worker_id"];
        
        //Need to wait for worker to query 4SQ
        if (workerId.length > 0) {
            //[self startObservingWorker];
            //[self runWorkerRecursively:workerId withParams:dict];
        }else{
            self.retrievedPlaces(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
        NSLog(@"Error with general restaurant query: %@", error.localizedDescription);
    }];
}

//Get chart info to use with places API
- (void)retrieveCharts:(void (^)(id chartData))completionHandler
        failureHandler:(void (^)(id error))failureHandler{

    [self.sessionManager GET:YUM_CHARTS parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];
    
}

//TODO:: Reload table view for each time a worker completes to make charts look faster
- (void)getRestaurantsForChart:(NSString *)chartId
                   atCoordinate:(CLLocationCoordinate2D)coordinate
              completionHandler:(void (^)(id chartData))completionHandler
                 failureHandler:(void (^)(id error))failureHandler
{
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:lat forKey:@"lat"];
    [dict setObject:lng forKey:@"lng"];
    [dict setObject:chartId forKey:@"chart_id"];
    
    self.chartsCompletion = completionHandler;
    
    NSLog(@"GETTING CHARTS");
    
    [self.sessionManager GET:YUM_PLACES_GENERAL parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDict = responseObject;
        NSString *workerId = responseDict[@"worker_id"];
        
        NSLog(@"Getting chart for : %@", dict[@"chart_id"]);
        
        //Need to wait for worker to query 4SQ
        if (workerId.length > 0) {
            //[self startObservingWorker];
            [self runWorkerRecursively:workerId withParams:dict completionHandler:^(id chartData) {
                //Might have something to do with using the same completion handler... ONLY return recursive result to this completion handler and handle all worker refreshing in here... Can also try max one operation on NSOperationQueue???
                self.chartsCompletion(chartData);
            } failureHandler:^(id error) {
                
            }];
        }else{
            self.chartsCompletion(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
        NSLog(@"Error with charts query: %@", error.localizedDescription);
    }];
}

- (void)getRestaurantsForCharts:(NSMutableArray *)charts
                  atCoordinate:(CLLocationCoordinate2D)coordinate
             completionHandler:(void (^)(id chartData))completionHandler
                failureHandler:(void (^)(id error))failureHandler
{
    //__block NSMutableArray *chartDataArr = [NSMutableArray array];
    __block dispatch_group_t group = dispatch_group_create();
    for(NSMutableDictionary *chartInfo in charts){
        NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
        NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:lat forKey:@"lat"];
        [dict setObject:lng forKey:@"lng"];
        [dict setObject:[[chartInfo allValues]firstObject] forKey:@"chart_id"];
        
        dispatch_group_enter(group);
        [self.sessionManager GET:YUM_PLACES_GENERAL parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            /*
            NSDictionary *responseDict = responseObject;
            NSString *workerId = responseDict[@"worker_id"];
            
            NSLog(@"Getting restaurants for chart_id:%@ WITH worker_id: %@", task.originalRequest.URL.absoluteString, workerId);
            
            //Need to wait for worker to query 4SQ
            
#warning Must get ordering CORRECT here (use a key and value) then just replace the view model's dictionaries by matching keys
            if (workerId.length > 0) {
                [self runWorkerRecursively:workerId withParams:dict completionHandler:^(id chartData) {
                    [chartDataArr addObject:chartData];
                    NSLog(@"Retrieved from worker");
                    dispatch_group_leave(group);
                } failureHandler:^(id error) {
                    
                }];
            }else{
            
            }
            */
            NSMutableDictionary *completedChart = [NSMutableDictionary dictionary];
            NSString *chartName = [[chartInfo allKeys]firstObject];
            [completedChart setObject:responseObject forKey:chartName];
            //Replace incomplete chart with completed (data retrieved)
            [charts replaceObjectAtIndex:[charts indexOfObject:chartInfo] withObject:completedChart];
            dispatch_group_leave(group);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failureHandler(error);
            NSLog(@"Error with getting worker / cached chart: %@", error.localizedDescription);
        }];
    }
    
    //Try to do this one by one
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //Need to make sure in same order
        completionHandler(charts);
        NSLog(@"Finished entire retrieval");
    });
}



#pragma mark - Workers

- (void)runWorkerRecursively:(NSString *)workerId withParams:(NSDictionary *)params
           completionHandler:(void (^)(id chartData))completionHandler
              failureHandler:(void (^)(id error))failureHandler
{
    NSString *workerURL = [NSString stringWithFormat:YUM_WORKER_GENERAL, workerId];
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
