//
//  TPLChartsDataSource.h
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking.h>

#import "Chart.h"

@import CoreLocation;

//To be used with ViewModel and populate charts
@interface TPLChartsDataSource : NSObject

@property (nonatomic, strong) NSMutableArray *categories;

//Places API
- (void)retrieveCharts:(void (^)(id chartsInfo))completionHandler
            failureHandler:(void (^)(id error))failureHandler;

//To get all restaurants for multiple charts
- (void)getRestaurantsForCharts:(NSMutableArray *)charts
                   atCoordinate:(CLLocationCoordinate2D)coordinate
              completionHandler:(void (^)(id chartData))completionHandler
                 failureHandler:(void (^)(id error))failureHandler;

//To get more restaurants for a specific chart
- (void)getMoreRestaurantsForChart:(Chart *)chart
                      atCoordinate:(CLLocationCoordinate2D)coordinate
                 completionHandler:(void (^)(id chartData))completionHandler
                    failureHandler:(void (^)(id error))failureHandler;

@end
