//
//  RatingContainerView.m
//  Foodhead
//
//  Created by Brian Wong on 3/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RatingContainerView.h"
#import "HealthRatingView.h"
#import "PriceRatingView.h"
#import "OverallRatingView.h"
#import "LayoutBounds.h"

@interface RatingContainerView ()

@property (nonatomic, strong) HealthRatingView *healthView;
@property (nonatomic, strong) PriceRatingView *priceView;
@property (nonatomic, strong) OverallRatingView *overallView;

@end

@implementation RatingContainerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadRatings:frame];
    }
    return self;
}

- (void)loadRatings:(CGRect)frame{
    self.overallView = [[OverallRatingView alloc]initWithFrame:CGRectMake(frame.size.width * 0.01, frame.size.height/2 - frame.size.height * 0.45, frame.size.width * 0.35, frame.size.height * 0.9)];
    
    self.healthView = [[HealthRatingView alloc]initWithFrame:CGRectMake(frame.size.width * 0.69, frame.size.height/2 - frame.size.height * 0.45, frame.size.width * 0.3, frame.size.height * 0.9)];
    
    self.priceView = [[PriceRatingView alloc]initWithFrame:CGRectMake((CGRectGetMaxX(self.overallView.frame) + CGRectGetMinX(self.healthView.frame))/2 - frame.size.width * 0.13, CGRectGetMidY(self.overallView.frame) - frame.size.height * 0.45, frame.size.width * 0.26, frame.size.height * 0.9)];
    
    [self addSubview:self.priceView];
    [self addSubview:self.overallView];
    [self addSubview:self.healthView];
    
    //[LayoutBounds drawBoundsForAllLayers:self];
}

- (void)setOverall:(NSNumber *)overall{
    [self.overallView setOverall:overall];
}

- (void)setPrice:(NSNumber *)price{
    [self.priceView setPrice:price];
}

- (void)setHealth:(NSNumber *)healthiness{
    [self.healthView setHealth:healthiness];
}

@end
