//
//  MetricsDisplayCell.m
//  FoodWise
//
//  Created by Brian Wong on 2/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "MetricsDisplayCell.h"
#import "FoodWiseDefines.h"
#import "LayoutBounds.h"
#import "UIFont+Extension.h"
#import "OverallRatingView.h"
#import "HealthRatingView.h"
#import "UserReview.h"

@interface MetricsDisplayCell()

//Separators
@property (nonatomic, strong) UIView *sep1;
@property (nonatomic, strong) UIView *sep2;
@property (nonatomic, strong) UIView *sep3;

//Reviews
@property (nonatomic, strong) OverallRatingView *overallTitle;
@property (nonatomic, strong) UILabel *overallLabel;

//Price
@property (nonatomic, strong) UILabel *avgPriceTitle;
@property (nonatomic, strong) UILabel *avgPriceLabel;

//Health
@property (nonatomic, strong) HealthRatingView *healthTitle;
@property (nonatomic, strong) UILabel *healthLabel;

@end

@implementation MetricsDisplayCell

#define SEPARATOR_PADDING 10.0

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGRect screen = [[UIScreen mainScreen]bounds];
    
    UIView *topSep = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APPLICATION_FRAME.size.width, 1.0)];
    topSep.backgroundColor = UIColorFromRGB(0x47606A);
    topSep.alpha = 0.15;
    [self.contentView addSubview:topSep];
    
    self.sep1 = [[UIView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width/3 - 1.0, 0, 1.0, METRIC_CELL_HEIGHT)];
    self.sep1.backgroundColor = UIColorFromRGB(0x47606A);
    self.sep1.alpha = 0.15;
    [self.contentView addSubview:self.sep1];
    
    self.sep2 = [[UIView alloc]initWithFrame:CGRectMake(((APPLICATION_FRAME.size.width/3) * 2) - 1.0, 0, 1.0, METRIC_CELL_HEIGHT)];
    self.sep2.backgroundColor = UIColorFromRGB(0x47606A);
    self.sep2.alpha = 0.15;
    [self.contentView addSubview:self.sep2];
    
    self.overallTitle = [[OverallRatingView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.sep1.frame)/2 - CGRectGetMaxX(self.sep1.frame) * 0.44, METRIC_CELL_HEIGHT * 0.5, CGRectGetMaxX(self.sep1.frame) * 0.88, METRIC_CELL_HEIGHT * 0.45)];
    self.overallTitle.backgroundColor = [UIColor clearColor];
    [self.overallTitle setOverall:@(0) inReviewFlow:NO];
    [self.contentView addSubview:self.overallTitle];
    
    self.overallLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screen.size.width * 0.24, METRIC_CELL_HEIGHT * 0.3)];
    self.overallLabel.center = CGPointMake(CGRectGetMidX(self.overallTitle.frame), CGRectGetMinY(self.overallTitle.frame) - METRIC_CELL_HEIGHT * 0.18);
    self.overallLabel.alpha = 0.0;
    self.overallLabel.backgroundColor = [UIColor clearColor];
    [self.overallLabel setFont:[UIFont nun_boldFontWithSize:APPLICATION_FRAME.size.width * 0.05]];
    [self.overallLabel setTextColor:[UIColor blackColor]];
    [self.overallLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.overallLabel];
    
    self.avgPriceTitle = [[UILabel alloc]initWithFrame:CGRectMake((CGRectGetMaxX(self.sep1.frame) + CGRectGetMinX(self.sep2.frame))/2 - screen.size.width * 0.14, CGRectGetMinY(self.overallTitle.frame), screen.size.width * 0.28, METRIC_CELL_HEIGHT * 0.34)];
    self.avgPriceTitle.backgroundColor = [UIColor clearColor];
    self.avgPriceTitle.alpha = 0.0;
    [self.avgPriceTitle setFont:[UIFont nun_boldFontWithSize:APPLICATION_FRAME.size.width * 0.05]];
    [self.avgPriceTitle setTextColor:[UIColor lightGrayColor]];
    [self.avgPriceTitle setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.avgPriceTitle];
    
    self.avgPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.avgPriceTitle.frame) - screen.size.width * 0.13, CGRectGetMidY(self.overallLabel.frame) - METRIC_CELL_HEIGHT * 0.15, screen.size.width * 0.26, METRIC_CELL_HEIGHT * 0.3)];
    self.avgPriceLabel.backgroundColor = [UIColor clearColor];
    self.avgPriceTitle.alpha = 0.0;
    [self.avgPriceLabel setFont:[UIFont nun_boldFontWithSize:APPLICATION_FRAME.size.width * 0.044]];
    [self.avgPriceLabel setTextColor:[UIColor blackColor]];
    [self.avgPriceLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.avgPriceLabel];

    self.healthTitle = [[HealthRatingView alloc]initWithFrame:CGRectMake(screen.size.width - CGRectGetMinX(self.sep1.frame)/2 - screen.size.width * 0.14 , CGRectGetMinY(self.overallTitle.frame), screen.size.width * 0.28, self.overallTitle.frame.size.height * 0.97)];
    self.healthTitle.backgroundColor = [UIColor clearColor];
    [self.healthTitle setHealth:@(0) inReviewFlow:NO];
    [self.contentView addSubview:self.healthTitle];
    
    self.healthLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.healthTitle.frame) - screen.size.width * 0.1, CGRectGetMinY(self.overallLabel.frame), screen.size.width * 0.2, METRIC_CELL_HEIGHT * 0.3)];
    self.healthLabel.alpha = 0.0;
    self.healthLabel.backgroundColor = [UIColor clearColor];
    [self.healthLabel setFont:[UIFont nun_boldFontWithSize:APPLICATION_FRAME.size.width * 0.05]];
    [self.healthLabel setTextColor:[UIColor blackColor]];
    [self.healthLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.healthLabel];    
}

- (void)populateMetrics:(TPLRestaurant *)restaurant withUserReviews:(NSMutableArray *)reviews{
    //Holds averages of all reviews
    double userPrice = 0.0;
    double userOverall = 0.0;
    double userHealth = 0.0;
    
    //Counts to determine if we convert or not
    int overallCount = 0;
    int healthCount = 0;
    int priceCount = 0;
    
    for (UserReview *review in reviews) {
        if (review.overall) {
            ++overallCount;
            userOverall += review.overall.doubleValue;
        }
        if (review.healthiness) {
            ++healthCount;
            userHealth += review.healthiness.doubleValue;
            
        }
        if (review.price) {
            ++priceCount;
            userPrice += review.price.doubleValue;
        }
    }

    userOverall = (round((userOverall/overallCount) * 2.0))/2.0;//Rounds to nearest 0.5
    userHealth = round(userHealth/healthCount);
    userPrice = userPrice/priceCount;
    
    //If not enough user reviews, use Foursquare's
    NSNumber *avgRating;
    if (overallCount >= OVERALL_CONVERSION_COUNT) {
        avgRating = @(userOverall);
        [self.overallTitle setOverall:avgRating inReviewFlow:NO];
    }else{
        avgRating = @(restaurant.foursq_rating.doubleValue/2.0);//Halve all ratings
        avgRating = @(round(avgRating.doubleValue * 2.0)/2.0);//Round to nearest multiple of 0.5
        [self.overallTitle setOverall:avgRating inReviewFlow:NO];
    }
    
    NSNumber *totalRatings = @(restaurant.foursq_num_ratings.integerValue + overallCount);
    self.overallLabel.text = [totalRatings stringValue];

    if (priceCount >= PRICE_CONVERSION_COUNT) {
        self.avgPriceTitle.text = @"per person";
        NSNumber *avgPrice = @(userPrice);
        self.avgPriceLabel.text = [NSString stringWithFormat:@"$%.2f", avgPrice.doubleValue];
    }else{
        self.avgPriceTitle.text = @"per person";
        if ([restaurant.foursq_price_tier isEqual: @(1)]) {
            self.avgPriceLabel.text = @"<$12";
        }else if ([restaurant.foursq_price_tier isEqual: @(2)]){
            self.avgPriceLabel.text = @"$15-30";
        }else if ([restaurant.foursq_price_tier isEqual: @(3)]){
            self.avgPriceLabel.text = @"$30-60";
        }else if ([restaurant.foursq_price_tier isEqual: @(4)]){
            self.avgPriceLabel.text = @"$60+";
        }else{
            self.avgPriceTitle.text = @"no price yet";
        }
    }
    
    if (healthCount > HEALTH_CONVERSION_COUNT) {
        NSNumber *avgHealth = @(userHealth);
        [self.healthTitle setHealth:avgHealth inReviewFlow:NO];
        self.healthLabel.text = [NSString stringWithFormat:@"%d", healthCount];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.overallLabel.alpha = 1.0;
        self.healthLabel.alpha = 1.0;
        self.avgPriceTitle.alpha = 1.0;
        self.avgPriceLabel.alpha = 1.0;
    }];
}


@end
