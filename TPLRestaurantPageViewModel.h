//
//  TPLRestaurantPageViewModel.h
//  FoodWise
//
//  Created by Brian Wong on 2/1/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TPLRestaurant.h"

@import CoreLocation;

//Will be used retrieve restaurant details as well as rate
@interface TPLRestaurantPageViewModel : NSObject

//Don't make a data object here for restaurant bc we shouldn't be exposing to rating flow?

//Retrieves Foursquare info
- (void)retrieveRestaurantDetailsFor:(NSString *)restaurantId
                          atLocation:(CLLocationCoordinate2D)coordinate
                   completionHandler:(void (^)(id completionHandler))completionHandler
                      failureHandler:(void (^)(id failureHandler))failureHandler;

- (void)submitReviewForRestaurant:(NSString *)restaurantId
                completionHandler:(void (^)(id completionHandler))completionHandler
                   failureHandler:(void (^)(id failureHandler))failureHandler;

- (void)getReviewsForRestaurant:(NSString *)restaurantId
              completionHandler:(void (^)(id completionHandler))completionHandler
                 failureHandler:(void (^)(id failureHandler))failureHandler;

@end
