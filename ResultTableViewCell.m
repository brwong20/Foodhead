//
//  ResultTableViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 4/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "ResultTableViewCell.h"
#import "FoodWiseDefines.h"
#import "OverallRatingView.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ResultTableViewCell ()

@property (nonatomic, strong) UIView *infoContainer;

@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIView *sepLine;

@property (nonatomic, strong) UIImageView *openIcon;
@property (nonatomic, strong) UILabel *openNowLabel;

@property (nonatomic, strong) UIImageView *overallIcon;
@property (nonatomic, strong) OverallRatingView *overallRating;

@property (nonatomic, strong) UILabel *priceSign;
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UIImageView *distanceIcon;
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) UIImageView *restaurantThumbnail;

@end

@implementation ResultTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self setupUI];
    }
    return self;
    
}

- (void)setupUI{
    self.infoContainer = [[UIView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width/2 - APPLICATION_FRAME.size.width * 0.44, RESULT_CELL_HEIGHT * 0.03, APPLICATION_FRAME.size.width * 0.88, RESULT_CELL_HEIGHT * 0.96)];
    self.infoContainer.backgroundColor = [UIColor whiteColor];
    self.infoContainer.layer.cornerRadius = 7.0;
    //self.infoContainer.layer.borderColor = [UIColor blackColor];
    //self.infoContainer.layer.borderWidth = 0.5;
    [self.contentView addSubview:self.infoContainer];
    
    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(self.infoContainer.bounds.size.width * 0.02, 5.0, self.infoContainer.bounds.size.width * 0.9, self.infoContainer.bounds.size.height * 0.15)];
    self.restaurantName.backgroundColor = [UIColor clearColor];
    self.restaurantName.textColor = [UIColor blackColor];
    self.restaurantName.numberOfLines = 1;
    self.restaurantName.font = [UIFont nun_mediumFontWithSize:20.0];
    [self.infoContainer addSubview:self.restaurantName];
    
    self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.restaurantName.frame) + self.infoContainer.bounds.size.height * 0.01, self.infoContainer.bounds.size.width * 0.5, self.infoContainer.bounds.size.height * 0.12)];
    self.categoryLabel.backgroundColor = [UIColor clearColor];
    self.categoryLabel.textColor = UIColorFromRGB(0x505254);
    self.categoryLabel.numberOfLines = 1;
    self.categoryLabel.font = [UIFont nun_fontWithSize:14.0];
    [self.infoContainer addSubview:self.categoryLabel];
    
    self.sepLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.categoryLabel.frame) + self.infoContainer.bounds.size.height * 0.02, self.infoContainer.bounds.size.width, 1.0)];
    self.sepLine.backgroundColor = UIColorFromRGB(0xF0F1F3);
    [self.infoContainer addSubview:self.sepLine];
    
    self.openIcon = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.categoryLabel.frame), CGRectGetMaxY(self.sepLine.frame) + self.infoContainer.bounds.size.height * 0.05, self.infoContainer.bounds.size.width * 0.04, self.infoContainer.bounds.size.width * 0.04)];
    self.openIcon.backgroundColor = [UIColor clearColor];
    [self.openIcon setImage:[UIImage imageNamed:@"openNow_search"]];
    [self.infoContainer addSubview:self.openIcon];
    
    self.openNowLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.openIcon.frame) + self.infoContainer.bounds.size.width * 0.06, CGRectGetMidY(self.openIcon.frame) - self.infoContainer.bounds.size.height * 0.05, self.infoContainer.bounds.size.width * 0.4, self.infoContainer.bounds.size.height * 0.1)];
    self.openNowLabel.backgroundColor = [UIColor clearColor];
    self.openNowLabel.textColor = UIColorFromRGB(0x505254);
    self.openNowLabel.font = [UIFont nun_fontWithSize:16.0];
    [self.infoContainer addSubview:self.openNowLabel];
    
    self.overallIcon = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.openIcon.frame), CGRectGetMaxY(self.openIcon.frame) + self.infoContainer.bounds.size.height * 0.07, self.openIcon.frame.size.width, self.openIcon.frame.size.height)];
    self.overallIcon.backgroundColor = [UIColor clearColor];
    self.overallIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.overallIcon setImage:[UIImage imageNamed:@"search_overall"]];
    [self.infoContainer addSubview:self.overallIcon];
    
    self.overallRating = [[OverallRatingView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.overallIcon.frame) + self.infoContainer.bounds.size.width * 0.045, CGRectGetMidY(self.overallIcon.frame) - self.infoContainer.bounds.size.height * 0.055, self.infoContainer.bounds.size.width * 0.4, self.infoContainer.bounds.size.height * 0.11)];
    self.overallRating.backgroundColor = [UIColor clearColor];
    [self.overallRating setOverall:@(5) inReviewFlow:NO];
    [self.infoContainer addSubview:self.overallRating];
    
    self.priceSign = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.overallIcon.frame), CGRectGetMaxY(self.overallIcon.frame) + self.infoContainer.bounds.size.height * 0.07, self.openIcon.frame.size.width, self.openIcon.frame.size.height)];
    self.priceSign.backgroundColor = [UIColor clearColor];
    self.priceSign.text = @"$";
    self.priceSign.textAlignment = NSTextAlignmentCenter;
    self.priceSign.font = [UIFont nun_boldFontWithSize:22.0];
    [self.infoContainer addSubview:self.priceSign];
    
    self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.openNowLabel.frame), CGRectGetMidY(self.priceSign.frame) - self.infoContainer.bounds.size.height * 0.05, self.infoContainer.bounds.size.width * 0.4, self.infoContainer.bounds.size.height * 0.1)];
    self.priceLabel.backgroundColor = [UIColor clearColor];
    self.priceLabel.textColor = UIColorFromRGB(0x505254);
    self.priceLabel.font = [UIFont nun_fontWithSize:16.0];
    [self.infoContainer addSubview:self.priceLabel];
    
    self.restaurantThumbnail = [[UIImageView alloc]initWithFrame:CGRectMake(self.infoContainer.bounds.size.width - self.infoContainer.bounds.size.height * 0.64, (self.infoContainer.bounds.size.height + CGRectGetMaxY(self.sepLine.frame))/2 - self.infoContainer.bounds.size.height * 0.28, self.infoContainer.bounds.size.height * 0.54, self.infoContainer.bounds.size.height * 0.54)];
    self.restaurantThumbnail.backgroundColor = [UIColor whiteColor];
    self.restaurantThumbnail.layer.borderColor = [UIColor blackColor].CGColor;
    self.restaurantThumbnail.layer.cornerRadius = 10.0;
    self.restaurantThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    self.restaurantThumbnail.clipsToBounds = YES;
    [self.infoContainer addSubview:self.restaurantThumbnail];
    
    self.distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.priceSign.frame) - self.openIcon.frame.size.width * 0.45, CGRectGetMaxY(self.priceLabel.frame) + self.infoContainer.bounds.size.height * 0.07, self.openIcon.frame.size.width * 0.9, self.openIcon.frame.size.height * 0.9)];
    self.distanceIcon.backgroundColor = [UIColor clearColor];
    self.distanceIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.distanceIcon setImage:[UIImage imageNamed:@"distance_search_filter"]];
    [self.infoContainer addSubview:self.distanceIcon];

    self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.priceLabel.frame), CGRectGetMidY(self.distanceIcon.frame) - self.infoContainer.bounds.size.height * 0.05, self.infoContainer.bounds.size.width * 0.3, self.infoContainer.bounds.size.height * 0.1)];
    self.distanceLabel.backgroundColor = [UIColor clearColor];
    self.distanceLabel.textColor = UIColorFromRGB(0x505254);
    self.distanceLabel.font = [UIFont nun_fontWithSize:16.0];
    [self.infoContainer addSubview:self.distanceLabel];    
}

- (void)prepareForReuse{
    [super prepareForReuse];
    
    self.restaurantThumbnail.image = nil;
    self.restaurantName.text = @"";
    self.categoryLabel.text = @"";
    self.openNowLabel.text = @"";
    [self.overallRating setOverall:@(0) inReviewFlow:NO];
    self.distanceLabel.text = @"";
    self.priceLabel.text = @"";
}

- (void)populateRestaurant:(TPLRestaurant *)restaurant{
    self.restaurantName.text = restaurant.name;
    
    //Explore results only return the primary category so just get the first element.
    if (restaurant.categories) {
        self.categoryLabel.text = [restaurant.categories firstObject];
    }
    
    if (restaurant.openNowExplore != nil) {
        //Based on popular hour check-ins from Foursquare
        if ([restaurant.openNowStatus isEqualToString:@"Likely open"]) {//Use Foursquare status
            self.openNowLabel.text = @"Likely Open";
        }else if([restaurant.openNowExplore boolValue] && !restaurant.openNowStatus) {//Based on popular hours
            self.openNowLabel.text = @"Likely Open";
        }else if (![restaurant.openNowExplore boolValue] && !restaurant.openNowStatus){//Based on popular hours
            self.openNowLabel.text = @"Likely Closed";
        }else if ([restaurant.openNowExplore boolValue] && restaurant.openNowStatus){
            self.openNowLabel.text = @"Open";
        }else{
            self.openNowLabel.text = @"Closed";
        }
    }else{
        self.openNowLabel.text = @"Hours unavailable";
    }
    
    NSNumber *avgRating;
    avgRating = @(restaurant.foursq_rating.doubleValue/2.0);//Halve all ratings
    avgRating = @(round(avgRating.doubleValue * 2.0)/2.0);//Round to nearest multiple of 0.5
    [self.overallRating setOverall:avgRating inReviewFlow:NO];
    
    if ([restaurant.foursq_price_tier isEqual: @(1)]) {
        self.priceLabel.text = @"<12";
    }else if ([restaurant.foursq_price_tier isEqual: @(2)]){
        self.priceLabel.text = @"15-25";
    }else if ([restaurant.foursq_price_tier isEqual: @(3)]){
        self.priceLabel.text = @"30-60";
    }else if ([restaurant.foursq_price_tier isEqual: @(4)]){
        self.priceLabel.text = @"60+";
    }else{
        self.priceLabel.text = @"No price yet";
    }
    
    //Meters to miles
    if (restaurant.distance) {
        double miles = [restaurant.distance doubleValue] * METERS_TO_MILES;
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", miles];
    }
    
    [self.restaurantThumbnail sd_setImageWithURL:[NSURL URLWithString:restaurant.thumbnail] completed:nil];
}

@end
