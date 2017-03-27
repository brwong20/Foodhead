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

    self.locationIcon = [[UIImageView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.02, RESTAURANT_LOCATION_CELL_HEIGHT * 0.07, APPLICATION_FRAME.size.width * 0.04, APPLICATION_FRAME.size.width * 0.05)];
    self.locationIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.locationIcon.backgroundColor = [UIColor clearColor];
    [self.locationIcon setImage:[UIImage imageNamed:@"location_icon"]];
    [self.contentView addSubview:self.locationIcon];
    
    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.1, RESTAURANT_LOCATION_CELL_HEIGHT * 0.1, APPLICATION_FRAME.size.width * 0.7, RESTAURANT_LOCATION_CELL_HEIGHT * 0.2)];
    self.restaurantName.backgroundColor = [UIColor clearColor];
    self.restaurantName.textColor = [UIColor blackColor];
    self.restaurantName.font = [UIFont nun_fontWithSize:RESTAURANT_LOCATION_CELL_HEIGHT * 0.11];
    [self.contentView addSubview:self.restaurantName];
    
    self.addressLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.restaurantName.frame) + RESTAURANT_LOCATION_CELL_HEIGHT * 0.05, APPLICATION_FRAME.size.width * 0.6, RESTAURANT_LOCATION_CELL_HEIGHT * 0.3)];
    self.addressLabel.textColor = UIColorFromRGB(0x505254);
    self.addressLabel.backgroundColor = [UIColor clearColor];
    self.addressLabel.numberOfLines = 0;
    self.addressLabel.enabledTextCheckingTypes = NSTextCheckingTypeAddress;
    self.addressLabel.delegate = self;
    self.addressLabel.linkAttributes = @{NSForegroundColorAttributeName : UIColorFromRGB(0x505254), NSUnderlineStyleAttributeName : @(1), NSUnderlineColorAttributeName : UIColorFromRGB(0x505254)};
    self.addressLabel.font = [UIFont nun_fontWithSize:RESTAURANT_LOCATION_CELL_HEIGHT * 0.1];
    [self.contentView addSubview:self.addressLabel];
    
    self.restaurantLink = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.addressLabel.frame) + RESTAURANT_LOCATION_CELL_HEIGHT * 0.05, APPLICATION_FRAME.size.width * 0.7, RESTAURANT_LOCATION_CELL_HEIGHT * 0.2)];
    self.restaurantLink.textColor = UIColorFromRGB(0x505254);
    self.restaurantLink.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.restaurantLink.delegate = self;
    self.restaurantLink.linkAttributes = @{NSForegroundColorAttributeName : UIColorFromRGB(0x505254), NSUnderlineStyleAttributeName : @(1), NSUnderlineColorAttributeName : UIColorFromRGB(0x505254)};
    self.restaurantLink.backgroundColor = [UIColor clearColor];
    self.restaurantLink.font = [UIFont nun_fontWithSize:RESTAURANT_LOCATION_CELL_HEIGHT * 0.1];
    [self.contentView addSubview:self.restaurantLink];

    self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.restaurantName.frame) + APPLICATION_FRAME.size.width * 0.03, CGRectGetMinY(self.restaurantName.frame), RESTAURANT_LOCATION_CELL_HEIGHT * 0.4, RESTAURANT_LOCATION_CELL_HEIGHT * 0.4)];
    self.shareButton.backgroundColor = [UIColor clearColor];
    [self.shareButton setImage:[UIImage imageNamed:@"share_btn"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.shareButton];
    
    [LayoutBounds drawBoundsForAllLayers:self];
}

- (void)populateInfo:(TPLRestaurant *)restaurant{
    if (restaurant) {
        if(restaurant.name.length > 0) self.restaurantName.text = restaurant.name;
        
        if(restaurant.address > 0) self.addressLabel.text = [NSString stringWithFormat:@"%@\n%@, %@ %@",restaurant.address, restaurant.city, restaurant.state, restaurant.zipCode];
        
        if (restaurant.website) {
            self.restaurantLink.text = restaurant.website;
        }else{
            self.restaurantLink.text = @"Website unavailable";
        }
    }
}

#pragma TTTAttributedLabel Delegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    if (url.absoluteString == self.restaurantLink.text){
//        if ([self.delegate respondsToSelector:@selector(didTapLocation)]) {
//            [self.delegate didTapLocation];
//        }
    }
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents{
    if ([self.delegate respondsToSelector:@selector(didTapLocation)]) {
        [self.delegate didTapLocation];
    }
}

@end
