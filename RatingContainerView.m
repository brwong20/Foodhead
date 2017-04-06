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

@property (nonatomic, strong) UIImageView *gradientBackground;
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
    self.gradientBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.gradientBackground.backgroundColor = [UIColor clearColor];
    [self.gradientBackground setImage:[UIImage imageNamed:@"rating_gradient"]];
    [self addSubview:self.gradientBackground];
    
    self.overallView = [[OverallRatingView alloc]initWithFrame:CGRectMake(frame.size.width * 0.01, frame.size.height/2 - frame.size.height * 0.45, frame.size.width * 0.35, frame.size.height * 0.9)];
    
    self.healthView = [[HealthRatingView alloc]initWithFrame:CGRectMake(frame.size.width * 0.69, frame.size.height/2 - frame.size.height * 0.35, frame.size.width * 0.3, frame.size.height * 0.7)];
    
    self.priceView = [[PriceRatingView alloc]initWithFrame:CGRectMake((CGRectGetMaxX(self.overallView.frame) + CGRectGetMinX(self.healthView.frame))/2 - frame.size.width * 0.13, CGRectGetMidY(self.overallView.frame) - frame.size.height * 0.45, frame.size.width * 0.26, frame.size.height * 0.9)];
    
    [self addSubview:self.priceView];
    [self addSubview:self.overallView];
    [self addSubview:self.healthView];
}

- (void)setOverall:(NSNumber *)overall{
    [self.overallView setOverall:overall inReviewFlow:YES];
}

- (void)setPrice:(NSNumber *)price{
    [self.priceView setPrice:price];
}

- (void)setHealth:(NSNumber *)healthiness{
    [self.healthView setHealth:healthiness inReviewFlow:YES];
}

//Eventually fade this in when user taps on a metric?
- (void)showGradient:(BOOL)gradient{
    if (gradient) {
        [self.gradientBackground setImage:[UIImage imageNamed:@"rating_gradient"]];
    }else{
        [self.gradientBackground setImage:nil];
    }
}

@end
