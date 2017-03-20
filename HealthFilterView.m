//
//  HealthFilterView.m
//  Foodhead
//
//  Created by Brian Wong on 3/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "HealthFilterView.h"
#import "UIFont+Extension.h"

@interface HealthFilterView ()

@property (nonatomic, strong) UILabel *healthTitle;
@property (nonatomic, strong) UIImageView *sepLine;

@property (nonatomic, strong) NSNumber *healthiness;
@property (nonatomic, strong) UIView *tasteView;

@property (nonatomic, strong) UIButton *health1;
@property (nonatomic, strong) UIButton *health2;
@property (nonatomic, strong) UIButton *health3;
@property (nonatomic, strong) UIButton *health4;
@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation HealthFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.healthTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.width * 0.2, self.frame.size.height - self.frame.size.height * 0.07, self.frame.size.width * 0.4, self.frame.size.height * 0.05)];
        self.healthTitle.backgroundColor = [UIColor clearColor];
        self.healthTitle.textAlignment = NSTextAlignmentCenter;
        self.healthTitle.font = [UIFont nun_lightFontWithSize:frame.size.height * 0.04];
        self.healthTitle.text = @"Healthiness";
        self.healthTitle.textColor = [UIColor whiteColor];
        [self addSubview:self.healthTitle];
        
        self.sepLine = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.width * 0.43, CGRectGetMinY(self.healthTitle.frame) - self.frame.size.height * 0.02, self.frame.size.width * 0.86, 5.0)];
        self.sepLine.backgroundColor = [UIColor clearColor];
        [self.sepLine setImage:[UIImage imageNamed:@"separate_line"]];
        [self addSubview:self.sepLine];
        
        self.health2 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.14, frame.size.height * 0.8, frame.size.width * 0.14, frame.size.width * 0.14)];
        self.health2.backgroundColor = [UIColor clearColor];
        self.health2.adjustsImageWhenHighlighted = NO;
        [self.health2 setImage:[UIImage imageNamed:@"apple_flow_empty"] forState:UIControlStateNormal];
        [self.health2 addTarget:self action:@selector(didSelectHealthRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.health2];
        
        self.health3 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2, frame.size.height * 0.8, frame.size.width * 0.14, frame.size.width * 0.14)];
        self.health3.backgroundColor = [UIColor clearColor];
        self.health3.adjustsImageWhenHighlighted = NO;
        [self.health3 setImage:[UIImage imageNamed:@"apple_flow_empty"] forState:UIControlStateNormal];
        [self.health3 addTarget:self action:@selector(didSelectHealthRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.health3];
        
        self.health1 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.health2.frame) - frame.size.width * 0.14, frame.size.height * 0.8, frame.size.width * 0.14, frame.size.width * 0.14)];
        self.health1.backgroundColor = [UIColor clearColor];
        self.health1.adjustsImageWhenHighlighted = NO;
        [self.health1 setImage:[UIImage imageNamed:@"apple_flow_empty"] forState:UIControlStateNormal];
        [self.health1 addTarget:self action:@selector(didSelectHealthRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.health1];
        
        self.health4 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.health3.frame), frame.size.height * 0.8, frame.size.width * 0.14, frame.size.width * 0.14)];
        self.health4.backgroundColor = [UIColor clearColor];
        self.health4.adjustsImageWhenHighlighted = NO;
        [self.health4 setImage:[UIImage imageNamed:@"apple_flow_empty"] forState:UIControlStateNormal];
        [self.health4 addTarget:self action:@selector(didSelectHealthRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.health4];
        
        self.buttonArray = [NSMutableArray array];
        [self.buttonArray addObject:self.health1];
        [self.buttonArray addObject:self.health2];
        [self.buttonArray addObject:self.health3];
        [self.buttonArray addObject:self.health4];
    }
    return self;
}

- (void)didSelectHealthRating:(UIButton *)ratingButton{
    BOOL shouldEmpty = NO;
    if ([ratingButton isEqual:self.health1]) {
        if ([self.healthiness isEqual: @(1)] ) {
            shouldEmpty = YES;
        }else{
            self.healthiness = @(1);
        }
    }else if ([ratingButton isEqual:self.health2]){
        if ([self.healthiness isEqual: @(2)] ) {
            shouldEmpty = YES;
        }else{
            self.healthiness = @(2);
        }
    }else if ([ratingButton isEqual:self.health3]){
        if ([self.healthiness isEqual: @(3)] ) {
            shouldEmpty = YES;
        }else{
            self.healthiness = @(3);
        }
    }else if ([ratingButton isEqual:self.health4]){
        if ([self.healthiness isEqual: @(4)] ) {
            shouldEmpty = YES;
        }else{
            self.healthiness = @(4);
        }
    }
    
    if (shouldEmpty) {
        [self removeAllRatings];
        self.healthiness = nil;
    }else{
        [self highlightButtonsUpTo:[self.buttonArray indexOfObject:ratingButton] + 1];
    }
    [self.delegate didRateHealth:self.healthiness];
}

- (void)setHealth:(NSNumber *)healthiness{
    [self highlightButtonsUpTo:[healthiness integerValue]];
}

- (void)highlightButtonsUpTo:(NSUInteger)num{
    //Reset all colors first
    [self removeAllRatings];
    
    //Fill based on rating
    for (int i = 0; i < num; ++i) {
        UIButton *tasteButton = self.buttonArray[i];
        [tasteButton setImage:[UIImage imageNamed:@"apple_flow"] forState:UIControlStateNormal];
    }
}

- (void)removeAllRatings{
    for (UIButton *tasteButton in self.buttonArray) {
        [tasteButton setImage:[UIImage imageNamed:@"apple_flow_empty"] forState:UIControlStateNormal];
    }
}




@end
