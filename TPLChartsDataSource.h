//
//  TPLChartsDataSource.h
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@import CoreLocation;

//To be used with ViewModel and populate charts
@interface TPLChartsDataSource : NSObject

@property (nonatomic, strong) NSMutableArray *categories;

- (void)retrieveCategoriesForLocation:(CLLocationCoordinate2D)coordinate
                               completionHandler:(void (^)(id JSON))completionHandler
                                  failureHandler:(void (^)(id error))failureHandler;


- (void)retrieveRestaurantsForCategory:(NSString *)category
                        withCoordinate:(CLLocationCoordinate2D)coordinate
                     completionHandler:(void (^)(id))completionHandler
                        failureHandler:(void (^)(id))failureHandler;
@end
