//
//  TPLRestaurantManager.h
//  FoodWise
//
//  Created by Brian Wong on 3/6/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>

@import CoreLocation;

@interface TPLRestaurantManager : NSObject

//GET Methods
- (void)getReviewsForRestaurant:(NSString *)restaurantId;

- (void)getRestaurantDetailsFor:(NSString *)restaurantId
                     atLocation:(CLLocationCoordinate2D)coordinate
              completionHandler:(void (^)(id))completionHandler
                 failureHandler:(void (^)(id))failureHandler;


//POST Methods
- (void)submitReviewForRestaurant:(NSString *)restaurantId
                    overallRating:(NSString *)rating
                      healthScore:(NSString *)health
                            price:(NSString *)price
                            photo:(NSData *)photoData;


@end
