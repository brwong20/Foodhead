//
//  ChartsViewModel.m
//  FoodWise
//
//  Created by Brian Wong on 1/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartsViewModel.h"
#import "Chart.h"

@interface TPLChartsViewModel ()

@property (nonatomic, strong) TPLChartsDataSource *restaurantDataSrc;

@end

@implementation TPLChartsViewModel

- (instancetype)initWithStore:(TPLChartsDataSource *)store{
    self = [super init];
    if(self){
        self.restaurantDataSrc = store;
        self.restaurantData = [NSMutableArray array];
        self.completeChartData = [NSMutableArray array];
    }
    return self;
}


//TODO: MUST FIND WAY TO PRESERVE CHART ID AND ORDER_INDEX SO WE CAN RE-QUERY - Make a Chart model object!!!
- (void)getChartsAtLocation:(CLLocationCoordinate2D)coordinate{
    //RACObserve the chart info and populate section titles first to make UI seem faster.
    [self.restaurantDataSrc retrieveCharts:^(id chartsInfo) {
        NSArray *charts = chartsInfo[@"charts"];
        NSMutableArray *arrCopy = [self mutableArrayValueForKey:@"completeChartData"];
        for (NSDictionary *chartDetails in charts) {
            Chart *incompleteChart = [MTLJSONAdapter modelOfClass:[Chart class] fromJSONDictionary:chartDetails error:nil];
            [arrCopy addObject:incompleteChart];
        }

        [self.restaurantDataSrc getRestaurantsForCharts:arrCopy atCoordinate:coordinate completionHandler:^(id completeChart) {
            NSNumber *index = completeChart[@"index"];
            Chart *chart = completeChart[@"chart"];
#warning Need a better way of using RAC here (updating the same object in this array with a dictionary...)
            [arrCopy replaceObjectAtIndex:[index integerValue] withObject:chart];
        } failureHandler:^(id error) {
            NSLog(@"Couldn't get restaurants for charts");
        }];
    } failureHandler:^(id error) {
        NSLog(@"Couldn't get chart info");
    }];
}

#pragma mark - Helper methods

- (NSArray *)parseJSON:(NSDictionary*)venueDict{
    NSMutableArray *restaurantArr = [NSMutableArray array];
    NSDictionary *response = venueDict[@"response"];
    NSArray *groups = response[@"groups"];
    //Have to check for other groups here - what if it's not recommended?
    NSDictionary *recommended = [groups firstObject];
    NSArray *venueArray = recommended[@"items"];
    
    for (NSDictionary *venueDict in venueArray) {
        NSError *error;
        TPLRestaurant *restaurant = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:venueDict error:&error];
        if (error) {
            NSLog(@"Couldn't deserealize JSON: %@", error);
            //return nil;
        }
        [restaurantArr addObject:restaurant];
    }
    
    NSArray *rest = [NSArray arrayWithArray:restaurantArr];
    
    return rest;
}

@end
