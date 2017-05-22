//
//  RestaurantPageControlView.m
//  Foodhead
//
//  Created by Brian Wong on 5/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RestaurantPageControlView.h"
#import "UIFont+Extension.h"
#import "FoodWiseDefines.h"
#import "LayoutBounds.h"

@implementation RestaurantPageControlView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width * 0.02, self.frame.size.height/2 - self.frame.size.height * 0.31, self.frame.size.width * 0.25, self.frame.size.height * 0.37)];
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        [self.priceLabel setFont:[UIFont nun_mediumFontWithSize:self.frame.size.height * 0.35]];
        [self addSubview:self.priceLabel];
        
        self.priceTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.priceLabel.frame) - self.frame.size.width * 0.11, CGRectGetMaxY(self.priceLabel.frame) , self.frame.size.width * 0.22, self.frame.size.height * 0.3)];
        self.priceTitle.textAlignment = NSTextAlignmentCenter;
        self.priceTitle.backgroundColor = [UIColor clearColor];
        [self.priceTitle setFont:[UIFont nun_lightFontWithSize:REST_PAGE_HEADER_FONT_SIZE]];
        [self.priceTitle setText:@"per person"];
        [self.priceTitle setTextColor:UIColorFromRGB(0x9B9B9B)];
        [self addSubview:self.priceTitle];
        
        self.callButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.priceLabel.frame) + self.frame.size.width * 0.04, self.frame.size.height/2 - self.frame.size.height * 0.35, self.frame.size.width * 0.2, self.frame.size.height * 0.7)];
        self.callButton.backgroundColor = [UIColor clearColor];
        [self.callButton setImage:[UIImage imageNamed:@"call_btn"] forState:UIControlStateNormal];
        [self.callButton addTarget:self action:@selector(callButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.callButton];
        
        self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.callButton.frame) + self.frame.size.width * 0.04, self.frame.size.height/2 - self.frame.size.height * 0.35, self.frame.size.width * 0.2, self.frame.size.height * 0.7)];
        self.shareButton.backgroundColor = [UIColor clearColor];
        [self.shareButton setImage:[UIImage imageNamed:@"share_button"] forState:UIControlStateNormal];
        [self addSubview:self.shareButton];
        
        self.favoriteButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.shareButton.frame) + self.frame.size.width * 0.04, self.frame.size.height/2 - self.frame.size.height * 0.35, self.frame.size.width * 0.2, self.frame.size.height * 0.7)];
        self.favoriteButton.backgroundColor = [UIColor clearColor];
        self.favoriteButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.favoriteButton addTarget:self action:@selector(favoriteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.favoriteButton];
        
        UIView *sepLine = [[UIView alloc]initWithFrame:CGRectMake(0.0, frame.size.height - 1.0, frame.size.width, 1.0)];
        sepLine.backgroundColor = UIColorFromRGB(0x47606A);
        sepLine.alpha = 0.15;
        [self addSubview:sepLine];        
    }
    return self;
}

- (void)setTextForPrice:(NSNumber *)price{
    if ([price isEqual: @(1)]) {
        self.priceLabel.text = @"<$12";
    }else if ([price isEqual: @(2)]){
        self.priceLabel.text = @"$15-25";
    }else if ([price isEqual: @(3)]){
        self.priceLabel.text = @"$30-60";
    }else if ([price isEqual: @(4)]){
        self.priceLabel.text = @"$60+";
    }else{
        self.priceLabel.font = [UIFont nun_mediumFontWithSize:REST_PAGE_HEADER_FONT_SIZE];
        self.priceLabel.text = @"no price yet";
    }
}

- (void)favoriteButtonClicked{
    if ([self.delegate respondsToSelector:@selector(userClickedFavoriteButton)]) {
        [self.delegate userClickedFavoriteButton];
    }
}

- (void)toggleFavoriteButton:(BOOL)favorite{
    if (favorite) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_browse_fill"] forState:UIControlStateNormal];
    }else{
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_browse"] forState:UIControlStateNormal];
    }
}

- (void)callButtonClicked{
    if ([self.delegate respondsToSelector:@selector(userCLickedCallButton)]) {
        [self.delegate userCLickedCallButton];
    }
}

@end
