//
//  SuggestionTableViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 3/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "SuggestionTableViewCell.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

@interface SuggestionTableViewCell ()

@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *address;

@end

@implementation SuggestionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.03, SEARCH_CELL_HEIGHT * 0.15, APPLICATION_FRAME.size.width * 0.8, SEARCH_CELL_HEIGHT * 0.22)];
    self.restaurantName.backgroundColor = [UIColor clearColor];
    self.restaurantName.font = [UIFont nun_fontWithSize:SEARCH_CELL_HEIGHT * 0.19];
    self.restaurantName.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.restaurantName];
    
    self.address = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.restaurantName.frame), CGRectGetMaxY(self.restaurantName.frame), APPLICATION_FRAME.size.width * 0.8, SEARCH_CELL_HEIGHT * 0.4)];
    self.address.backgroundColor = [UIColor clearColor];
    self.address.numberOfLines = 0;
    self.address.font = [UIFont nun_fontWithSize:SEARCH_CELL_HEIGHT * 0.15];
    self.address.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.address];
    
    //[LayoutBounds drawBoundsForAllLayers:self];
}

- (void)populateRestaurantInfo:(TPLRestaurant *)restaurant{
    self.restaurantName.text = restaurant.name;
    self.address.text = [NSString stringWithFormat:@"%@\n%@, %@", restaurant.suggestion_address, restaurant.suggestion_city, restaurant.suggestion_state];
}

@end
