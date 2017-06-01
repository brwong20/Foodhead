//
//  OnboardingView.m
//  Foodhead
//
//  Created by Brian Wong on 5/27/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "OnboardingView.h"
#import "UIFont+Extension.h"

@interface OnboardingView ()

@property (nonatomic, strong) UIView *onboardView;
@property (nonatomic, strong) UILabel *onboardingPrompt;
@property (nonatomic, strong) UIImageView *onboardingImg;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation OnboardingView

- (instancetype)initWithFrame:(CGRect)frame onPage:(OnboardingPage)page{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.onboardView = [[UIView alloc]initWithFrame:CGRectMake(0.0, frame.size.height - frame.size.height * 0.25, frame.size.width, frame.size.height * 0.27)];
        self.onboardView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.93];
        self.onboardView.layer.shadowOffset = CGSizeMake(-2.0, 0.0);
        self.onboardView.layer.shadowOpacity = 0.5;
        self.onboardView.layer.shadowRadius = 10.0;
        self.onboardView.layer.shadowColor = [UIColor blackColor].CGColor;
        [self addSubview:self.onboardView];
        
        self.onboardingPrompt = [[UILabel alloc]initWithFrame:CGRectMake(self.onboardView.frame.size.width/2 - self.onboardView.frame.size.width * 0.425, self.onboardView.frame.size.height * 0.03, self.onboardView.frame.size.width * 0.85, self.onboardView.frame.size.height * 0.4)];
        self.onboardingPrompt.backgroundColor = [UIColor clearColor];
        self.onboardingPrompt.font = [UIFont nun_mediumFontWithSize:REST_PAGE_HEADER_FONT_SIZE + 1.0];
        self.onboardingPrompt.numberOfLines = 2;
        self.onboardingPrompt.textAlignment = NSTextAlignmentCenter;
        
        NSString *onboardPrompt;
        UIImage *onboardImg;
        if (page == OnboardingPageHome) {
            onboardPrompt = @"Browse restaurants curated\nfrom tasty food blogs near you.";
            onboardImg = [UIImage imageNamed:@"owl_full"];
        }else if (page == OnboardingPageFavorite){
            onboardPrompt = @"Tap a fork to favorite restaurants\nyou love or want to try";
            onboardImg = [UIImage imageNamed:@"favorite_big"];
        }else if (page == OnboardingPageBrowse){
            onboardPrompt = @"Watch video recipes, cooking\n tips, inspiring chefs, and more!";
            onboardImg = [UIImage imageNamed:@"owl_openarms"];
        }
        
        self.onboardingPrompt.text = onboardPrompt;
        [self.onboardView addSubview:self.onboardingPrompt];
        
        self.onboardingImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.onboardView.frame.size.width/2 - self.onboardView.frame.size.width * 0.1, CGRectGetMaxY(self.onboardingPrompt.frame) + self.onboardView.frame.size.height * 0.01, self.onboardView.frame.size.width * 0.2, self.onboardView.frame.size.width * 0.2)];
        self.onboardingImg.contentMode = UIViewContentModeScaleAspectFit;
        self.onboardingImg.backgroundColor = [UIColor clearColor];
        self.onboardingImg.layer.rasterizationScale = [[UIScreen mainScreen]scale];
        self.onboardingImg.layer.shouldRasterize = YES;
        [self.onboardingImg setImage:onboardImg];
        [self.onboardView addSubview:self.onboardingImg];
    }
    return self;
}

@end
