//
//  RestaurantSearchViewController.h
//  Foodhead
//
//  Created by Brian Wong on 3/9/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantReview.h"

@import CoreLocation;

@interface RestaurantSearchViewController : UIViewController

@property (nonatomic, strong) RestaurantReview *currentReview;

@end
