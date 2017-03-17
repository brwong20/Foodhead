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

@interface RestaurantDetailsTableViewCell ()

@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *category;
@property (nonatomic, strong) UILabel *openNow;
@property (nonatomic, strong) UILabel *distanceLabel;//Needs to be calculated dynamically from current dist
//@property (nonatomic, strong) ImageRatingView *ratingView;
@property (nonatomic, strong) UIImageView *distanceImg;

@end

#define METERS_TO_MILES 0.000621371

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
    self.restaurantName.numberOfLines = 0;
    self.restaurantName.textAlignment = NSTextAlignmentLeft;
    self.restaurantName.font = [UIFont nun_fontWithSize:RESTAURANT_INFO_CELL_HEIGHT * 0.2];
    self.restaurantName.textColor = [UIColor blackColor];
    [self addSubview:self.restaurantName];
    
    self.category = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.restaurantName.frame), APPLICATION_FRAME.size.width * 0.9, RESTAURANT_INFO_CELL_HEIGHT * 0.17)];
    self.category.textColor = [UIColor darkGrayColor];
    self.category.backgroundColor = [UIColor clearColor];
    [self.category setFont:[UIFont nun_fontWithSize:RESTAURANT_INFO_CELL_HEIGHT * 0.15]];
    [self addSubview:self.category];
    
    self.openNow = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), RESTAURANT_INFO_CELL_HEIGHT - RESTAURANT_INFO_CELL_HEIGHT * 0.2, APPLICATION_FRAME.size.width * 0.5, RESTAURANT_INFO_CELL_HEIGHT * 0.14)];
    self.openNow.backgroundColor = [UIColor clearColor];
    self.openNow.textColor = [UIColor lightGrayColor];
    self.openNow.font = [UIFont nun_fontWithSize:RESTAURANT_INFO_CELL_HEIGHT * 0.12];
    [self addSubview:self.openNow];
    
    self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.openNow.frame) + APPLICATION_FRAME.size.width * 0.2, CGRectGetMidY(self.openNow.frame) - RESTAURANT_INFO_CELL_HEIGHT * 0.07, APPLICATION_FRAME.size.width * 0.2, RESTAURANT_INFO_CELL_HEIGHT * 0.14)];
    self.distanceLabel.backgroundColor = [UIColor clearColor];
    self.distanceLabel.font = [UIFont nun_fontWithSize:RESTAURANT_INFO_CELL_HEIGHT * 0.12];
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
//    CGSize maxCellSize = CGSizeMake(self.restaurantName.frame.size.width, RESTAURANT_INFO_CELL_HEIGHT * 0.5);//Setting the appropriate width is a MUST here!!
//    CGRect nameSize = [self.restaurantName.text boundingRectWithSize:maxCellSize
//                                                                 options:NSStringDrawingUsesLineFragmentOrigin
//                                                              attributes:@{NSFontAttributeName:[UIFont nun_fontWithSize:22.0]} context:nil];
//    CGRect nameFrame = self.restaurantName.frame;
//    nameFrame.size = nameSize.size;
//    self.restaurantName.frame = nameFrame;
    
    NSString *categoriesStr;
//    for (int i = 0; i < restaurant.categories.count; ++i) {
//        if (i == 0) {
//            categoriesStr = restaurant.categories[i];
//            continue;
//        }
//        NSString *catStr = [restaurant.categories[i] stringByReplacingOccurrencesOfString:@"Restaurant" withString:@""];
//        categoriesStr = [categoriesStr stringByAppendingString:[NSString stringWithFormat:@", %@", catStr]];
//    }
    
    self.category.text = categoriesStr;
    
    //Meters to miles
    double miles = [restaurant.distance doubleValue] * METERS_TO_MILES;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", miles];
    
    if (restaurant.hours) {
        //Last object always Today
        NSDictionary *todayDict = [restaurant.hours lastObject];
        NSString *hoursToday = todayDict[@"Today"];
        if (hoursToday) {            
            if (restaurant.openNow) {
                self.openNow.text = [NSString stringWithFormat:@"%@/%@", @"Open", hoursToday];
            }else{
                self.openNow.text = [NSString stringWithFormat:@"%@/%@", @"Closed", hoursToday];
            }
        }else{
            self.openNow.text = @"Hours unavailable";
        }
    }
    
    //If no hours, shift UI
    
}


@end
