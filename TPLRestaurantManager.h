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
- (void)getReviewsForRestaurant:(NSString *)restaurantId
              completionHandler:(void (^)(id reviews))completionHandler
                 failureHandler:(void (^)(id error))failureHandler;

- (void)getRestaurantDetailsFor:(NSString *)restaurantId
                     atLocation:(CLLocationCoordinate2D)coordinate
              completionHandler:(void (^)(id details))completionHandler
                 failureHandler:(void (^)(id error))failureHandler;


- (void)getMoreMediaForRestaurant:(NSString *)restaurantId
                              page:(NSString *)pageNumber
                 completionHandler:(void (^)(id images))completionHandler
                    failureHandler:(void (^)(id error))failureHandler;


//Autocomplete
- (void)searchRestaurantsWithQuery:(NSString *)queryStr
                        atLocation:(CLLocationCoordinate2D)coordinate
                 completionHandler:(void (^)(id suggestions))completionHandler
                    failureHandler:(void (^)(id error))failureHandler;
//POST Methods
- (void)submitReviewForRestaurant:(NSString *)restaurantId
                    overallRating:(NSString *)rating
                      healthScore:(NSString *)health
                            price:(NSString *)price
                            photo:(NSData *)photoData
                completionHandler:(void (^)(id success))completionHandler
                   failureHandler:(void (^)(id error))failureHandler;


@end
