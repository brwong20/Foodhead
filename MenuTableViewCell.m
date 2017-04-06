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
        
        UIView *sepLine = [[UIView alloc]initWithFrame:SEP_LINE_RECT];
        sepLine.center = CGPointMake(sepLine.center.x, METRIC_CELL_HEIGHT - 1.0);
        sepLine.backgroundColor = UIColorFromRGB(0x47606A);
        sepLine.alpha = 0.15;
        [self.contentView addSubview:sepLine];
        
        self.menuImg = [[UIImageView alloc]initWithFrame:CGRectMake(REST_PAGE_ICON_PADDING, METRIC_CELL_HEIGHT/3.5, APPLICATION_FRAME.size.width * 0.05, APPLICATION_FRAME.size.width * 0.06)];
        self.menuImg.contentMode = UIViewContentModeScaleAspectFit;
        self.menuImg.backgroundColor = [UIColor clearColor];
        [self.menuImg setImage:[UIImage imageNamed:@"menu_icon"]];
        [self.contentView addSubview:self.menuImg];
        
        self.menuLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(sepLine.frame), METRIC_CELL_HEIGHT/1.9 - METRIC_CELL_HEIGHT * 0.15, APPLICATION_FRAME.size.width * 0.6, METRIC_CELL_HEIGHT * 0.3)];
        self.menuLabel.backgroundColor = [UIColor clearColor];
        self.menuLabel.textColor = [UIColor blackColor];
        self.menuLabel.font = [UIFont nun_fontWithSize:REST_PAGE_HEADER_FONT_SIZE];
        [self.contentView addSubview:self.menuLabel];
        
        self.arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(sepLine.frame) - 5.0, METRIC_CELL_HEIGHT/2 - 4.5, 5.0, 9)];
        self.arrowImg.backgroundColor = [UIColor clearColor];
        self.arrowImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.arrowImg setImage:[UIImage imageNamed:@"arrow_right"]];
        [self.contentView addSubview:self.arrowImg];        
    }
    return self;
}

@end
