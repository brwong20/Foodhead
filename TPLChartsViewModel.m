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
#import <ReactiveObjC/ReactiveObjC.h>

@interface TPLChartsViewModel ()

@property (nonatomic, strong) TPLChartsDataSource *restaurantDataSrc;

@end

@implementation TPLChartsViewModel

- (instancetype)init{
    self = [super init];
    if(self){
        self.restaurantDataSrc = [[TPLChartsDataSource alloc]init];
        self.completeChartData = [NSMutableArray array];
    }
    return self;
}

//- (instancetype)initWithStore:(TPLChartsDataSource *)store{
//    self = [super init];
//    if(self){
//        self.restaurantDataSrc = [[TPLChartsDataSource alloc]init];
//        self.completeChartData = [NSMutableArray array];
//    }
//    return self;
//}

- (void)getChartsAtLocation:(CLLocationCoordinate2D)coordinate{
    @weakify(self);
    [[[self signalForIncompleteCharts:coordinate] flattenMap:^__kindof RACSignal * _Nullable(NSMutableArray *incompleteCharts) {
        NSMutableArray *requestSignals = [NSMutableArray array];
        
        for (Chart *chart in incompleteCharts) {
            RACSignal *chartSignal = [[self restaurantsForChartSignal:chart atLocation:coordinate] catch:^RACSignal * _Nonnull(NSError * _Nonnull error) {
                DLog(@"Error creating chart signal");
                return [RACSignal empty];
            }];
            [requestSignals addObject:chartSignal];
        }

        //Turn all requests into signals
        RACSignal *chartsSignals = [requestSignals.rac_sequence signalWithScheduler:[RACScheduler immediateScheduler]];
        RACSignal *results = [chartsSignals flatten:1];//Run one request (signal) at a time
        
        [results subscribeError:^(NSError * _Nullable error) {
            @strongify(self)
            self.chartsLoadFailed = YES;
            self.finishedLoading = YES;
        }completed:^{
            @strongify(self)
            self.finishedLoading = YES;
        }];
        return chartsSignals;
    }]subscribeError:^(id  _Nullable x) {
        @strongify(self)
        DLog(@"Error loading chart info: %@", x);
        self.chartsLoadFailed = YES;
        self.finishedLoading = YES;
    }completed:^{
        self.finishedLoading = NO;
        self.chartsLoadFailed = NO;
        DLog(@"Chart info loaded");
    }];
}

#pragma mark RACSignals

- (RACSignal *)signalForIncompleteCharts:(CLLocationCoordinate2D)coordinate{
    NSMutableArray *arrCopy = [self mutableArrayValueForKey:@"completeChartData"];
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self.restaurantDataSrc retrieveChartsForLocation:coordinate completionHandler:^(id chartData){
            [arrCopy removeAllObjects];
            NSArray *charts = chartData[@"charts"];
            for (NSDictionary *chartDetails in charts) {
                Chart *incompleteChart = [MTLJSONAdapter modelOfClass:[Chart class] fromJSONDictionary:chartDetails error:nil];
                [arrCopy addObject:incompleteChart];
            }
            
            [subscriber sendNext:arrCopy];
            [subscriber sendCompleted];
        } failureHandler:^(id error) {
            //Throw bad service alert
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)restaurantsForChartSignal:(Chart *)chart atLocation:(CLLocationCoordinate2D)coordinate{
    NSMutableArray *arrCopy = [self mutableArrayValueForKey:@"completeChartData"];
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self.restaurantDataSrc getRestaurantsForChart:chart atCoordinate:coordinate completionHandler:^(Chart *completeChart) {
            [arrCopy replaceObjectAtIndex:[arrCopy indexOfObject:chart] withObject:chart];
            [subscriber sendCompleted];
        } failureHandler:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}


//Since we are passing a reference of an already existing chart, we will observe when new objects are added to its places array instead of completeChartData.
- (RACSignal *)getMoreRestaurantsForChartSignal:(Chart *)chart atLocation:(CLLocationCoordinate2D)coordinate{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self.restaurantDataSrc getRestaurantsForChart:chart atCoordinate:coordinate completionHandler:^(Chart *chart) {
            [subscriber sendCompleted];
        } failureHandler:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}
    

@end
