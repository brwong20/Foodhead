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

- (RACSignal *)getChartsAtLocation:(CLLocationCoordinate2D)coordinate{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
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
            
            //RACSignal *results = [chartsSignals flatten:incompleteCharts.count];
            [results subscribeNext:^(id  _Nullable x) {
                [subscriber sendNext:x];
            }error:^(NSError * _Nullable error) {
                [subscriber sendError:error];
            } completed:^{
                [subscriber sendCompleted];
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
        return nil;
    }];
}

- (RACSignal *)getRecentBlogPostsAtLocation:(CLLocationCoordinate2D)coordinate
                                    forPage:(NSString *)pageNum
                                  withLimit:(NSString *)resultLimit{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self.restaurantDataSrc getRecentMediaAtCoordinate:coordinate page:pageNum withTimeframe:@"36" limitPerPage:resultLimit  limitMostRecent:@"6" completionHandler:^(Places *blogPosts) {
            //Convert places into TPLRestaurants            
            for (int i = 0; i < blogPosts.places.count; ++i) {
                NSDictionary *restInfo = blogPosts.places[i];
                TPLRestaurant *rest = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:restInfo error:nil];
                [blogPosts.places replaceObjectAtIndex:i withObject:rest];
            }
            [subscriber sendNext:blogPosts];
            [subscriber sendCompleted];
        } failureHandler:^(id error) {
            [subscriber sendError:error];
        }];
        return nil;
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


//Uncomment to have results returned in sectioned charts
//- (RACSignal *)restaurantsForChartSignal:(Chart *)chart atLocation:(CLLocationCoordinate2D)coordinate{
//    NSMutableArray *arrCopy = [self mutableArrayValueForKey:@"completeChartData"];
//    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        [self.restaurantDataSrc getRestaurantsForChart:chart atCoordinate:coordinate completionHandler:^(Chart *completeChart) {
//            [arrCopy replaceObjectAtIndex:[arrCopy indexOfObject:chart] withObject:chart];
//            [subscriber sendNext:completeChart];
//            [subscriber sendCompleted];
//        } failureHandler:^(NSError *error) {
//            [subscriber sendError:error];
//        }];
//        return nil;
//    }];
//}

//Just returns all results in whatever order we load the charts
- (RACSignal *)restaurantsForChartSignal:(Chart *)chart atLocation:(CLLocationCoordinate2D)coordinate{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self.restaurantDataSrc getRestaurantsForChart:chart atCoordinate:coordinate completionHandler:^(Places *restaurants) {
            //Convert places into TPLRestaurants
            for (int i = 0; i < restaurants.places.count; ++i) {
                NSDictionary *restInfo = restaurants.places[i];
                TPLRestaurant *rest = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:restInfo error:nil];
                [restaurants.places replaceObjectAtIndex:i withObject:rest];
            }
            [subscriber sendNext:restaurants];
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
