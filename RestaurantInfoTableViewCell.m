//
//  RestaurantInfoTableViewCell.m
//  FoodWise
//
//  Created by Brian Wong on 2/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RestaurantInfoTableViewCell.h"
#import "FoodWiseDefines.h"

@interface RestaurantInfoTableViewCell()

@property (nonatomic, strong) UIImageView *locationIcon;
@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation RestaurantInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        
//        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
//        detector match
    }
    return self;
}

- (void)setupUI{
    self.contentView.backgroundColor = [UIColor blackColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(screenSize.width * 0.05, RESTAURANT_INFO_CELL_HEIGHT * 0.12, screenSize.width * 0.5, RESTAURANT_INFO_CELL_HEIGHT * 0.2)];
    self.restaurantName.text = @"Jean-Georges";
    self.restaurantName.backgroundColor = [UIColor clearColor];
    self.restaurantName.textColor = [UIColor grayColor];
    self.restaurantName.font = [UIFont boldSystemFontOfSize:18.0];
    [self.contentView addSubview:self.restaurantName];
    
    self.addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenSize.width * 0.05 , CGRectGetMaxY(self.restaurantName.frame), screenSize.width * 0.3, RESTAURANT_INFO_CELL_HEIGHT * 0.5)];
    self.addressLabel.textColor = [UIColor whiteColor];
    self.addressLabel.backgroundColor = [UIColor clearColor];
    self.addressLabel.numberOfLines = 0;
    [self.addressLabel setText:@"Address 1\nAddress 2"];
    [self.contentView addSubview:self.addressLabel];
    
    self.restaurantLink = [[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.restaurantName.frame) + screenSize.width * 0.1, CGRectGetMaxY(self.restaurantName.frame) - RESTAURANT_INFO_CELL_HEIGHT * 0.1, screenSize.width * 0.3, RESTAURANT_INFO_CELL_HEIGHT * 0.1)];
    self.restaurantLink.dataDetectorTypes = UIDataDetectorTypeLink;
    self.restaurantLink.backgroundColor = [UIColor blueColor];
    self.restaurantLink.textColor = [UIColor whiteColor];
    self.restaurantLink.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor grayColor]};
    self.restaurantLink.editable = NO;
    self.restaurantLink.scrollEnabled  = NO;
    self.restaurantLink.backgroundColor = [UIColor clearColor];
    self.restaurantLink.text = @"jean-georges.com";
    [self.contentView addSubview:self.restaurantLink];

    self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(screenSize.width * 0.8, CGRectGetMaxY(self.restaurantLink.frame) + RESTAURANT_INFO_CELL_HEIGHT * 0.2, RESTAURANT_INFO_CELL_HEIGHT * 0.4, RESTAURANT_INFO_CELL_HEIGHT * 0.4)];
    self.shareButton.backgroundColor = [UIColor whiteColor];
    self.shareButton.layer.cornerRadius = self.shareButton.frame.size.height * 0.07;
    [self.shareButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [self.contentView addSubview:self.shareButton];
}

@end
