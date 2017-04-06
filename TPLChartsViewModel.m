//
//  ChartsViewModel.m
//  FoodWise
//
//  Created by Brian Wong on 1/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartsViewModel.h"
#import "Chart.h"
#import "FoodWiseDefines.h"
#import "Places.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TPLChartsViewModel ()

@property (nonatomic, strong) TPLChartsDataSource *restaurantDataSrc;
//@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation TPLChartsViewModel

- (instancetype)initWithStore:(TPLChartsDataSource *)store{
    self = [super init];
    if(self){
        self.restaurantDataSrc = store;
        //self.sessionManager = [[AFHTTPSessionManager alloc]init];
        self.restaurantData = [NSMutableArray array];
        self.completeChartData = [NSMutableArray array];
    }
    return self;
}

- (void)getChartsAtLocation:(CLLocationCoordinate2D)coordinate{
    NSMutableArray *arrCopy = [self mutableArrayValueForKey:@"completeChartData"];
    //RACObserve the chart info and populate section titles first to make UI seem faster.
    [self.restaurantDataSrc retrieveChartsForLocation:coordinate completionHandler:^(id chartData){
        [arrCopy removeAllObjects];
        NSArray *charts = chartData[@"charts"];
        for (NSDictionary *chartDetails in charts) {
            Chart *incompleteChart = [MTLJSONAdapter modelOfClass:[Chart class] fromJSONDictionary:chartDetails error:nil];
            [arrCopy addObject:incompleteChart];
        }
        
        self.finishedLoading = NO;
        self.chartsLoadFailed = NO;
    
        #warning Need a better way of using RAC here (updating the same object in this array with a dictionary...)
        [self.restaurantDataSrc getRestaurantsForCharts:arrCopy atCoordinate:coordinate completionHandler:^(id completeChart) {
            NSNumber *index = completeChart[@"index"];
            Chart *chart = completeChart[@"chart"];
            [arrCopy replaceObjectAtIndex:[index integerValue] withObject:chart];
            
#warning This doesn't work if we don't load in serial order. Must find a better way to do this
            if ([index integerValue] == arrCopy.count - 1) {
                self.finishedLoading = YES;
            }
        } failureHandler:^(id error) {
            //NSLog(@"Failed to get restaurants for charts: %@", error);
            self.chartsLoadFailed = YES;
            self.finishedLoading = YES;
        }];
    } failureHandler:^(id error) {
        //Throw bad service alert
        self.chartsLoadFailed = YES;
        self.finishedLoading = YES;
    }];
}

@end
