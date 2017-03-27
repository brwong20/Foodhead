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
@property (nonatomic, strong) NSMutableArray *completeChartData;

//Dependency injection in case we want to test view model constructor exclusively
- (instancetype)initWithStore:(TPLChartsDataSource *)store;
- (void)getChartsAtLocation:(CLLocationCoordinate2D)coordinate;


@end
