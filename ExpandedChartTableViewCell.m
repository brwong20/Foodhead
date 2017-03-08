//
//  ExpandedChartTableViewCell.m
//  FoodWise
//
//  Created by Brian Wong on 2/14/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "ExpandedChartTableViewCell.h"
#import "FoodWiseDefines.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation ExpandedChartTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
        
        self.thumbImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5.0, CATEGORY_RESTAURANT_CELL_HEIGHT * 0.5 - CATEGORY_RESTAURANT_CELL_HEIGHT * 0.425, CATEGORY_RESTAURANT_CELL_HEIGHT * 0.85, CATEGORY_RESTAURANT_CELL_HEIGHT * 0.85)];
        self.thumbImageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.thumbImageView];
        
        self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.thumbImageView.frame) + screenWidth * 0.05, CGRectGetMinY(self.thumbImageView.frame), screenWidth * 0.5, CATEGORY_RESTAURANT_CELL_HEIGHT * 0.2)];
        self.restaurantName.textAlignment = NSTextAlignmentLeft;
        self.restaurantName.font = [UIFont boldSystemFontOfSize:CATEGORY_RESTAURANT_CELL_HEIGHT * 0.25];
        self.restaurantName.backgroundColor = [UIColor clearColor];
        self.restaurantName.textColor = [UIColor whiteColor];
        [self addSubview:self.restaurantName];
    }
    return self;
}

@end
