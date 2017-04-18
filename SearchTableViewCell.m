//
//  SearchTableViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 4/7/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "SearchTableViewCell.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"
#import "NSString+IsEmpty.h"

@interface SearchTableViewCell ()

@property (nonatomic, strong) UIImageView *searchImg;
@property (nonatomic, strong) UILabel *searchLabel;
@property (nonatomic, strong) UILabel *searchSubLabel;
@property (nonatomic, strong) UIView *sepLine;

@end

@implementation SearchTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = APPLICATION_BACKGROUND_COLOR;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.sepLine = [[UIView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.12, SEARCH_CONTROLLER_CELL_HEIGHT - 1.0, APPLICATION_FRAME.size.width * 0.84, 1.0)];
        self.sepLine.backgroundColor = UIColorFromRGB(0x47606A);
        self.sepLine.alpha = 0.15;
        [self.contentView addSubview:self.sepLine];
        
        self.searchImg = [[UIImageView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.04, SEARCH_CONTROLLER_CELL_HEIGHT/2 - SEARCH_CONTROLLER_CELL_HEIGHT * 0.2, SEARCH_CONTROLLER_CELL_HEIGHT * 0.35, SEARCH_CONTROLLER_CELL_HEIGHT * 0.36)];
        self.searchImg.contentMode = UIViewContentModeScaleAspectFit;
        self.searchImg.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.searchImg];
        
        self.searchLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.sepLine.frame), SEARCH_CONTROLLER_CELL_HEIGHT/2 - SEARCH_CONTROLLER_CELL_HEIGHT * 0.35, APPLICATION_FRAME.size.width * 0.8, SEARCH_CONTROLLER_CELL_HEIGHT * 0.35)];
        self.searchLabel.backgroundColor = [UIColor clearColor];
        [self.searchLabel setFont:[UIFont nun_mediumFontWithSize:16.0]];
        [self.contentView addSubview:self.searchLabel];
        
        self.searchSubLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.searchLabel.frame), CGRectGetMaxY(self.searchLabel.frame), APPLICATION_FRAME.size.width * 0.8, SEARCH_CONTROLLER_CELL_HEIGHT * 0.35)];
        self.searchSubLabel.backgroundColor = [UIColor clearColor];
        self.searchSubLabel.textColor = UIColorFromRGB(0x505254);
        [self.searchSubLabel setFont:[UIFont nun_fontWithSize:14.0]];
        [self.contentView addSubview:self.searchSubLabel];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    [self.searchImg setImage:nil];
    self.searchLabel.frame = CGRectMake(CGRectGetMinX(self.sepLine.frame), SEARCH_CONTROLLER_CELL_HEIGHT/2 - SEARCH_CONTROLLER_CELL_HEIGHT * 0.35, APPLICATION_FRAME.size.width * 0.8, SEARCH_CONTROLLER_CELL_HEIGHT * 0.35);
}

- (void)populateRestaurant:(TPLRestaurant *)restaurant{
    [self.searchImg setImage:[UIImage imageNamed:@"location_icon"]];
    self.searchLabel.text = restaurant.name;
    self.searchSubLabel.alpha = 1.0;
    
    NSString *addressString = [NSString string];
    if (![NSString isEmpty:restaurant.suggestion_address]) {
        addressString = [addressString stringByAppendingString:[NSString stringWithFormat:@"%@, %@", restaurant.suggestion_address, restaurant.suggestion_city]];
    }else if(![NSString isEmpty:restaurant.suggestion_city]) {
        addressString = [addressString stringByAppendingString:[NSString stringWithFormat:@"%@", restaurant.suggestion_city]];
    }
    
    //Final check just in case
    if ([NSString isEmpty:addressString]) {
        self.searchLabel.frame = CGRectMake(self.searchLabel.frame.origin.x, SEARCH_CONTROLLER_CELL_HEIGHT/2 - SEARCH_CONTROLLER_CELL_HEIGHT * 0.175, self.searchLabel.frame.size.width, self.searchLabel.frame.size.height);
        self.searchSubLabel.alpha = 0.0;
    }

    self.searchSubLabel.text = addressString;
}

- (void)populateCategory:(Category *)category{
    [self.searchImg setImage:[UIImage imageNamed:@"search"]];
    self.searchLabel.text = category.categoryShortName;
    self.searchLabel.frame = CGRectMake(self.searchLabel.frame.origin.x, SEARCH_CONTROLLER_CELL_HEIGHT/2 - SEARCH_CONTROLLER_CELL_HEIGHT * 0.175, self.searchLabel.frame.size.width, self.searchLabel.frame.size.height);
    self.searchSubLabel.alpha = 0.0;
}

@end
