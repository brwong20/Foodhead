//
//  OverallRatingView.m
//  Foodhead
//
//  Created by Brian Wong on 3/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "OverallRatingView.h"
#import "LayoutBounds.h"

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
    self.overall3 = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.width * 0.085, frame.size.height /2 - frame.size.height * 0.375, frame.size.width * 0.17, frame.size.height * 0.75)];
    self.overall3.contentMode = UIViewContentModeScaleAspectFit;
    self.overall3.backgroundColor = [UIColor clearColor];
    self.overall3.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.overall3.layer.shouldRasterize = YES;
    [self addSubview:self.overall3];
    
    self.overall2 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.overall3.frame) - self.frame.size.width * 0.2, frame.size.height /2 - frame.size.height * 0.375, frame.size.width * 0.17, frame.size.height * 0.75)];
    self.overall2.contentMode = UIViewContentModeScaleAspectFit;
    self.overall2.backgroundColor = [UIColor clearColor];
    self.overall3.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.overall3.layer.shouldRasterize = YES;
    [self addSubview:self.overall2];
    
    self.overall1 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.overall2.frame) - self.frame.size.width * 0.2, frame.size.height /2 - frame.size.height * 0.375, frame.size.width * 0.17, frame.size.height * 0.75)];
    self.overall1.contentMode = UIViewContentModeScaleAspectFit;
    self.overall1.backgroundColor = [UIColor clearColor];
    self.overall1.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.overall1.layer.shouldRasterize = YES;
    [self addSubview:self.overall1];
    
    self.overall4 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.overall3.frame) + self.frame.size.width * 0.03, frame.size.height /2 - frame.size.height * 0.375, frame.size.width * 0.17, frame.size.height * 0.75)];
    self.overall4.contentMode = UIViewContentModeScaleAspectFit;
    self.overall4.backgroundColor = [UIColor clearColor];
    self.overall4.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.overall4.layer.shouldRasterize = YES;
    [self addSubview:self.overall4];
    
    self.overall5 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.overall4.frame) + self.frame.size.width * 0.03, frame.size.height /2 - frame.size.height * 0.375, frame.size.width * 0.17, frame.size.height * 0.75)];
    self.overall5.contentMode = UIViewContentModeScaleAspectFit;
    self.overall5.backgroundColor = [UIColor clearColor];
    self.overall5.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.overall5.layer.shouldRasterize = YES;
    [self addSubview:self.overall5];
    
    self.overallArr = [NSMutableArray array];
    [self.overallArr addObject:self.overall1];
    [self.overallArr addObject:self.overall2];
    [self.overallArr addObject:self.overall3];
    [self.overallArr addObject:self.overall4];
    [self.overallArr addObject:self.overall5];
    
}

- (void)setOverall:(NSNumber *)overall inReviewFlow:(BOOL)reviewFlow{
    if (!overall) {
        for (UIImageView *overallImg in self.overallArr) {
            [overallImg setImage:nil];
        }
        return;
    }
    
 
    for (UIImageView *overallImg in self.overallArr) {
        if (reviewFlow) {
            [overallImg setImage:nil];
        }else{
            [overallImg setImage:[UIImage imageNamed:@"overall_empty_page"]];
        }
    }
    
    NSInteger numFull = overall.integerValue;
    double decimal = overall.doubleValue - numFull;
    
    //Fill full hearts first then add a half based on decimal.
    for (int i = 0; i < numFull; ++i) {
        UIImageView *overallImg = self.overallArr[i];
        [overallImg setImage:[UIImage imageNamed:@"overall_flow"]];
    }
    
    if (decimal == 0.5) {
        UIImageView *halfView = self.overallArr[numFull];
        [halfView setImage:[UIImage imageNamed:@"overall_half"]];
    }
    
}

@end
