//
//  TPLRestaurantPageViewController.h
//  FoodWise
//
//  Created by Brian Wong on 1/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLRestaurant.h"
#import "DiscoverRealm.h"

@import CoreLocation;

@protocol RestaurantPageDelegate <NSObject>

//- (void)restaurantPageDidFavorite:(DiscoverRealm *)fav atIndexPath:(NSIndexPath *)indexPath;
//- (void)restaurantPageDidUnfavorite:(NSString *)primaryKey;

@end

@interface TPLRestaurantPageViewController : UIViewController

@property (nonatomic, strong) TPLRestaurant *selectedRestaurant;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<RestaurantPageDelegate>delegate;

@end
