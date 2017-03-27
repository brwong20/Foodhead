//
//  HealthRatingView.m
//  Foodhead
//
//  Created by Brian Wong on 3/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "HealthRatingView.h"

#define NUM_HEALTH 4

@interface HealthRatingView ()

@property (nonatomic, strong) NSMutableArray *healthArr;
@property (nonatomic, strong) UIImageView *health1;
@property (nonatomic, strong) UIImageView *health2;
@property (nonatomic, strong) UIImageView *health3;
@property (nonatomic, strong) UIImageView *health4;

@end

@implementation HealthRatingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI:frame];
    }
    return self;
}

- (void)setupUI:(CGRect)frame{
    self.health2 = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.225, frame.size.height/2 - frame.size.width * 0.11, frame.size.width * 0.22, frame.size.width * 0.22)];
    self.health2.backgroundColor = [UIColor clearColor];
    [self addSubview:self.health2];
    
    self.health3 = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 + frame.size.width * 0.005, frame.size.height/2 - frame.size.width * 0.11, frame.size.width * 0.22, frame.size.width * 0.22)];
    self.health3.backgroundColor = [UIColor clearColor];
    [self addSubview:self.health3];
    
    self.health1 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.health2.frame) - frame.size.width * 0.23, frame.size.height/2 - frame.size.width * 0.11, frame.size.width * 0.22, frame.size.width * 0.22)];
    self.health1.backgroundColor = [UIColor clearColor];
    [self addSubview:self.health1];
    
    self.health4 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.health3.frame) + frame.size.width * 0.01, frame.size.height/2 - frame.size.width * 0.11, frame.size.width * 0.22, frame.size.width * 0.22)];
    self.health4.backgroundColor = [UIColor clearColor];
    [self addSubview:self.health4];
    
    self.healthArr = [NSMutableArray array];
    [self.healthArr addObject:self.health1];
    [self.healthArr addObject:self.health2];
    [self.healthArr addObject:self.health3];
    [self.healthArr addObject:self.health4];
}

- (void)setHealth:(NSNumber *)healthiness{
    for (UIImageView *healthImg in self.healthArr) {
        [healthImg setImage:nil];
    }
    
    //Fill based on rating
    for (int i = 0; i < [healthiness integerValue]; ++i) {
        UIImageView *healthImg = self.healthArr[i];
        [healthImg setImage:[UIImage imageNamed:@"apple_flow"]];
    }
}

@end
