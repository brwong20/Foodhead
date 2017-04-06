//
//  TPLChartSectionView.m
//  FoodWise
//
//  Created by Brian Wong on 2/14/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartSectionView.h"
#import "UIFont+Extension.h"
#import "FoodWiseDefines.h"
#import "LayoutBounds.h"

@interface TPLChartSectionView ()


@end

@implementation TPLChartSectionView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(((APPLICATION_FRAME.size.width * CHART_PADDING_PERCENTAGE)) + 3.0, frame.size.height * 0.3, frame.size.width * 0.8, frame.size.height * 0.6)];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont nun_boldFontWithSize:frame.size.height * 0.45];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
//        self.arrowButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.9, CGRectGetMidY(self.titleLabel.frame) - frame.size.height * 0.2, frame.size.width * 0.06, frame.size.height * 0.4)];
//        self.arrowButton.backgroundColor = [UIColor clearColor];
//        self.arrowButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        [self.arrowButton setTitle:@"all" forState:UIControlStateNormal];
//        self.arrowButton.titleLabel.textColor = UIColorFromRGB(0xA4AAB4);
//        self.arrowButton.titleLabel.font = [UIFont nun_fontWithSize:frame.size.height * 0.3];
//        [self.arrowButton setTitleColor:UIColorFromRGB(0xA4AAB4) forState:UIControlStateNormal];
//        [self.arrowButton addTarget:self action:@selector(sectionSelected:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:self.arrowButton];
//        
//        self.arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.arrowButton.frame), CGRectGetMidY(self.arrowButton.frame) - frame.size.height * 0.1, frame.size.width * 0.03, frame.size.height * 0.2)];
//        self.arrowImg.backgroundColor = [UIColor clearColor];
//        self.arrowImg.contentMode = UIViewContentModeScaleAspectFit;
//        [self.arrowImg setImage:[UIImage imageNamed:@"arrow_right"]];
//        [self addSubview:self.arrowImg];        
    }
    return self;
}

- (void)sectionSelected:(id)sender{
    if ([self.delegate respondsToSelector:@selector(didSelectSection:)]) {
        [self.delegate didSelectSection:self.section];
    }
}

@end
