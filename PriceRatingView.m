//
//  PriceRatingView.m
//  Foodhead
//
//  Created by Brian Wong on 3/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "PriceRatingView.h"
#import "UIFont+Extension.h"

@interface PriceRatingView ()

@property (nonatomic, strong) UILabel *priceLabel;

@end

@implementation PriceRatingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.45, frame.size.height/2 - frame.size.height * 0.35, frame.size.width * 0.9, frame.size.height * 0.7)];
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        self.priceLabel.textColor = [UIColor whiteColor];
        self.priceLabel.font = [UIFont nun_fontWithSize:frame.size.height * 0.43];
        [self addSubview:self.priceLabel];
    }
    return self;
}

- (void)setPrice:(NSNumber *)price{
    if (price) {
        [self.priceLabel setText:[NSString stringWithFormat:@"$%.2f", [price doubleValue]]];
    }else{
        [self.priceLabel setText:@""];
    }
}

@end
