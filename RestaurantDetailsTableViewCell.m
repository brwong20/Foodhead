//
//  RestaurantDetailsTableViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 3/14/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RestaurantDetailsTableViewCell.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"
#import "NSString+IsEmpty.h"
#import "FoodheadAnalytics.h"

@interface RestaurantDetailsTableViewCell ()

@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *category;
@property (nonatomic, strong) UILabel *openNow;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UIImageView *distanceImg;
@property (nonatomic, strong) UIButton *callButton;
@property (nonatomic, strong) NSString *phoneNumber;

@end

@implementation RestaurantDetailsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    //Modularize into own class
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.03, RESTAURANT_INFO_CELL_HEIGHT * 0.05, APPLICATION_FRAME.size.width * 0.9, RESTAURANT_INFO_CELL_HEIGHT * 0.27)];
    self.restaurantName.numberOfLines = 1;
    self.restaurantName.textAlignment = NSTextAlignmentLeft;
    self.restaurantName.font = [UIFont nun_fontWithSize:RESTAURANT_INFO_CELL_HEIGHT * 0.23];
    self.restaurantName.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.restaurantName];
    
    self.category = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.restaurantName.frame) + RESTAURANT_INFO_CELL_HEIGHT * 0.12, APPLICATION_FRAME.size.width * 0.85, RESTAURANT_INFO_CELL_HEIGHT * 0.17)];
    self.category.textColor = [UIColor darkGrayColor];
    self.category.backgroundColor = [UIColor clearColor];
    [self.category setFont:[UIFont nun_fontWithSize:REST_PAGE_HEADER_FONT_SIZE]];
    self.category.alpha = 0.0;
    [self.contentView addSubview:self.category];
    
    self.openNow = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.category.frame) + RESTAURANT_INFO_CELL_HEIGHT * 0.03, APPLICATION_FRAME.size.width * 0.8, RESTAURANT_INFO_CELL_HEIGHT * 0.14)];
    self.openNow.backgroundColor = [UIColor clearColor];
    self.openNow.textColor = [UIColor lightGrayColor];
    self.openNow.font = [UIFont nun_fontWithSize:REST_PAGE_DETAIL_FONT_SIZE];
    self.openNow.alpha = 0.0;
    [self.contentView addSubview:self.openNow];
    
    self.distanceImg = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.openNow.frame), CGRectGetMaxY(self.openNow.frame) + RESTAURANT_INFO_CELL_HEIGHT * 0.06, RESTAURANT_INFO_CELL_HEIGHT * 0.1,  RESTAURANT_INFO_CELL_HEIGHT * 0.1)];
    self.distanceImg.alpha = 0.0;
    self.distanceImg.contentMode = UIViewContentModeScaleAspectFit;
    self.distanceImg.backgroundColor = [UIColor clearColor];
    [self.distanceImg setImage:[UIImage imageNamed:@"distance_icon"]];
    [self.contentView addSubview:self.distanceImg];
    
    self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.distanceImg.frame) + RESTAURANT_INFO_CELL_HEIGHT * 0.06, CGRectGetMidY(self.distanceImg.frame) - RESTAURANT_INFO_CELL_HEIGHT * 0.07, APPLICATION_FRAME.size.width * 0.2, RESTAURANT_INFO_CELL_HEIGHT * 0.14)];
    self.distanceLabel.backgroundColor = [UIColor clearColor];
    self.distanceLabel.font = [UIFont nun_fontWithSize:REST_PAGE_DETAIL_FONT_SIZE];
    self.distanceLabel.textColor = [UIColor grayColor];
    self.distanceLabel.alpha = 0.0;
    [self.contentView addSubview:self.distanceLabel];
    
    self.callButton = [[UIButton alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.9, RESTAURANT_INFO_CELL_HEIGHT - APPLICATION_FRAME.size.width * 0.1, APPLICATION_FRAME.size.width * 0.1, APPLICATION_FRAME.size.width * 0.1)];
    self.callButton.backgroundColor = [UIColor clearColor];
    [self.callButton setImage:[UIImage imageNamed:@"call_btn"] forState:UIControlStateNormal];
    [self.callButton addTarget:self action:@selector(callRestaurant) forControlEvents:UIControlEventTouchUpInside];
    self.callButton.alpha = 0.0;
    [self.contentView addSubview:self.callButton];
}

- (void)setInfoForRestaurant:(TPLRestaurant *)restaurant{
    self.restaurantName.text = restaurant.name;
    
    NSString *categoriesStr = @"";
    if (restaurant.categories.count == 1) {
        NSString *catStr = [[restaurant.categories firstObject]stringByReplacingOccurrencesOfString:@" Restaurant" withString:@""];
        categoriesStr = catStr;
    }else if(restaurant.categories.count > 1){
        NSString *firstCat = [restaurant.categories[0] stringByReplacingOccurrencesOfString:@" Restaurant" withString:@""];
        NSString *secondCat = [restaurant.categories[1] stringByReplacingOccurrencesOfString:@" Restaurant" withString:@""];
        categoriesStr = [NSString stringWithFormat:@"%@, %@", firstCat, secondCat];
    }
    self.category.text = categoriesStr;

    //Meters to miles
    if (restaurant.distance) {
        double miles = [restaurant.distance doubleValue] * METERS_TO_MILES;
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", miles];
    }
    
    if (restaurant.hours) {
        //Last object always Today
        NSDictionary *todayDict = [restaurant.hours lastObject];
        NSString *hoursToday = todayDict[@"Today"];
        if (hoursToday) {            
            if (restaurant.openNow) {
                self.openNow.text = [NSString stringWithFormat:@"%@ / %@", @"Open", hoursToday];
            }else{
                self.openNow.text = [NSString stringWithFormat:@"%@ / %@", @"Closed", hoursToday];
            }
        }else{
            self.openNow.text = @"Hours unavailable";
        }
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.category.alpha = 1.0;
        self.distanceImg.alpha = 1.0;
        self.distanceLabel.alpha = 1.0;
        self.openNow.alpha = 1.0;
        self.phoneNumber = restaurant.phoneNumber;
        if (![NSString isEmpty:self.phoneNumber]) {
            self.callButton.alpha = 1.0;
        }
    }];
}

#pragma mark - Call Restaurant

- (void)callRestaurant{
    if (![NSString isEmpty:self.phoneNumber]) {
        [FoodheadAnalytics logEvent:CALL_RESTAURANT];
        NSString *formattedNumber = [self.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:formattedNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber] options:@{} completionHandler:nil];
    }
}

@end
