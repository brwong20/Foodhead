//
//  ChartsViewModel.m
//  FoodWise
//
//  Created by Brian Wong on 1/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartsViewModel.h"

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

- (void)getChartsAtLocation:(CLLocationCoordinate2D)coordinate{
    //RACObserve the chart info and populate section titles first to make UI seem faster.
    [self.restaurantDataSrc retrieveCharts:^(id chartsInfo) {
        NSArray *charts = chartsInfo[@"charts"];
        for (int i = 0; i < charts.count; ++i) {
            [self.completeChartData addObject:[NSNull null]];
        }
        
//Find a way to load this right away
        for (NSDictionary *chartDetails in charts) {
            NSString *chartTitle = chartDetails[@"title"];
            NSNumber *chart_id = chartDetails[@"id"];
            NSNumber *index = chartDetails[@"order_index"];
            NSMutableDictionary *incompleteChart = [@{chartTitle : chart_id}mutableCopy];
            
            NSMutableArray *arrCopy = [self mutableArrayValueForKey:@"completeChartData"];
            [arrCopy replaceObjectAtIndex:[index integerValue] withObject:incompleteChart];
        }
        
#warning Consider making an actual Chart model object for easier checking (is chart complete? set properties, etc.) - Fill this Chart with restaurants and have convenience methods to retrieve a rest
        [self.restaurantDataSrc getRestaurantsForCharts:self.completeChartData atCoordinate:coordinate completionHandler:^(id chartData) {
            //Set and notify RACObserve we've retrieved all completed chart data.
            NSMutableArray *arrCopy = [self mutableArrayValueForKey:@"completeChartData"];
            
            //Also need to check for ordering here, BUT BEST WAY IS TO JUST OBSERVE ENTIRE PROPERTY CHANGE!!!
            dispatch_async(dispatch_get_main_queue(), ^{
                for (int i = 0 ; i < self.completeChartData.count; ++i) {
                    [arrCopy replaceObjectAtIndex:i withObject:chartData[i]];
                }
            });
        } failureHandler:^(id error) {
            NSLog(@"Couldn't get restaurants for charts");
        }];
    } failureHandler:^(id error) {
        NSLog(@"Couldn't get chart info");
    }];
}

- (void)getRestaurantsAtCoordinate:(CLLocationCoordinate2D)coordinate{
    [self.restaurantDataSrc getNearbyRestaurantsAtCoordinate:coordinate retrievedPlaces:^(NSArray *places) {
        //NSLog(@"%@", places);
    } failureHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

- (void)getRestaurantsWithCoordinate:(CLLocationCoordinate2D)coordinate{
    NSArray *categories = @[@"American", @"Sushi", @"Salad", @"Healthy", @"Mexican", @"Thai"];
    
    NSMutableArray *rest = [[NSMutableArray alloc]initWithCapacity:categories.count];
    for (int i = 0; i < categories.count; ++i) {
        rest[i] = [NSNull null];//Must initialize empty objects in order to replace them
    }
    
    __block int count = 0;//Makes sure we've retrieved each restaurant so we can process all at once.
    for (NSString *category in categories) {
        NSMutableDictionary *categoryDict = [NSMutableDictionary dictionary];
        [self.restaurantDataSrc retrieveRestaurantsForCategory:category withCoordinate:coordinate completionHandler:^(id JSON) {
            NSUInteger index = [categories indexOfObject:category];
            if(JSON){
                [categoryDict setValue:[self parseJSON:JSON] forKey:category];
                [rest replaceObjectAtIndex:index withObject:categoryDict];//We do this to make sure our restaurant responses are in the same order as the categories sent.
                ++count;
                if(count == categories.count){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //Must use this proxy itself rather than the actual array!
                        NSMutableArray *arr = [self mutableArrayValueForKey:@"restaurantData"];
                        [arr addObjectsFromArray:rest];
                    });
                }
            }else{
                [categoryDict setValue:@{} forKey:category];//In case we get NOTHING for a category
            }
        } failureHandler:^(id error) {
            NSLog(@"Failed to retrieve restaurant for category!!!");
        }];
    }
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
