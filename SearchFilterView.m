//
//  SearchFilterView.m
//  Foodhead
//
//  Created by Brian Wong on 4/10/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "SearchFilterView.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"
#import "FoodheadAnalytics.h"

@interface SearchFilterView ()

//Navigation
@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIButton *applyButton;

//Open Now
@property (nonatomic, strong) UIButton *openNow;
@property (nonatomic, strong) UIView *openNowSepLine;
@property (nonatomic, strong) NSNumber *openNowFilter;

//Price
@property (nonatomic, strong) UIImageView *priceIcon;
@property (nonatomic, strong) UILabel *priceTitle;
@property (nonatomic, strong) UIView *priceContainer;
@property (nonatomic, strong) UIView *priceSepLine;


@property (nonatomic, strong) UIButton *priceTierFirst;
@property (nonatomic, strong) UIButton *priceTierSecond;
@property (nonatomic, strong) UIButton *priceTierThird;
@property (nonatomic, strong) UIButton *priceTierFourth;
@property (nonatomic, strong) NSArray *priceArray;

@property (nonatomic, strong) NSMutableArray *priceFilters;//Can have multiple price options


//Distance
@property (nonatomic, strong) UIImageView *distanceIcon;
@property (nonatomic, strong) UILabel *distanceTitle;
@property (nonatomic, strong) UIView *distanceContainer;
@property (nonatomic, strong) UIView *distanceSepLine;


@property (nonatomic, strong) UIButton *distanceFirst;
@property (nonatomic, strong) UIButton *distanceSecond;
@property (nonatomic, strong) UIButton *distanceThird;
@property (nonatomic, strong) UIButton *distanceFourth;
@property (nonatomic, strong) UIButton *distanceFifth;
@property (nonatomic, strong) NSArray *distanceArray;
@property (nonatomic, strong) NSArray *distances;

@property (nonatomic, strong) NSNumber *distanceFilter;

@end

@implementation SearchFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = APPLICATION_BACKGROUND_COLOR;
        
        self.openNow = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.22, frame.size.height * 0.11, frame.size.width * 0.44, frame.size.height * 0.1)];
        self.openNow.backgroundColor = [UIColor whiteColor];
        self.openNow.layer.cornerRadius = 8.0;
        self.openNow.layer.borderWidth = 1.0;
        self.openNow.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
        [self.openNow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.openNow addTarget:self action:@selector(selectOpenNow) forControlEvents:UIControlEventTouchUpInside];
        [self.openNow setTitle:@"Open now" forState:UIControlStateNormal];
        [self.openNow.titleLabel setFont:[UIFont nun_mediumFontWithSize:frame.size.height * 0.03]];
        [self addSubview:self.openNow];
        
        self.openNowSepLine = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.45, CGRectGetMaxY(self.openNow.frame) + frame.size.height * 0.04, frame.size.width * 0.9, 1.0)];
        self.openNowSepLine.backgroundColor = UIColorFromRGB(0x43474E);
        self.openNowSepLine.alpha = 0.6;
        [self addSubview:self.openNowSepLine];
        
        self.exitButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.openNowSepLine.frame) - frame.size.width * 0.2, frame.size.height * 0.02, frame.size.width * 0.2, frame.size.width * 0.08)];
        self.exitButton.backgroundColor = [UIColor clearColor];
        self.exitButton.titleLabel.font = [UIFont nun_lightFontWithSize:frame.size.height * 0.03];
        self.exitButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.exitButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.exitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.exitButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.exitButton];
        
        self.clearButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.openNowSepLine.frame), CGRectGetMidY(self.exitButton.frame) - frame.size.height * 0.025, frame.size.width * 0.2, frame.size.width * 0.08)];
        self.clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.clearButton.backgroundColor = [UIColor clearColor];
        self.clearButton.titleLabel.font = [UIFont nun_lightFontWithSize:frame.size.height * 0.03];
        self.clearButton.alpha = 0.0;
        [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        [self.clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.clearButton addTarget:self action:@selector(clearAllFilters) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.clearButton];
        
        self.applyButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.43, frame.size.height * 0.78, frame.size.width * 0.86, frame.size.height * 0.1)];
        self.applyButton.backgroundColor = APPLICATION_BLUE_COLOR;
        self.applyButton.layer.cornerRadius = 8.0;
        self.applyButton.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
        self.applyButton.layer.borderWidth = 1.0;
        [self.applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.applyButton.titleLabel setFont:[UIFont nun_mediumFontWithSize:frame.size.height * 0.03]];
        [self.applyButton setTitle:@"Apply" forState:UIControlStateNormal];
        [self.applyButton addTarget:self action:@selector(applyFilters) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.applyButton];
        
        [self setupPriceUI:frame];
        [self setupDistanceUI:frame];
    }
    return self;
}

- (void)setupPriceUI:(CGRect)frame{
    self.priceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width * 0.28, CGRectGetMaxY(self.openNowSepLine.frame) + frame.size.height * 0.025, frame.size.width * 0.05, frame.size.width * 0.05)];
    self.priceIcon.backgroundColor = [UIColor clearColor];
    self.priceIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.priceIcon setImage:[UIImage imageNamed:@"price_search_filter"]];
    [self addSubview:self.priceIcon];
    
    self.priceTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.priceIcon.frame) + frame.size.width * 0.02, CGRectGetMinY(self.priceIcon.frame), frame.size.width * 0.5, frame.size.height * 0.03)];
    self.priceTitle.backgroundColor = [UIColor clearColor];
    [self.priceTitle setFont:[UIFont nun_mediumFontWithSize:frame.size.height * 0.025]];
    [self.priceTitle setText:@"Total price per person"];
    [self addSubview:self.priceTitle];
    
    self.priceContainer = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.openNowSepLine.frame), CGRectGetMaxY(self.priceTitle.frame) + frame.size.height * 0.03, self.openNowSepLine.frame.size.width, frame.size.height * 0.12)];
    self.priceContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.priceContainer];
    
    self.priceTierSecond = [[UIButton alloc]initWithFrame:CGRectMake(self.priceContainer.frame.size.width/2 - self.priceContainer.frame.size.width * 0.23, 0, self.priceContainer.bounds.size.width * 0.22, self.priceContainer.bounds.size.height)];
    self.priceTierSecond.backgroundColor = [UIColor clearColor];
    self.priceTierSecond.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
    self.priceTierSecond.layer.borderWidth = 1.0;
    self.priceTierSecond.layer.cornerRadius = 8.0;
    self.priceTierSecond.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.priceTierSecond setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.priceTierSecond setTitle:@"$15-30" forState:UIControlStateNormal];
    [self.priceTierSecond addTarget:self action:@selector(didSelectPrice:) forControlEvents:UIControlEventTouchUpInside];
    [self.priceTierSecond.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
    [self.priceContainer addSubview:self.priceTierSecond];
    
    self.priceTierThird = [[UIButton alloc]initWithFrame:CGRectMake(self.priceContainer.frame.size.width/2 + self.priceContainer.frame.size.width * 0.01, 0, self.priceContainer.bounds.size.width * 0.22, self.priceContainer.bounds.size.height)];
    self.priceTierThird.backgroundColor = [UIColor clearColor];
    self.priceTierThird.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
    self.priceTierThird.layer.borderWidth = 1.0;
    self.priceTierThird.layer.cornerRadius = 8.0;
    self.priceTierThird.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.priceTierThird setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.priceTierThird setTitle:@"$30-60" forState:UIControlStateNormal];
    [self.priceTierThird addTarget:self action:@selector(didSelectPrice:) forControlEvents:UIControlEventTouchUpInside];
    [self.priceTierThird.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];

    [self.priceContainer addSubview:self.priceTierThird];
    
    self.priceTierFirst = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.priceTierSecond.frame) - self.priceContainer.frame.size.width * 0.24, 0, self.priceContainer.bounds.size.width * 0.22, self.priceContainer.bounds.size.height)];
    self.priceTierFirst.backgroundColor = [UIColor clearColor];
    self.priceTierFirst.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
    self.priceTierFirst.layer.borderWidth = 1.0;
    self.priceTierFirst.layer.cornerRadius = 8.0;
    self.priceTierFirst.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.priceTierFirst setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.priceTierFirst setTitle:@"$<12" forState:UIControlStateNormal];
    [self.priceTierFirst addTarget:self action:@selector(didSelectPrice:) forControlEvents:UIControlEventTouchUpInside];
    [self.priceTierFirst.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
    [self.priceContainer addSubview:self.priceTierFirst];
    
    self.priceTierFourth = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.priceTierThird.frame) + self.priceContainer.frame.size.width * 0.02, 0, self.priceContainer.bounds.size.width * 0.22, self.priceContainer.bounds.size.height)];
    self.priceTierFourth.backgroundColor = [UIColor clearColor];
    self.priceTierFourth.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
    self.priceTierFourth.layer.borderWidth = 1.0;
    self.priceTierFourth.layer.cornerRadius = 8.0;
    self.priceTierFourth.titleLabel.numberOfLines = 2;
    self.priceTierFourth.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.priceTierFourth.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.priceTierFourth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.priceTierFourth setTitle:@"$60+" forState:UIControlStateNormal];
//    NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithString:@"ball out\n($60+)"];
//    [attTitle addAttributes:@{NSFontAttributeName : [UIFont nun_fontWithSize:12.0], NSForegroundColorAttributeName : UIColorFromRGB(0x949494)} range:NSMakeRange(8, attTitle.length - 8)];
//    [self.priceTierFourth setAttributedTitle:attTitle forState:UIControlStateNormal];
    [self.priceTierFourth addTarget:self action:@selector(didSelectPrice:) forControlEvents:UIControlEventTouchUpInside];
    [self.priceTierFourth.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
    [self.priceContainer addSubview:self.priceTierFourth];
    
    self.priceSepLine = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.45, CGRectGetMaxY(self.priceContainer.frame) + frame.size.height * 0.05, frame.size.width * 0.9, 1.0)];
    self.priceSepLine.backgroundColor = UIColorFromRGB(0x43474E);
    self.priceSepLine.alpha = 0.6;
    [self addSubview:self.priceSepLine];
    
    self.priceArray = @[self.priceTierFirst, self.priceTierSecond, self.priceTierThird, self.priceTierFourth];
    self.priceFilters = [NSMutableArray array];
}

- (void)setupDistanceUI:(CGRect)frame{
    self.distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width * 0.32, CGRectGetMaxY(self.priceSepLine.frame) + frame.size.height * 0.025, frame.size.width * 0.04, frame.size.width * 0.04)];
    self.distanceIcon.backgroundColor = [UIColor clearColor];
    [self.distanceIcon setImage:[UIImage imageNamed:@"distance_search_filter"]];
    [self addSubview:self.distanceIcon];
    
    self.distanceTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.distanceIcon.frame) + frame.size.width * 0.025, CGRectGetMinY(self.distanceIcon.frame), frame.size.width * 0.5, frame.size.height * 0.03)];
    self.distanceTitle.backgroundColor = [UIColor clearColor];
    [self.distanceTitle setFont:[UIFont nun_mediumFontWithSize:frame.size.height * 0.025]];
    [self.distanceTitle setText:@"Distance away"];
    [self addSubview:self.distanceTitle];
    
    self.distanceContainer = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.priceContainer.frame), CGRectGetMaxY(self.distanceTitle.frame) + frame.size.height * 0.03, self.openNowSepLine.frame.size.width, frame.size.height * 0.12)];
    self.distanceContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.distanceContainer];
    
//    self.distanceFirst = [[UIButton alloc]init];
//    self.distanceSecond = [[UIButton alloc]init];
//    self.distanceThird = [[UIButton alloc]init];
//    self.distanceFourth = [[UIButton alloc]init];
////    self.distanceFifth = [[UIButton alloc]init];
//    self.distanceArray = @[self.distanceFirst, self.distanceSecond, self.distanceThird, self.distanceFourth];
//    
//    for (int i = 0; i < 4; ++i) {
//        UIButton *distButton = self.distanceArray[i];
//        distButton.frame = CGRectMake(i * self.distanceContainer.bounds.size.width * 0.22, 0.0, self.distanceContainer.frame.size.width * 0.165, self.distanceContainer.bounds.size.height);
//        distButton.backgroundColor = [UIColor whiteColor];
//        distButton.layer.cornerRadius = 8.0;
//        distButton.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
//        distButton.layer.borderWidth = 1.0;
//        distButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [distButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [distButton.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
//        [distButton addTarget:self action:@selector(didSelectDistance:) forControlEvents:UIControlEventTouchUpInside];
//        [self.distanceContainer addSubview:distButton];
//        
//        if(i == 0)[distButton setTitle:@"<1 mi" forState:UIControlStateNormal];
//        else if(i == 1) [distButton setTitle:@"<3 mi" forState:UIControlStateNormal];
//        else if(i == 2) [distButton setTitle:@"<6 mi" forState:UIControlStateNormal];
//        else if (i == 3) [distButton setTitle:@"<12 mi" forState:UIControlStateNormal];
//        else{
//            distButton.frame = CGRectMake(self.distanceContainer.bounds.size.width * 0.72, 0.0, self.distanceContainer.frame.size.width * 0.27, self.distanceContainer.bounds.size.height);
//            distButton.titleLabel.numberOfLines = 2;
//            distButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//            NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithString:@"adventure\n(8+ mi)"];
//            [attTitle addAttributes:@{NSFontAttributeName : [UIFont nun_fontWithSize:12.0], NSForegroundColorAttributeName : UIColorFromRGB(0x949494)} range:NSMakeRange(9, attTitle.length - 9)];
//            [distButton setAttributedTitle:attTitle forState:UIControlStateNormal];
//            [distButton setTitle:@"adventure\n(8+ mi)" forState:UIControlStateNormal];
//        }
//    }
    
    self.distanceSecond = [[UIButton alloc]initWithFrame:CGRectMake(self.distanceContainer.frame.size.width/2 - self.distanceContainer.frame.size.width * 0.23, 0, self.distanceContainer.bounds.size.width * 0.22, self.distanceContainer.bounds.size.height)];
    self.distanceSecond.backgroundColor = [UIColor clearColor];
    self.distanceSecond.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
    self.distanceSecond.layer.borderWidth = 1.0;
    self.distanceSecond.layer.cornerRadius = 8.0;
    self.distanceSecond.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.distanceSecond setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.distanceSecond setTitle:@"<3 mi" forState:UIControlStateNormal];
    [self.distanceSecond addTarget:self action:@selector(didSelectDistance:) forControlEvents:UIControlEventTouchUpInside];
    [self.distanceSecond.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
    [self.distanceContainer addSubview:self.distanceSecond];
    
    self.distanceThird = [[UIButton alloc]initWithFrame:CGRectMake(self.distanceContainer.frame.size.width/2 + self.distanceContainer.frame.size.width * 0.01, 0, self.distanceContainer.bounds.size.width * 0.22, self.distanceContainer.bounds.size.height)];
    self.distanceThird.backgroundColor = [UIColor clearColor];
    self.distanceThird.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
    self.distanceThird.layer.borderWidth = 1.0;
    self.distanceThird.layer.cornerRadius = 8.0;
    self.distanceThird.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.distanceThird setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.distanceThird setTitle:@"<6 mi" forState:UIControlStateNormal];
    [self.distanceThird addTarget:self action:@selector(didSelectDistance:) forControlEvents:UIControlEventTouchUpInside];
    [self.distanceThird.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
    [self.distanceContainer addSubview:self.distanceThird];
    
    self.distanceFirst = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.distanceSecond.frame) - self.distanceContainer.frame.size.width * 0.24, 0, self.distanceContainer.bounds.size.width * 0.22, self.distanceContainer.bounds.size.height)];
    self.distanceFirst.backgroundColor = [UIColor clearColor];
    self.distanceFirst.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
    self.distanceFirst.layer.borderWidth = 1.0;
    self.distanceFirst.layer.cornerRadius = 8.0;
    self.distanceFirst.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.distanceFirst setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.distanceFirst setTitle:@"<1 mi" forState:UIControlStateNormal];
    [self.distanceFirst addTarget:self action:@selector(didSelectDistance:) forControlEvents:UIControlEventTouchUpInside];
    [self.distanceFirst.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
    [self.distanceContainer addSubview:self.distanceFirst];
    
    self.distanceFourth = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.distanceThird.frame) + self.distanceContainer.frame.size.width * 0.02, 0, self.distanceContainer.bounds.size.width * 0.22, self.distanceContainer.bounds.size.height)];
    self.distanceFourth.backgroundColor = [UIColor clearColor];
    self.distanceFourth.layer.borderColor = UIColorFromRGB(0x979797).CGColor;
    self.distanceFourth.layer.borderWidth = 1.0;
    self.distanceFourth.layer.cornerRadius = 8.0;
    self.distanceFourth.titleLabel.numberOfLines = 2;
    self.distanceFourth.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.distanceFourth.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.distanceFourth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.distanceFourth setTitle:@"<12 mi" forState:UIControlStateNormal];
 //   NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithString:@"< 6mi"];
//    [attTitle addAttributes:@{NSFontAttributeName : [UIFont nun_fontWithSize:12.0], NSForegroundColorAttributeName : UIColorFromRGB(0x949494)} range:NSMakeRange(8, attTitle.length - 8)];
//    [self.distanceFourth setAttributedTitle:attTitle forState:UIControlStateNormal];
    [self.distanceFourth addTarget:self action:@selector(didSelectDistance:) forControlEvents:UIControlEventTouchUpInside];
    [self.distanceFourth.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
    [self.distanceContainer addSubview:self.distanceFourth];
    
    self.distances = @[@"1600", @"4828", @"9656", @"19312"];
    self.distanceArray = @[self.distanceFirst, self.distanceSecond, self.distanceThird, self.distanceFourth];
}

- (void)toggleApplyButton{
    if (self.openNowFilter.boolValue || self.priceFilters.count > 0 || self.distanceFilter) {
        [UIView animateWithDuration:0.25 animations:^{
            self.clearButton.alpha = 1.0;

        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.clearButton.alpha = 0.0;
        }];
    }
}

- (void)clearAllFilters{
    //Get each button selected and reset values
    if (self.priceFilters.count > 0) {
        for (UIButton *priceBtn in self.priceArray) {
            priceBtn.backgroundColor = [UIColor whiteColor];
            [priceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [self.priceFilters removeAllObjects];
    }
    
    if (self.distanceFilter) {
        UIButton *distance = self.distanceArray[[self.distanceFilter integerValue]];
        distance.backgroundColor = [UIColor whiteColor];
        [distance setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.distanceFilter = nil;
    }
    
    [self.openNow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.openNow.backgroundColor = [UIColor whiteColor];
    self.openNowFilter = nil;

    [self toggleApplyButton];
}

- (void)exit{
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark - Delegate methods

- (void)selectOpenNow{
    if ([self.openNowFilter boolValue]) {
        self.openNow.backgroundColor = [UIColor whiteColor];
        [self.openNow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.openNowFilter = @(0);
    }else{
        self.openNow.backgroundColor = APPLICATION_BLUE_COLOR;
        [self.openNow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.openNowFilter = @(1);
    }
    
    [self toggleApplyButton];
}

- (void)didSelectPrice:(UIButton *)price{
    NSInteger btnIndex = [self.priceArray indexOfObject:price];
    BOOL prevPrice = [self.priceFilters containsObject:@(btnIndex + 1)];
    if (prevPrice) {
        //Deselect previous price if there was one
        price.backgroundColor = [UIColor whiteColor];
        [price setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.priceFilters removeObject:@(btnIndex + 1)];
    }else{
        price.backgroundColor = APPLICATION_BLUE_COLOR;
        [price setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        NSInteger index = [self.priceArray indexOfObject:price];
        [self.priceFilters addObject:@(index + 1)];
    }
    [self toggleApplyButton];
}

- (void)didSelectDistance:(UIButton *)distance{
    NSInteger btnIndex = [self.distanceArray indexOfObject:distance];
    if (self.distanceFilter && self.distanceFilter.integerValue == btnIndex) {
        distance.backgroundColor = [UIColor whiteColor];
        [distance setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.distanceFilter = nil;
    }else{
        for (UIButton *distBtn in self.distanceArray) {
            if (distance != distBtn) {
                distBtn.backgroundColor = [UIColor whiteColor];
                [distBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }else{
                distBtn.backgroundColor = APPLICATION_BLUE_COLOR;
                [distBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
        self.distanceFilter = @(btnIndex);
    }
    
    [self toggleApplyButton];
}

- (void)applyFilters{
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    //Must be non-nil since these are going into the foursquare request directly
    if (self.openNowFilter) [filters setObject:[self.openNowFilter stringValue] forKey:@"openNow"];
    if (self.priceFilters.count > 0){
        NSString *prices = [self.priceFilters componentsJoinedByString:@","];
        [filters setObject:prices forKey:@"price"];
    }
    if (self.distanceFilter) [filters setObject:self.distances[[self.distanceFilter integerValue]] forKey:@"radius"];
    
    if ([self.delegate respondsToSelector:@selector(didSelectFilters:)]) {
        [self.delegate didSelectFilters:filters];
    }    
    [FoodheadAnalytics logEvent:SEARCH_FILTER_APPLY withParameters:filters];
}

@end
