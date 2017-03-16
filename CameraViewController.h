//
//  CameraViewController.h
//  FoodWise
//
//  Created by Brian Wong on 2/21/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RestaurantReview.h"
#import "TPLRestaurant.h"

@import CoreLocation;

@interface CameraViewController : UIViewController

@property (nonatomic, strong) RestaurantReview *currentReview;

@end
