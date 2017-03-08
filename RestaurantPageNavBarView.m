//
//  RestaurantPageNavBarView.m
//  FoodWise
//
//  Created by Brian Wong on 2/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RestaurantPageNavBarView.h"

@interface RestaurantPageNavBarView()

@property (nonatomic, strong) UIView *beenHereView;

@end

@implementation RestaurantPageNavBarView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.beenHereView = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width * 0.7, frame.size.height/2 - frame.size.height * 0.2, frame.size.width * 0.3, frame.size.height * 0.4)];
        self.beenHereView.backgroundColor = [UIColor redColor];
        [self addSubview:self.beenHereView];
    }
    return self;
}

- (void)setupUI:(CGRect)frame{
}

@end
