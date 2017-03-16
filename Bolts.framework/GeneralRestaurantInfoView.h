//
//  GeneralRestaurantInfoView.h
//  FoodWise
//
//  Created by Brian Wong on 2/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageRatingView.h"

@interface GeneralRestaurantInfoView : UIView

@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *category;
@property (nonatomic, strong) UILabel *openNow;
@property (nonatomic, strong) UILabel *hoursToday;
@property (nonatomic, strong) UILabel *distanceLabel;//Needs to be calculated dynamically from current dist
@property (nonatomic, strong) ImageRatingView *ratingView;

@end
