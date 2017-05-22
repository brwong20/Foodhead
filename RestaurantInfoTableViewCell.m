//
//  RestaurantInfoTableViewCell.m
//  FoodWise
//
//  Created by Brian Wong on 2/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RestaurantInfoTableViewCell.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"
#import "TTTAttributedLabel.h"
#import "FoodheadAnalytics.h"

#import "NSString+IsEmpty.h"

@interface RestaurantInfoTableViewCell() <TTTAttributedLabelDelegate>

@property (nonatomic, strong) UIImageView *locationIcon;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) TTTAttributedLabel *addressLabel;
@property (nonatomic, strong) TTTAttributedLabel *restaurantLink;

@end

@implementation RestaurantInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    UIView *sepLine = [[UIView alloc]initWithFrame:SEP_LINE_RECT];
    sepLine.center = CGPointMake(sepLine.center.x, RESTAURANT_LOCATION_CELL_HEIGHT - 1.0);
    sepLine.backgroundColor = UIColorFromRGB(0x47606A);
    sepLine.alpha = 0.15;
    [self.contentView addSubview:sepLine];
    
    self.locationIcon = [[UIImageView alloc]initWithFrame:CGRectMake(REST_PAGE_ICON_PADDING, RESTAURANT_LOCATION_CELL_HEIGHT * 0.07, APPLICATION_FRAME.size.width * 0.05, APPLICATION_FRAME.size.width * 0.06)];
    self.locationIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.locationIcon.backgroundColor = [UIColor clearColor];
    [self.locationIcon setImage:[UIImage imageNamed:@"location_icon"]];
    [self.contentView addSubview:self.locationIcon];
    
    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.locationIcon.frame) + APPLICATION_FRAME.size.width * 0.04, CGRectGetMidY(self.locationIcon.frame) - RESTAURANT_LOCATION_CELL_HEIGHT * 0.1, APPLICATION_FRAME.size.width * 0.75, RESTAURANT_LOCATION_CELL_HEIGHT * 0.2)];
    self.restaurantName.backgroundColor = [UIColor clearColor];
    self.restaurantName.textColor = [UIColor blackColor];
    self.restaurantName.font = [UIFont nun_mediumFontWithSize:REST_PAGE_HEADER_FONT_SIZE];
    [self.contentView addSubview:self.restaurantName];
    
    self.addressLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.restaurantName.frame) + RESTAURANT_LOCATION_CELL_HEIGHT * 0.05, APPLICATION_FRAME.size.width * 0.6, RESTAURANT_LOCATION_CELL_HEIGHT * 0.3)];
    self.addressLabel.textColor = UIColorFromRGB(0x505254);
    self.addressLabel.backgroundColor = [UIColor clearColor];
    self.addressLabel.numberOfLines = 0;
    self.addressLabel.enabledTextCheckingTypes = NSTextCheckingTypeAddress;
    self.addressLabel.delegate = self;
    self.addressLabel.linkAttributes = @{NSForegroundColorAttributeName : UIColorFromRGB(0x505254), NSUnderlineStyleAttributeName : @(1), NSUnderlineColorAttributeName : UIColorFromRGB(0x505254)};
    self.addressLabel.activeLinkAttributes = @{NSForegroundColorAttributeName : APPLICATION_BLUE_COLOR, NSUnderlineStyleAttributeName : @(1), NSUnderlineColorAttributeName : APPLICATION_BLUE_COLOR};
    self.addressLabel.font = [UIFont nun_fontWithSize:REST_PAGE_DETAIL_FONT_SIZE];
    [self.contentView addSubview:self.addressLabel];
    
    self.restaurantLink = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.addressLabel.frame) + RESTAURANT_LOCATION_CELL_HEIGHT * 0.05, APPLICATION_FRAME.size.width * 0.7, RESTAURANT_LOCATION_CELL_HEIGHT * 0.2)];
    self.restaurantLink.textColor = UIColorFromRGB(0x505254);
    self.restaurantLink.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.restaurantLink.delegate = self;
    self.restaurantLink.linkAttributes = @{NSForegroundColorAttributeName : UIColorFromRGB(0x505254), NSUnderlineStyleAttributeName : @(1), NSUnderlineColorAttributeName : UIColorFromRGB(0x505254)};
    self.restaurantLink.activeLinkAttributes = @{NSForegroundColorAttributeName : APPLICATION_BLUE_COLOR, NSUnderlineStyleAttributeName : @(1), NSUnderlineColorAttributeName : APPLICATION_BLUE_COLOR};
    self.restaurantLink.backgroundColor = [UIColor clearColor];
    self.restaurantLink.font = [UIFont nun_fontWithSize:REST_PAGE_DETAIL_FONT_SIZE];
    [self.contentView addSubview:self.restaurantLink];

//    self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.restaurantName.frame) + APPLICATION_FRAME.size.width * 0.03, CGRectGetMinY(self.restaurantName.frame), RESTAURANT_LOCATION_CELL_HEIGHT * 0.4, RESTAURANT_LOCATION_CELL_HEIGHT * 0.4)];
//    self.shareButton.backgroundColor = [UIColor clearColor];
//    [self.shareButton setImage:[UIImage imageNamed:@"share_btn"] forState:UIControlStateNormal];
//    [self.contentView addSubview:self.shareButton];
}

- (void)populateInfo:(TPLRestaurant *)restaurant{
    if (restaurant) {
        
        //Meters to miles
        if (restaurant.distance) {
            double miles = [restaurant.distance doubleValue] * METERS_TO_MILES;
            self.restaurantName.text = [NSString stringWithFormat:@"%.2f mi away", miles];
        }
        
        NSString *addressText = @"";
        if(![NSString isEmpty:restaurant.address]) addressText = [addressText stringByAppendingString:restaurant.address];
        
        if (![NSString isEmpty:restaurant.city] && ![NSString isEmpty:restaurant.state]) {
            addressText = [addressText stringByAppendingString:[NSString stringWithFormat:@"\n%@, %@", restaurant.city, restaurant.state]];
        }
        
        if (![NSString isEmpty:restaurant.zipCode]) {
            addressText = [addressText stringByAppendingString:[NSString stringWithFormat:@" %@", restaurant.zipCode]];
        }
        
//        if ([NSString isEmpty:addressText]) {
//            addressText = @"Address unavailable";
//        }
        self.addressLabel.text = addressText;
        
        if (![NSString isEmpty:restaurant.website]) {
            self.restaurantLink.text = restaurant.website;
        }else{
            self.restaurantLink.text = @"Website unavailable";
        }
    }
}

#pragma TTTAttributedLabel Delegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    if ([self.delegate respondsToSelector:@selector(didTapRestaurantLink:)]) {
        [FoodheadAnalytics logEvent:OPEN_RESTAURANT_WEBSITE];
        [self.delegate didTapRestaurantLink:url];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents{
    if ([self.delegate respondsToSelector:@selector(didTapLocation)]) {
        [FoodheadAnalytics logEvent:OPEN_RESTAURANT_ADDRESS];
        [self.delegate didTapLocation];
    }
}

@end
