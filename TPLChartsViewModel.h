//
//  TPLChartsViewModel.h
//  FoodWise
//
//  Created by Brian Wong on 1/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//
#import "TPLRestaurant.h"
#import "TPLChartsDataSource.h"

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>

@import CoreLocation;

@interface TPLChartsViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *restaurantData;

//Dependency injection in case we want to test view model constructor exclusively
- (instancetype)initWithStore:(TPLChartsDataSource *)store;

- (void)getRestaurantsWithCoordinate:(CLLocationCoordinate2D)coordinate;

////To display specific category chart
//- (void)getChartWithCategory:(NSString *)categoryId
//              withCoordinate:(CLLocationCoordinate2D)coordinate
//           completionHandler:(void (^)(id JSON))completionHandler
//              failureHandler:(void (^)(id error))failureHandler;

- (id)getRestaurantAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)getNumChartsForSection:(NSIndexPath *)indexPath;

@end
