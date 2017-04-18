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

@property (nonatomic, strong) NSMutableArray *completeChartData;

@property (nonatomic, assign) BOOL finishedLoading;//Tells our refresh control to stop refreshing
@property (nonatomic, assign) BOOL chartsLoadFailed;//True when we couldn't retrieve our charts due to bad connection -> Will show connection error on charts page. TODO:Should have a clearer way to do this without the bool (either find better way or don't use RAC and use completion/failure handler instead)

//Dependency injection in case we want to test view model constructor exclusively
- (instancetype)initWithStore:(TPLChartsDataSource *)store;

- (void)getChartsAtLocation:(CLLocationCoordinate2D)coordinate;

@end
