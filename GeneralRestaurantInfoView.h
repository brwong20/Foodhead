//
//  GeneralRestaurantInfoView.h
//  FoodWise
//
//  Created by Brian Wong on 2/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageRatingView.h"
#import "TPLRestaurant.h"

@interface GeneralRestaurantInfoView : UIView


- (void)setInfoForRestaurant:(TPLRestaurant *)restaurant;

@end
