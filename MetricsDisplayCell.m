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

@interface MetricsDisplayCell()

//Separators
@property (nonatomic, strong) UIView *sep1;
@property (nonatomic, strong) UIView *sep2;
@property (nonatomic, strong) UIView *sep3;

//Reviews
@property (nonatomic, strong) UILabel *overallTitle;
@property (nonatomic, strong) UILabel *overallLabel;

//Price
@property (nonatomic, strong) UILabel *avgPriceTitle;
@property (nonatomic, strong) UILabel *avgPriceLabel;

//Health
@property (nonatomic, strong) UILabel *healthTitle;
@property (nonatomic, strong) UILabel *healthLabel;

//Portion
//@property (nonatomic, strong) UILabel *portionTitle;
//@property (nonatomic, strong) UILabel *portionLabel;

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
    
    self.sep1 = [[UIView alloc]initWithFrame:CGRectMake(screen.size.width * 0.35, 0, 1.0, METRIC_CELL_HEIGHT)];
    self.sep1.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.sep1];
    
    self.sep2 = [[UIView alloc]initWithFrame:CGRectMake(screen.size.width * 0.65, 0, 1.0, METRIC_CELL_HEIGHT)];
    self.sep2.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.sep2];
    
    self.overallTitle = [[UILabel alloc]initWithFrame:CGRectMake((screen.size.width - CGRectGetMaxX(self.sep2.frame))/2.2 - screen.size.width * 0.075, METRIC_CELL_HEIGHT * 0.7 - METRIC_CELL_HEIGHT * 0.1, screen.size.width * 0.15, METRIC_CELL_HEIGHT * 0.3)];
    self.overallTitle.text = @"Reviews";
    self.overallTitle.backgroundColor = [UIColor clearColor];
    [self.overallTitle setFont:[UIFont systemFontOfSize:14.0]];
    [self.overallTitle setTextColor:[UIColor blackColor]];
    [self.overallTitle setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.overallTitle];
    
    self.overallLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screen.size.width * 0.2, METRIC_CELL_HEIGHT * 0.3)];
    self.overallLabel.center = CGPointMake(CGRectGetMidX(self.overallTitle.frame), CGRectGetMinY(self.overallTitle.frame) - 15.0);
    //self.overallLabel.text = [self.numReviews stringValue];
    self.overallLabel.backgroundColor = [UIColor clearColor];
    self.overallLabel.text = @"22";
    [self.overallLabel setFont:[UIFont nun_semiboldFontWithSize:18.0]];
    [self.overallLabel setTextColor:[UIColor blackColor]];
    [self.overallLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.overallLabel];
    
    self.avgPriceTitle = [[UILabel alloc]initWithFrame:CGRectMake((CGRectGetMaxX(self.sep1.frame) + CGRectGetMinX(self.sep2.frame))/2 - screen.size.width * 0.12, CGRectGetMinY(self.overallTitle.frame), screen.size.width * 0.24, METRIC_CELL_HEIGHT * 0.3)];
    self.avgPriceTitle.text = @"average price";
    self.avgPriceTitle.backgroundColor = [UIColor clearColor];
    [self.avgPriceTitle setFont:[UIFont nun_semiboldFontWithSize:METRIC_CELL_HEIGHT * 0.28]];
    [self.avgPriceTitle setTextColor:[UIColor lightGrayColor]];
    [self.avgPriceTitle setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.avgPriceTitle];
    
    self.avgPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screen.size.width * 0.2, METRIC_CELL_HEIGHT * 0.3)];
    self.avgPriceLabel.center = CGPointMake(CGRectGetMidX(self.avgPriceTitle.frame), CGRectGetMinY(self.avgPriceTitle.frame) - 15.0);
    self.avgPriceLabel.backgroundColor = [UIColor clearColor];
    self.avgPriceLabel.text = @"$9";
    [self.avgPriceLabel setFont:[UIFont nun_semiboldFontWithSize:18.0]];
    [self.avgPriceLabel setTextColor:[UIColor blackColor]];
    [self.avgPriceLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.avgPriceLabel];

    self.healthTitle = [[UILabel alloc]initWithFrame:CGRectMake(screen.size.width - CGRectGetMaxX(self.sep1.frame)/2.2 - screen.size.width * 0.075, CGRectGetMinY(self.overallTitle.frame), screen.size.width * 0.15, METRIC_CELL_HEIGHT * 0.3)];
    self.healthTitle.text = @"Health";
    self.healthTitle.backgroundColor = [UIColor clearColor];
    [self.healthTitle setFont:[UIFont nun_lightFontWithSize:18.0]];
    [self.healthTitle setTextColor:[UIColor blackColor]];
    [self.healthTitle setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.healthTitle];
    
    self.healthLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screen.size.width * 0.2, METRIC_CELL_HEIGHT * 0.3)];
    self.healthLabel.center = CGPointMake(CGRectGetMidX(self.healthTitle.frame), CGRectGetMinY(self.healthTitle.frame) - 15.0);
    self.healthLabel.backgroundColor = [UIColor clearColor];
    self.healthLabel.text = @"Healthy";
    [self.healthLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.healthLabel setTextColor:[UIColor blackColor]];
    [self.healthLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.healthLabel];
    
//    self.portionTitle = [[UILabel alloc]initWithFrame:CGRectMake(screen.size.width - CGRectGetMaxX(self.sep1.frame)/2 - screen.size.width * 0.075, CGRectGetMinY(self.overallTitle.frame), screen.size.width * 0.15, METRIC_CELL_HEIGHT * 0.2)];
//    self.portionTitle.text = @"Portion";
//    self.portionTitle.backgroundColor = [UIColor clearColor];
//    [self.portionTitle setFont:[UIFont systemFontOfSize:14.0]];
//    [self.portionTitle setTextColor:[UIColor whiteColor]];
//    [self.portionTitle setTextAlignment:NSTextAlignmentCenter];
//    [self addSubview:self.portionTitle];
//    
//    self.portionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screen.size.width * 0.2, METRIC_CELL_HEIGHT * 0.3)];
//    self.portionLabel.center = CGPointMake(CGRectGetMidX(self.portionTitle.frame), CGRectGetMinY(self.portionTitle.frame) - 15.0);
//    self.portionLabel.backgroundColor = [UIColor clearColor];
//    self.portionLabel.text = @"Stuffed";
//    [self.portionLabel setFont:[UIFont systemFontOfSize:16.0]];
//    [self.portionLabel setTextColor:[UIColor whiteColor]];
//    [self.portionLabel setTextAlignment:NSTextAlignmentCenter];
//    [self addSubview:self.portionLabel];
    
    //[LayoutBounds drawBoundsForAllLayers:self];
}

@end
