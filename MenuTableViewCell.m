//
//  MenuTableViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 3/14/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "MenuTableViewCell.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

@interface MenuTableViewCell ()

@property (nonatomic, strong) UIImageView *menuImg;

@end

@implementation MenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.menuImg = [[UIImageView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.019, METRIC_CELL_HEIGHT/4, APPLICATION_FRAME.size.width * 0.04, APPLICATION_FRAME.size.width * 0.05)];
        self.menuImg.contentMode = UIViewContentModeScaleAspectFit;
        self.menuImg.backgroundColor = [UIColor clearColor];
        [self.menuImg setImage:[UIImage imageNamed:@"menu_icon"]];
        [self.contentView addSubview:self.menuImg];
        
        self.menuLabel = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.1, METRIC_CELL_HEIGHT/2 - METRIC_CELL_HEIGHT * 0.15, APPLICATION_FRAME.size.width * 0.6, METRIC_CELL_HEIGHT * 0.3)];
        self.menuLabel.backgroundColor = [UIColor clearColor];
        self.menuLabel.textColor = [UIColor blackColor];
        self.menuLabel.font = [UIFont nun_fontWithSize:16.0];
        [self.contentView addSubview:self.menuLabel];
        
        self.arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width - 20.0, METRIC_CELL_HEIGHT/2 - 7.5, 5.0, 10.0)];
        self.arrowImg.backgroundColor = [UIColor clearColor];
        self.arrowImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.arrowImg setImage:[UIImage imageNamed:@"arrow_right"]];
        [self.contentView addSubview:self.arrowImg];
        
        [LayoutBounds drawBoundsForAllLayers:self];
    }
    return self;
}

@end
