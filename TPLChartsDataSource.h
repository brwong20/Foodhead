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

@import CoreLocation;

//To be used with ViewModel and populate charts
@interface TPLChartsDataSource : NSObject

@property (nonatomic, strong) NSMutableArray *categories;

//Places/Charts API

//For specific chart/category
- (void)getNearbyRestaurantsAtCoordinate:(CLLocationCoordinate2D)coordinate
                         retrievedPlaces:(void (^) (NSArray *))placesData
                          failureHandler:(void (^)(id))failureHandler;

- (void)retrieveRestaurantsForCategory:(NSString *)category
                        withCoordinate:(CLLocationCoordinate2D)coordinate
                     completionHandler:(void (^)(id))completionHandler
                        failureHandler:(void (^)(id))failureHandler;

- (void)retrieveRestaurantsForCategory:(NSString *)category
                          atCoordinate:(CLLocationCoordinate2D)coordinate
                             withQuery:(NSString *)query
                     completionHandler:(void (^)(id))completionHandler
                        failureHandler:(void (^)(id))failureHandler;

- (void)retrieveCharts:(void (^)(id chartsInfo))completionHandler
            failureHandler:(void (^)(id error))failureHandler;

- (void)getRestaurantsForChart:(NSString *)chartId
                  atCoordinate:(CLLocationCoordinate2D)coordinate
             completionHandler:(void (^)(id chartData))completionHandler
                failureHandler:(void (^)(id error))failureHandler;

- (void)getRestaurantsForCharts:(NSMutableArray *)charts
                   atCoordinate:(CLLocationCoordinate2D)coordinate
              completionHandler:(void (^)(id chartData))completionHandler
                 failureHandler:(void (^)(id error))failureHandler;

@end
