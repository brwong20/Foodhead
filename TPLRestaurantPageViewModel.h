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

//Retrieves different info/media on restaurant
- (void)retrieveRestaurantDetailsFor:(TPLRestaurant *)restaurant
                          atLocation:(CLLocationCoordinate2D)coordinate
                   completionHandler:(void (^)(id completionHandler))completionHandler
                      failureHandler:(void (^)(id failureHandler))failureHandler;

- (void)retrieveReviewsForRestaurant:(TPLRestaurant *)restaurant
              completionHandler:(void (^)(id completionHandler))completionHandler
                 failureHandler:(void (^)(id failureHandler))failureHandler;

- (void)retrieveImagesForRestaurant:(TPLRestaurant *)restaurant
                               page:(NSString *)pageNumber
                  completionHandler:(void (^)(id completionHandler))completionHandler
                     failureHandler:(void (^)(id failureHandler))failureHandler;


//User submission of ratings
- (void)submitReviewForRestaurant:(NSString *)restaurantId
                completionHandler:(void (^)(id completionHandler))completionHandler
                   failureHandler:(void (^)(id failureHandler))failureHandler;

@end
