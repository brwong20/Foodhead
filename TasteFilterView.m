//
//  TasteFilterView.m
//  FoodWise
//
//  Created by Brian Wong on 2/7/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TasteFilterView.h"
#import "UIFont+Extension.h"

@interface TasteFilterView ()

@property (nonatomic, strong) NSNumber *overallRating;
@property (nonatomic, strong) UILabel *overallTitle;
@property (nonatomic, strong) UIImageView *sepLine;

@property (nonatomic, strong) UIButton *taste1;
@property (nonatomic, strong) UIButton *taste2;
@property (nonatomic, strong) UIButton *taste3;
@property (nonatomic, strong) UIButton *taste4;
@property (nonatomic, strong) UIButton *taste5;
@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation TasteFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.overallTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.width * 0.2, self.frame.size.height - self.frame.size.height * 0.25, self.frame.size.width * 0.4, self.frame.size.height * 0.05)];
        self.overallTitle.backgroundColor = [UIColor clearColor];
        self.overallTitle.textAlignment = NSTextAlignmentCenter;
        self.overallTitle.font = [UIFont nun_boldFontWithSize:frame.size.height * 0.04];
        self.overallTitle.text = @"Overall";
        self.overallTitle.textColor = [UIColor whiteColor];
        self.overallTitle.layer.shadowOffset = CGSizeMake(0, 0);
        self.overallTitle.layer.shadowOpacity = 1.0;
        self.overallTitle.layer.shadowRadius = 10.0f;
        [self addSubview:self.overallTitle];
//        
//        self.sepLine = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.width * 0.43, CGRectGetMinY(self.overallTitle.frame) - self.frame.size.height * 0.02, self.frame.size.width * 0.86, 5.0)];
//        self.sepLine.backgroundColor = [UIColor clearColor];
//        [self.sepLine setImage:[UIImage imageNamed:@"separate_line"]];
//        [self addSubview:self.sepLine];
        
        self.taste3 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.overallTitle.frame) - self.frame.size.width * 0.07, CGRectGetMaxY(self.overallTitle.frame) + self.frame.size.width * 0.08, self.frame.size.width * 0.14, self.frame.size.width * 0.14)];
        self.taste3.adjustsImageWhenHighlighted = NO;
        self.taste3.backgroundColor = [UIColor clearColor];
        [self.taste3 setImage:[UIImage imageNamed:@"overall_flow_empty"] forState:UIControlStateNormal];
        [self.taste3 addTarget:self action:@selector(didSelectTasteRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.taste3];
        
        self.taste2 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.taste3.frame) - self.frame.size.width * 0.17, CGRectGetMaxY(self.overallTitle.frame) + self.frame.size.width * 0.08, self.frame.size.width * 0.14, self.frame.size.width * 0.14)];
        self.taste2.backgroundColor = [UIColor clearColor];
        self.taste2.adjustsImageWhenHighlighted = NO;
        [self.taste2 setImage:[UIImage imageNamed:@"overall_flow_empty"] forState:UIControlStateNormal];
        [self.taste2 addTarget:self action:@selector(didSelectTasteRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.taste2];
        
        self.taste1 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.taste2.frame) - self.frame.size.width * 0.17, CGRectGetMaxY(self.overallTitle.frame) + self.frame.size.width * 0.08, self.frame.size.width * 0.14, self.frame.size.width * 0.14)];
        self.taste1.adjustsImageWhenHighlighted = NO;
        self.taste1.backgroundColor = [UIColor clearColor];
        [self.taste1 setImage:[UIImage imageNamed:@"overall_flow_empty"] forState:UIControlStateNormal];
        [self.taste1 addTarget:self action:@selector(didSelectTasteRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.taste1];
        
        self.taste4 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.taste3.frame) + self.frame.size.width * 0.03, CGRectGetMaxY(self.overallTitle.frame) + self.frame.size.width * 0.08, self.frame.size.width * 0.14, self.frame.size.width * 0.14)];
        self.taste4.adjustsImageWhenHighlighted = NO;
        self.taste4.backgroundColor = [UIColor clearColor];
        [self.taste4 setImage:[UIImage imageNamed:@"overall_flow_empty"] forState:UIControlStateNormal];
        [self.taste4 addTarget:self action:@selector(didSelectTasteRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.taste4];
        
        self.taste5 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.taste4.frame) + self.frame.size.width * 0.03, CGRectGetMaxY(self.overallTitle.frame) + self.frame.size.width * 0.08, self.frame.size.width * 0.14, self.frame.size.width * 0.14)];
        self.taste5.adjustsImageWhenHighlighted = NO;
        self.taste5.backgroundColor = [UIColor clearColor];
        [self.taste5 setImage:[UIImage imageNamed:@"overall_flow_empty"] forState:UIControlStateNormal];
        [self.taste5 addTarget:self action:@selector(didSelectTasteRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.taste5];
        
        self.buttonArray = [NSMutableArray array];
        [self.buttonArray addObject:self.taste1];
        [self.buttonArray addObject:self.taste2];
        [self.buttonArray addObject:self.taste3];
        [self.buttonArray addObject:self.taste4];
        [self.buttonArray addObject:self.taste5];
    }
    return self;
}

- (void)didSelectTasteRating:(UIButton *)ratingButton{
    BOOL shouldEmpty = NO;
    
    if ([ratingButton isEqual:self.taste1]) {
        if ([self.overallRating isEqualToNumber:@(1)]) {
            shouldEmpty = YES;
        }else{
            self.overallRating = @(1);
        }
    }else if ([ratingButton isEqual:self.taste2]){
        if ([self.overallRating isEqualToNumber:@(2)]) {
            shouldEmpty = YES;
        }else{
            self.overallRating = @(2);
        }
    }else if ([ratingButton isEqual:self.taste3]){
        if ([self.overallRating isEqualToNumber:@(3)]) {
            shouldEmpty = YES;
        }else{
            self.overallRating = @(3);
        }
    }else if ([ratingButton isEqual:self.taste4]){
        if ([self.overallRating isEqualToNumber:@(4)]) {
            shouldEmpty = YES;
        }else{
            self.overallRating = @(4);
        }
    }else{
        if ([self.overallRating isEqualToNumber:@(5)]) {
            shouldEmpty = YES;
        }else{
            self.overallRating = @(5);
        }
    }
    
    if (shouldEmpty) {
        [self removeAllRatings];
        self.overallRating = nil;
    }else{
        [self highlightButtonsUpTo:self.overallRating.integerValue];
    }
    
    [self.delegate didRateOverall:self.overallRating];
}

- (void)highlightButtonsUpTo:(NSUInteger)num{
    //Reset all colors first
    for (UIButton *tasteButton in self.buttonArray) {
        [tasteButton setImage:[UIImage imageNamed:@"overall_flow_empty"] forState:UIControlStateNormal];
    }
    
    //Fill based on rating
    for (int i = 0; i < num; ++i) {
        UIButton *tasteButton = self.buttonArray[i];
        [tasteButton setImage:[UIImage imageNamed:@"overall_flow"] forState:UIControlStateNormal];
    }
}

- (void)removeAllRatings{
    for (UIButton *tasteButton in self.buttonArray) {
        [tasteButton setImage:[UIImage imageNamed:@"overall_flow_empty"] forState:UIControlStateNormal];
    }
}

@end
