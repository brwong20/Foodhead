//
//  OverallRatingView.m
//  Foodhead
//
//  Created by Brian Wong on 3/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "OverallRatingView.h"

@interface OverallRatingView()

@property (nonatomic, strong) UIImageView *overall1;
@property (nonatomic, strong) UIImageView *overall2;
@property (nonatomic, strong) UIImageView *overall3;
@property (nonatomic, strong) UIImageView *overall4;
@property (nonatomic, strong) UIImageView *overall5;
@property (nonatomic, strong) NSMutableArray *overallArr;

@end


@implementation OverallRatingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI:frame];
    }
    return self;
}

- (void)setupUI:(CGRect)frame{
    self.overall3 = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.width * 0.09, frame.size.height /2 - frame.size.width * 0.09, frame.size.width * 0.18, frame.size.width * 0.18)];
    self.overall3.contentMode = UIViewContentModeScaleAspectFit;
    self.overall3.backgroundColor = [UIColor clearColor];
    [self addSubview:self.overall3];
    
    self.overall2 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.overall3.frame) - self.frame.size.width * 0.18, frame.size.height /2 - frame.size.width * 0.09, frame.size.width * 0.18, frame.size.width * 0.18)];
    self.overall2.contentMode = UIViewContentModeScaleAspectFit;
    self.overall2.backgroundColor = [UIColor clearColor];
    [self addSubview:self.overall2];
    
    self.overall1 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.overall2.frame) - self.frame.size.width * 0.18, frame.size.height /2 - frame.size.width * 0.09, frame.size.width * 0.18, frame.size.width * 0.18)];
    self.overall1.contentMode = UIViewContentModeScaleAspectFit;
    self.overall1.backgroundColor = [UIColor clearColor];
    [self addSubview:self.overall1];
    
    self.overall4 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.overall3.frame), frame.size.height /2 - frame.size.width * 0.09, frame.size.width * 0.18, frame.size.width * 0.18)];
    self.overall4.contentMode = UIViewContentModeScaleAspectFit;
    self.overall4.backgroundColor = [UIColor clearColor];
    [self addSubview:self.overall4];
    
    self.overall5 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.overall4.frame), frame.size.height /2 - frame.size.width * 0.09, frame.size.width * 0.18, frame.size.width * 0.18)];
    self.overall5.contentMode = UIViewContentModeScaleAspectFit;
    self.overall5.backgroundColor = [UIColor clearColor];
    [self addSubview:self.overall5];
    
    self.overallArr = [NSMutableArray array];
    [self.overallArr addObject:self.overall1];
    [self.overallArr addObject:self.overall2];
    [self.overallArr addObject:self.overall3];
    [self.overallArr addObject:self.overall4];
    [self.overallArr addObject:self.overall5];
}

- (void)setOverall:(NSNumber *)overall{
    for (UIImageView *overallImg in self.overallArr) {
        [overallImg setImage:nil];
    }
    
    //Fill based on rating
    for (int i = 0; i < [overall integerValue]; ++i) {
        UIImageView *overallImg = self.overallArr[i];
        [overallImg setImage:[UIImage imageNamed:@"overall_flow"]];
    }
}

@end
