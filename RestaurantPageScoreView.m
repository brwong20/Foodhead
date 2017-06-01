//
//  RestaurantPageScoreView.m
//  Foodhead
//
//  Created by Brian Wong on 5/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RestaurantPageScoreView.h"
#import "UIFont+Extension.h"
#import "FoodWiseDefines.h"
#import "LayoutBounds.h"

@implementation RestaurantPageScoreView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.2, self.frame.size.height * 0.2, self.frame.size.width * 0.18, self.frame.size.height * 0.6)];
        self.scoreLabel.backgroundColor = [UIColor clearColor];
        self.scoreLabel.font = [UIFont nun_mediumFontWithSize:APPLICATION_FRAME.size.width * 0.08];
        self.scoreLabel.textColor = APPLICATION_BLUE_COLOR;
        self.scoreLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.scoreLabel];
        
        self.scoreImage = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 + frame.size.width * 0.06, CGRectGetMidY(self.scoreLabel.frame) - frame.size.width * 0.06, frame.size.width * 0.11, frame.size.width * 0.08)];
        self.scoreImage.backgroundColor = [UIColor clearColor];
        //self.scoreImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.scoreImage setImage:[UIImage imageNamed:@"hootscore_icon"]];
        [self addSubview:self.scoreImage];
        
        self.scoreCaption = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.scoreImage.frame) - frame.size.width * 0.13, CGRectGetMaxY(self.scoreImage.frame) + 1.0, frame.size.width * 0.26, frame.size.height * 0.2)];
        self.scoreCaption.backgroundColor = [UIColor clearColor];
        self.scoreCaption.textAlignment = NSTextAlignmentCenter;
        self.scoreCaption.text = @"hootscore";
        self.scoreCaption.font = [UIFont nun_fontWithSize:REST_PAGE_HEADER_FONT_SIZE];
        self.scoreCaption.textColor = UIColorFromRGB(0x505254);
        [self addSubview:self.scoreCaption];        
    }
    return self;
}

@end
