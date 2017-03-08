//
//  TPLChartSectionView.m
//  FoodWise
//
//  Created by Brian Wong on 2/14/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartSectionView.h"
@interface TPLChartSectionView ()

@property (nonatomic, strong) UIButton *arrowButton;

@end

@implementation TPLChartSectionView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width * 0.03, 0, frame.size.width * 0.8, frame.size.height)];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:frame.size.height * 0.5];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
        self.arrowButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.9, 0, frame.size.width * 0.1, frame.size.height)];
        self.arrowButton.backgroundColor = [UIColor clearColor];
        [self.arrowButton setImage:[[UIImage imageNamed:@"arrow"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.arrowButton addTarget:self action:@selector(sectionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.arrowButton];
    }
    return self;
}

- (void)sectionSelected:(id)sender{
    if ([self.delegate respondsToSelector:@selector(didSelectSection:)]) {
        [self.delegate didSelectSection:self.section];
    }
}

@end
