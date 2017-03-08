//
//  TPLRestaurantPageViewController.h
//  FoodWise
//
//  Created by Brian Wong on 1/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLRestaurant.h"

@import CoreLocation;

@interface TPLRestaurantPageViewController : UIViewController

@property (nonatomic, strong) TPLRestaurant *selectedRestaurant;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@end
