//
//  TPLAssetPreviewController.h
//  FoodWise
//
//  Created by Brian Wong on 2/5/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RestaurantReview.h"
#import "TPLRestaurant.h"

@import CoreLocation;

@interface TPLAssetPreviewController : UIViewController

@property (nonatomic, strong) RestaurantReview *currentReview;

@end
