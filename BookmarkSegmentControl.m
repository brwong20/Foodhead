
//
//  BookmarkSegmentControl.m
//  Foodhead
//
//  Created by Brian Wong on 5/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "BookmarkSegmentControl.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"

@interface BookmarkSegmentControl()

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation BookmarkSegmentControl

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xECECEC);
        self.layer.cornerRadius = 8.0;
        self.clipsToBounds = YES;
        
        self.leftButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width * 0.005, self.frame.size.height/2 - self.frame.size.height * 0.45, self.frame.size.width * 0.49, self.frame.size.height * 0.9)];
        self.leftButton.backgroundColor = [UIColor whiteColor];
        [self.leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.leftButton.titleLabel setFont:[UIFont nun_fontWithSize:REST_PAGE_HEADER_FONT_SIZE]];
        [self.leftButton setTitle:@"Restaurants" forState:UIControlStateNormal];
        self.leftButton.layer.cornerRadius = 8.0;
        [self.leftButton addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftButton];
        
        self.rightButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.width * 0.495, self.frame.size.height/2 - self.frame.size.height * 0.45, self.frame.size.width * 0.49, self.frame.size.height * 0.9)];
        self.rightButton.backgroundColor = [UIColor clearColor];
        [self.rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.rightButton.titleLabel setFont:[UIFont nun_fontWithSize:REST_PAGE_HEADER_FONT_SIZE]];
        [self.rightButton setTitle:@"Videos" forState:UIControlStateNormal];
        self.rightButton.layer.cornerRadius = 8.0;
        [self.rightButton addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightButton];
        
    }
    return self;
}

- (void)didSelectButton:(UIButton *)sender{
    if (sender == _leftButton) {
        self.leftButton.backgroundColor = [UIColor whiteColor];
        [self.leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        self.rightButton.backgroundColor = [UIColor clearColor];
        [self.rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

        if ([self.delegate respondsToSelector:@selector(didSelectSegment:)]) {
            [self.delegate didSelectSegment:0];
        }
    }else if (sender == _rightButton){
        self.rightButton.backgroundColor = [UIColor whiteColor];
        [self.rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        self.leftButton.backgroundColor = [UIColor clearColor];
        [self.leftButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

        if ([self.delegate respondsToSelector:@selector(didSelectSegment:)]) {
            [self.delegate didSelectSegment:1];
        }
    }
}

@end
