
//
//  TPLRestaurantPageViewModel.m
//  FoodWise
//
//  Created by Brian Wong on 2/1/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLRestaurantPageViewModel.h"

#import "TPLRestaurantManager.h"

@interface TPLRestaurantPageViewModel ()

@property (nonatomic, strong) TPLRestaurantManager *restaurantManager;

@end

@implementation TPLRestaurantPageViewModel

- (instancetype)init{
    self = [super init];
    if (self) {
        self.restaurantManager = [[TPLRestaurantManager alloc]init];
    }
    return self;
}


//Find a way to do this with RAC
- (void)retrieveRestaurantDetailsFor:(NSString *)restaurantId
                          atLocation:(CLLocationCoordinate2D)coordinate
                   completionHandler:(void (^)(id data))completionHandler
                      failureHandler:(void (^)(id error))failureHandler{
    [self.restaurantManager getRestaurantDetailsFor:restaurantId atLocation:coordinate completionHandler:^(id details) {
        completionHandler(details);
    } failureHandler:^(id error) {
        NSLog(@"Couldnt get restaurant details");
        completionHandler(failureHandler);
    }];
}

@end
