
//
//  TPLRestaurantPageViewModel.m
//  FoodWise
//
//  Created by Brian Wong on 2/1/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLRestaurantPageViewModel.h"

#import "TPLRestaurantManager.h"
#import "TPLDetailedRestaurant.h"
#import "UserReview.h"
#import "User.h"

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

//Purpose: Converts incomplete restaurant to full restaurant (all details retrieved)
- (void)retrieveRestaurantDetailsFor:(TPLRestaurant *)restaurant
                          atLocation:(CLLocationCoordinate2D)coordinate
                   completionHandler:(void (^)(id data))completionHandler
                      failureHandler:(void (^)(id error))failureHandler{
    [self.restaurantManager getRestaurantDetailsFor:restaurant.foursqId atLocation:coordinate completionHandler:^(id details) {
        NSDictionary *result = details[@"result"];
        NSError *err;
        TPLDetailedRestaurant *detailedRestaurant;
        if (result) {
            detailedRestaurant = [MTLJSONAdapter modelOfClass:[TPLDetailedRestaurant class] fromJSONDictionary:result error:&err];
        }else{
            detailedRestaurant = [MTLJSONAdapter modelOfClass:[TPLDetailedRestaurant class] fromJSONDictionary:details error:&err];//Cached data returned by itself w/o 'result' key
        }
        [restaurant mergeValuesForKeysFromModel:detailedRestaurant];
        completionHandler(restaurant);
    } failureHandler:^(id error) {
        NSLog(@"Couldnt get restaurant details:%@", error);
        failureHandler(error);
    }];
}

- (void)retrieveImagesForRestaurant:(TPLRestaurant *)restaurant
                               page:(NSString *)pageNumber
                  completionHandler:(void (^)(id media))completionHandler
                     failureHandler:(void (^)(id error))failureHandler{
    [self.restaurantManager getMediaForRestaurant:restaurant page:pageNumber completionHandler:^(id mediaData) {
        completionHandler(mediaData);
    } failureHandler:^(id error) {
        failureHandler(error);
    }];
}

- (void)retrieveReviewsForRestaurant:(TPLRestaurant *)restaurant
              completionHandler:(void (^)(id))completionHandler
                 failureHandler:(void (^)(id))failureHandler{
    [self.restaurantManager getReviewsForRestaurant:restaurant.foursqId completionHandler:^(id reviews) {
        //Convert to manageable model object
        NSMutableArray *reviewArr = [NSMutableArray array];
        for (NSDictionary *reviewInfo in reviews) {
            UserReview *review = [MTLJSONAdapter modelOfClass:[UserReview class] fromJSONDictionary:reviewInfo error:nil];
            User *userOfReview = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:reviewInfo error:nil];
            [review mergeValuesForKeysFromModel:userOfReview];
            [reviewArr addObject:review];
        }
        completionHandler(reviewArr);
    } failureHandler:^(id error) {
        failureHandler(error);
    }];
}

@end
