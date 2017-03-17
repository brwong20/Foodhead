//
//  GeneralRestaurantInfoView.m
//  FoodWise
//
//  Created by Brian Wong on 2/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "GeneralRestaurantInfoView.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

@interface GeneralRestaurantInfoView ()

@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *category;
@property (nonatomic, strong) UILabel *openNow;
@property (nonatomic, strong) UILabel *distanceLabel;//Needs to be calculated dynamically from current dist
@property (nonatomic, strong) ImageRatingView *ratingView;
@property (nonatomic, strong) UIImageView *distanceImg;

@end

#define METERS_TO_MILES 0.000621371

@implementation GeneralRestaurantInfoView

- (instancetype)initWithFrame:(CGRect)frame{
    //Modularize into own class
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = APPLICATION_BACKGROUND_COLOR;
        [self setupUI:frame];
    }
    return self;
}

- (void)setupUI:(CGRect)frame{
    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(10.0, frame.size.height * 0.05, frame.size.width * 0.8, frame.size.height * 0.3)];
    self.restaurantName.textAlignment = NSTextAlignmentLeft;
    self.restaurantName.font = [UIFont nun_fontWithSize:22.0];
    self.restaurantName.textColor = [UIColor blackColor];
    [self addSubview:self.restaurantName];
    
    self.category = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.restaurantName.frame), frame.size.width * 0.7, frame.size.height * 0.15)];
    self.category.textColor = [UIColor darkGrayColor];
    self.category.backgroundColor = [UIColor clearColor];
    [self.category setFont:[UIFont nun_fontWithSize:16.0]];
    [self addSubview:self.category];
    
    self.openNow = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), frame.size.height - frame.size.height * 0.12, frame.size.width * 0.5, frame.size.height * 0.1)];
    self.openNow.backgroundColor = [UIColor clearColor];
    self.openNow.textColor = [UIColor lightGrayColor];
    self.openNow.font = [UIFont nun_fontWithSize:14.0];
    [self addSubview:self.openNow];

    self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.openNow.frame) + frame.size.width * 0.1, CGRectGetMinY(self.openNow.frame), frame.size.width * 0.2, frame.size.height * 0.1)];
    self.distanceLabel.backgroundColor = [UIColor clearColor];
    self.distanceLabel.font = [UIFont nun_fontWithSize:14.0];
    self.distanceLabel.textColor = [UIColor grayColor];
    [self addSubview:self.distanceLabel];
    
    self.distanceImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 12.0, 12.0)];
    self.distanceImg.center = CGPointMake(CGRectGetMinX(self.distanceLabel.frame) - 12.0, self.distanceLabel.center.y);
    self.distanceImg.backgroundColor = [UIColor clearColor];
    [self.distanceImg setImage:[UIImage imageNamed:@"distance_icon"]];
    [self addSubview:self.distanceImg];
    
    [LayoutBounds drawBoundsForAllLayers:self];
}

- (void)setInfoForRestaurant:(TPLRestaurant *)restaurant{
    self.restaurantName.text = restaurant.name;
    [self.restaurantName sizeToFit];
    
    NSString *categoriesStr = @"";
    for (NSString *category in restaurant.categories) {
        categoriesStr = [categoriesStr stringByAppendingString:[NSString stringWithFormat:@"%@ ", category]];
    }
    self.category.text = categoriesStr;
    
    //Meters to miles
    double miles = [restaurant.distance doubleValue] * METERS_TO_MILES;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", miles];

    NSArray *hoursTodayArr = restaurant.hours;
    NSString *hoursToday = @"";
    
    for (NSString *hours in hoursTodayArr) {
        hoursToday = [hoursToday stringByAppendingString:hours];
    }
    
    if (restaurant.openNow) {
        self.openNow.text = [NSString stringWithFormat:@"%@/%@", @"Open Now", hoursToday];
    }else{
        self.openNow.text = [NSString stringWithFormat:@"%@/%@", @"Closed", hoursToday];
    }
    
}


@end
