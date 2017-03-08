//
//  GeneralRestaurantInfoView.m
//  FoodWise
//
//  Created by Brian Wong on 2/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "GeneralRestaurantInfoView.h"

@implementation GeneralRestaurantInfoView

- (instancetype)initWithFrame:(CGRect)frame{
    //Modularize into own class
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self setupUI:frame];
    }
    return self;
}

- (void)setupUI:(CGRect)frame{
    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(10.0, frame.size.height * 0.2, frame.size.width * 0.6, frame.size.height * 0.2)];
    self.restaurantName.textAlignment = NSTextAlignmentLeft;
    self.restaurantName.font = [UIFont boldSystemFontOfSize:24.0];
    self.restaurantName.textColor = [UIColor grayColor];
    self.restaurantName.text = @"JEAN-GEORGES";
    [self addSubview:self.restaurantName];
    
    self.category = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.restaurantName.frame), frame.size.width * 0.4, frame.size.height * 0.1)];
    self.category.text = @"French Cuisine";
    self.category.textColor = [UIColor darkGrayColor];
    self.category.backgroundColor = [UIColor clearColor];
    [self.category setFont:[UIFont boldSystemFontOfSize:14.0]];
    [self addSubview:self.category];
    
    self.openNow = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.category.frame) + frame.size.height * 0.2, frame.size.width * 0.2, frame.size.height * 0.1)];
    self.openNow.text = @"Open now";
    self.openNow.backgroundColor = [UIColor clearColor];
    self.openNow.textColor = [UIColor lightGrayColor];
    self.openNow.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:self.openNow];
    
    self.hoursToday = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.openNow.frame), CGRectGetMinY(self.openNow.frame), frame.size.width * 0.25, frame.size.height * 0.1)];
    self.hoursToday.text = @"/ 9:00 - 22:00";
    self.hoursToday.backgroundColor = [UIColor clearColor];
    self.hoursToday.textColor = [UIColor grayColor];
    self.hoursToday.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:self.hoursToday];
    
    self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.hoursToday.frame) + frame.size.width * 0.1, CGRectGetMinY(self.openNow.frame), frame.size.width * 0.2, frame.size.height * 0.1)];
    self.distanceLabel.text = @"1 mi";
    self.distanceLabel.backgroundColor = [UIColor clearColor];
    self.distanceLabel.font = [UIFont systemFontOfSize:12.0];
    self.distanceLabel.textColor = [UIColor grayColor];
    [self addSubview:self.distanceLabel];
}

@end
