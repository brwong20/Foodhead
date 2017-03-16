//
//  MetricsDisplayCell.m
//  FoodWise
//
//  Created by Brian Wong on 2/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "MetricsDisplayCell.h"
#import "FoodWiseDefines.h"

@interface MetricsDisplayCell()

//Separators
@property (nonatomic, strong) UIView *sep1;
@property (nonatomic, strong) UIView *sep2;
@property (nonatomic, strong) UIView *sep3;

//Reviews
@property (nonatomic, strong) UILabel *numReviewsTitle;
@property (nonatomic, strong) UILabel *numReviewsLabel;

//Price
@property (nonatomic, strong) UILabel *avgPriceTitle;
@property (nonatomic, strong) UILabel *avgPriceLabel;

//Health
@property (nonatomic, strong) UILabel *healthTitle;
@property (nonatomic, strong) UILabel *healthLabel;

//Portion
@property (nonatomic, strong) UILabel *portionTitle;
@property (nonatomic, strong) UILabel *portionLabel;

@end

@implementation MetricsDisplayCell

#define SEPARATOR_PADDING 10.0

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    CGRect screen = [[UIScreen mainScreen]bounds];
    
    //TODO: Setup separators first then center each label in between
    self.sep1 = [[UIView alloc]initWithFrame:CGRectMake(screen.size.width * 0.22, METRIC_CELL_HEIGHT/4, 1.0, METRIC_CELL_HEIGHT/2)];
    self.sep1.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.sep1];
    
    self.sep2 = [[UIView alloc]initWithFrame:CGRectMake(screen.size.width * 0.5, METRIC_CELL_HEIGHT/4, 1.0, METRIC_CELL_HEIGHT/2)];
    self.sep2.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.sep2];
    
    self.sep3 = [[UIView alloc]initWithFrame:CGRectMake(screen.size.width * 0.77, METRIC_CELL_HEIGHT/4, 1.0, METRIC_CELL_HEIGHT/2)];
    self.sep3.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.sep3];
    
    self.backgroundColor = [UIColor blackColor];
    
    self.numReviewsTitle = [[UILabel alloc]initWithFrame:CGRectMake((screen.size.width - CGRectGetMaxX(self.sep3.frame))/2 - screen.size.width * 0.075, METRIC_CELL_HEIGHT * 0.7 - METRIC_CELL_HEIGHT * 0.1, screen.size.width * 0.15, METRIC_CELL_HEIGHT * 0.2)];
    self.numReviewsTitle.text = @"Reviews";
    self.numReviewsTitle.backgroundColor = [UIColor clearColor];
    [self.numReviewsTitle setFont:[UIFont systemFontOfSize:14.0]];
    [self.numReviewsTitle setTextColor:[UIColor whiteColor]];
    [self.numReviewsTitle setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.numReviewsTitle];
    
    self.numReviewsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screen.size.width * 0.2, METRIC_CELL_HEIGHT * 0.3)];
    self.numReviewsLabel.center = CGPointMake(CGRectGetMidX(self.numReviewsTitle.frame), CGRectGetMinY(self.numReviewsTitle.frame) - 15.0);
    //self.numReviewsLabel.text = [self.numReviews stringValue];
    self.numReviewsLabel.backgroundColor = [UIColor clearColor];
    self.numReviewsLabel.text = @"22";
    [self.numReviewsLabel setFont:[UIFont systemFontOfSize:18.0]];
    [self.numReviewsLabel setTextColor:[UIColor whiteColor]];
    [self.numReviewsLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.numReviewsLabel];
    
    self.avgPriceTitle = [[UILabel alloc]initWithFrame:CGRectMake((CGRectGetMaxX(self.sep1.frame) + CGRectGetMinX(self.sep2.frame))/2 - screen.size.width * 0.075, CGRectGetMinY(self.numReviewsTitle.frame), screen.size.width * 0.15, METRIC_CELL_HEIGHT * 0.2)];
    self.avgPriceTitle.text = @"Price";
    self.avgPriceTitle.backgroundColor = [UIColor clearColor];
    [self.avgPriceTitle setFont:[UIFont systemFontOfSize:14.0]];
    [self.avgPriceTitle setTextColor:[UIColor whiteColor]];
    [self.avgPriceTitle setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.avgPriceTitle];
    
    self.avgPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screen.size.width * 0.2, METRIC_CELL_HEIGHT * 0.3)];
    self.avgPriceLabel.center = CGPointMake(CGRectGetMidX(self.avgPriceTitle.frame), CGRectGetMinY(self.avgPriceTitle.frame) - 15.0);
    //self.avgPriceLabel.text = [self.avgPrice stringValue];
    self.avgPriceLabel.backgroundColor = [UIColor clearColor];
    self.avgPriceLabel.text = @"$9";
    [self.avgPriceLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.avgPriceLabel setTextColor:[UIColor whiteColor]];
    [self.avgPriceLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.avgPriceLabel];

    
    self.healthTitle = [[UILabel alloc]initWithFrame:CGRectMake((CGRectGetMaxX(self.sep2.frame) + CGRectGetMinX(self.sep3.frame))/2 - screen.size.width * 0.075, CGRectGetMinY(self.numReviewsTitle.frame), screen.size.width * 0.15, METRIC_CELL_HEIGHT * 0.2)];
    self.healthTitle.text = @"Health";
    self.healthTitle.backgroundColor = [UIColor clearColor];
    [self.healthTitle setFont:[UIFont systemFontOfSize:14.0]];
    [self.healthTitle setTextColor:[UIColor whiteColor]];
    [self.healthTitle setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.healthTitle];
    
    self.healthLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screen.size.width * 0.2, METRIC_CELL_HEIGHT * 0.3)];
    self.healthLabel.center = CGPointMake(CGRectGetMidX(self.healthTitle.frame), CGRectGetMinY(self.healthTitle.frame) - 15.0);
    self.healthLabel.backgroundColor = [UIColor clearColor];
    self.healthLabel.text = @"Healthy";//Make jokes about this? (Cheat Meal, Might wanna reconsider fatass!!!)
    [self.healthLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.healthLabel setTextColor:[UIColor whiteColor]];
    [self.healthLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.healthLabel];
    
    self.portionTitle = [[UILabel alloc]initWithFrame:CGRectMake(screen.size.width - CGRectGetMaxX(self.sep1.frame)/2 - screen.size.width * 0.075, CGRectGetMinY(self.numReviewsTitle.frame), screen.size.width * 0.15, METRIC_CELL_HEIGHT * 0.2)];
    self.portionTitle.text = @"Portion";
    self.portionTitle.backgroundColor = [UIColor clearColor];
    [self.portionTitle setFont:[UIFont systemFontOfSize:14.0]];
    [self.portionTitle setTextColor:[UIColor whiteColor]];
    [self.portionTitle setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.portionTitle];
    
    self.portionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screen.size.width * 0.2, METRIC_CELL_HEIGHT * 0.3)];
    self.portionLabel.center = CGPointMake(CGRectGetMidX(self.portionTitle.frame), CGRectGetMinY(self.portionTitle.frame) - 15.0);
    self.portionLabel.backgroundColor = [UIColor clearColor];
    self.portionLabel.text = @"Stuffed";
    [self.portionLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.portionLabel setTextColor:[UIColor whiteColor]];
    [self.portionLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.portionLabel];
}

@end
