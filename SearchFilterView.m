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
        
        self.exitButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.03, frame.size.height * 0.04, frame.size.width * 0.065, frame.size.width * 0.065)];
        self.exitButton.backgroundColor = [UIColor clearColor];
        [self.exitButton setImage:[UIImage imageNamed:@"filter_exit_btn"] forState:UIControlStateNormal];
        [self.exitButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.exitButton];
        
        self.openNow = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.22, frame.size.height * 0.12, frame.size.width * 0.44, frame.size.height * 0.1)];
        self.openNow.backgroundColor = [UIColor clearColor];
        self.openNow.layer.cornerRadius = self.openNow.frame.size.height/2;
        self.openNow.layer.borderWidth = 1.0;
        self.openNow.layer.borderColor = [UIColor blackColor].CGColor;
        [self.openNow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.openNow addTarget:self action:@selector(selectOpenNow) forControlEvents:UIControlEventTouchUpInside];
        [self.openNow setTitle:@"Open now" forState:UIControlStateNormal];
        [self.openNow.titleLabel setFont:[UIFont nun_boldFontWithSize:frame.size.height * 0.03]];
        [self addSubview:self.openNow];
        
        self.openNowSepLine = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.43, CGRectGetMaxY(self.openNow.frame) + frame.size.height * 0.04, frame.size.width * 0.86, 1.0)];
        self.openNowSepLine.backgroundColor = UIColorFromRGB(0x43474E);
        self.openNowSepLine.alpha = 0.6;
        [self addSubview:self.openNowSepLine];
        
        self.clearButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.78, CGRectGetMidY(self.exitButton.frame) - frame.size.height * 0.025, frame.size.width * 0.2, frame.size.height * 0.05)];
        self.clearButton.backgroundColor = [UIColor clearColor];
        self.clearButton.titleLabel.font = [UIFont nun_boldFontWithSize:frame.size.height * 0.025];
        self.clearButton.alpha = 0.0;
        [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        [self.clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.clearButton addTarget:self action:@selector(clearAllFilters) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.clearButton];
        
        self.applyButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.43, frame.size.height * 0.88, frame.size.width * 0.86, frame.size.height * 0.1)];
        self.applyButton.backgroundColor = UIColorFromRGB(0xDEEDFD);
        self.applyButton.layer.cornerRadius = self.applyButton.frame.size.height/2;
        self.applyButton.layer.borderColor = [UIColor blackColor].CGColor;
        self.applyButton.layer.borderWidth = 0.5;
        self.applyButton.alpha = 0.0;
        [self.applyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.applyButton.titleLabel setFont:[UIFont nun_boldFontWithSize:frame.size.height * 0.03]];
        [self.applyButton setTitle:@"APPLY" forState:UIControlStateNormal];
        [self.applyButton addTarget:self action:@selector(applyFilters) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.applyButton];
        
        [self setupPriceUI:frame];
        [self setupDistanceUI:frame];
        
        //[LayoutBounds drawBoundsForAllLayers:self];
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
    [self.priceTitle setFont:[UIFont nun_boldFontWithSize:frame.size.height * 0.025]];
    [self.priceTitle setText:@"Total price per person"];
    [self addSubview:self.priceTitle];
    
    self.priceContainer = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.openNowSepLine.frame), CGRectGetMaxY(self.priceTitle.frame) + frame.size.height * 0.03, self.openNowSepLine.frame.size.width, frame.size.height * 0.09)];
    self.priceContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.priceContainer];
    
    self.priceTierSecond = [[UIButton alloc]initWithFrame:CGRectMake(self.priceContainer.frame.size.width/2 - self.priceContainer.frame.size.width * 0.23, 0, self.priceContainer.bounds.size.width * 0.22, self.priceContainer.bounds.size.height)];
    self.priceTierSecond.backgroundColor = [UIColor clearColor];
    self.priceTierSecond.layer.borderColor = [UIColor blackColor].CGColor;
    self.priceTierSecond.layer.borderWidth = 0.5;
    self.priceTierSecond.layer.cornerRadius = 8.0;
    self.priceTierSecond.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.priceTierSecond setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.priceTierSecond setTitle:@"$15-30" forState:UIControlStateNormal];
    [self.priceTierSecond addTarget:self action:@selector(didSelectPrice:) forControlEvents:UIControlEventTouchUpInside];
    [self.priceTierSecond.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
    [self.priceContainer addSubview:self.priceTierSecond];
    
    self.priceTierThird = [[UIButton alloc]initWithFrame:CGRectMake(self.priceContainer.frame.size.width/2 + self.priceContainer.frame.size.width * 0.01, 0, self.priceContainer.bounds.size.width * 0.22, self.priceContainer.bounds.size.height)];
    self.priceTierThird.backgroundColor = [UIColor clearColor];
    self.priceTierThird.layer.borderColor = [UIColor blackColor].CGColor;
    self.priceTierThird.layer.borderWidth = 0.5;
    self.priceTierThird.layer.cornerRadius = 8.0;
    self.priceTierThird.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.priceTierThird setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.priceTierThird setTitle:@"$30-60" forState:UIControlStateNormal];
    [self.priceTierThird addTarget:self action:@selector(didSelectPrice:) forControlEvents:UIControlEventTouchUpInside];
    [self.priceTierThird.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];

    [self.priceContainer addSubview:self.priceTierThird];
    
    self.priceTierFirst = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.priceTierSecond.frame) - self.priceContainer.frame.size.width * 0.24, 0, self.priceContainer.bounds.size.width * 0.22, self.priceContainer.bounds.size.height)];
    self.priceTierFirst.backgroundColor = [UIColor clearColor];
    self.priceTierFirst.layer.borderColor = [UIColor blackColor].CGColor;
    self.priceTierFirst.layer.borderWidth = 0.5;
    self.priceTierFirst.layer.cornerRadius = 8.0;
    self.priceTierFirst.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.priceTierFirst setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.priceTierFirst setTitle:@"$<12" forState:UIControlStateNormal];
    [self.priceTierFirst addTarget:self action:@selector(didSelectPrice:) forControlEvents:UIControlEventTouchUpInside];
    [self.priceTierFirst.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
    [self.priceContainer addSubview:self.priceTierFirst];
    
    self.priceTierFourth = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.priceTierThird.frame) + self.priceContainer.frame.size.width * 0.02, 0, self.priceContainer.bounds.size.width * 0.22, self.priceContainer.bounds.size.height)];
    self.priceTierFourth.backgroundColor = [UIColor clearColor];
    self.priceTierFourth.layer.borderColor = [UIColor blackColor].CGColor;
    self.priceTierFourth.layer.borderWidth = 0.5;
    self.priceTierFourth.layer.cornerRadius = 8.0;
    self.priceTierFourth.titleLabel.numberOfLines = 2;
    self.priceTierFourth.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.priceTierFourth.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.priceTierFourth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithString:@"ball out\n($60+)"];
    [attTitle addAttributes:@{NSFontAttributeName : [UIFont nun_fontWithSize:12.0], NSForegroundColorAttributeName : UIColorFromRGB(0x949494)} range:NSMakeRange(8, attTitle.length - 8)];
    [self.priceTierFourth setAttributedTitle:attTitle forState:UIControlStateNormal];
    [self.priceTierFourth addTarget:self action:@selector(didSelectPrice:) forControlEvents:UIControlEventTouchUpInside];
    [self.priceTierFourth.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
    [self.priceContainer addSubview:self.priceTierFourth];
    
    self.priceSepLine = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.43, CGRectGetMaxY(self.priceContainer.frame) + frame.size.height * 0.05, frame.size.width * 0.86, 1.0)];
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
    [self.distanceTitle setFont:[UIFont nun_boldFontWithSize:frame.size.height * 0.025]];
    [self.distanceTitle setText:@"Distance away"];
    [self addSubview:self.distanceTitle];
    
    self.distanceContainer = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.openNowSepLine.frame) - self.openNowSepLine.frame.size.width * 0.46, CGRectGetMaxY(self.distanceTitle.frame) + frame.size.height * 0.03, self.openNowSepLine.frame.size.width * 0.96, frame.size.height * 0.09)];
    self.distanceContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.distanceContainer];
    
    self.distanceFirst = [[UIButton alloc]init];
    self.distanceSecond = [[UIButton alloc]init];
    self.distanceThird = [[UIButton alloc]init];
    self.distanceFourth = [[UIButton alloc]init];
    self.distanceFifth = [[UIButton alloc]init];
    self.distanceArray = @[self.distanceFirst, self.distanceSecond, self.distanceThird, self.distanceFourth, self.distanceFifth];
    
    for (int i = 0; i < 5; ++i) {
        UIButton *distButton = self.distanceArray[i];
        distButton.frame = CGRectMake(i * self.distanceContainer.bounds.size.width * 0.18, 0.0, self.distanceContainer.frame.size.width * 0.165, self.distanceContainer.bounds.size.height);
        distButton.backgroundColor = [UIColor whiteColor];
        distButton.layer.cornerRadius = 8.0;
        distButton.layer.borderColor = [UIColor blackColor].CGColor;
        distButton.layer.borderWidth = 0.5;
        distButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [distButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [distButton.titleLabel setFont:[UIFont nun_fontWithSize:16.0]];
        [distButton addTarget:self action:@selector(didSelectDistance:) forControlEvents:UIControlEventTouchUpInside];
        [self.distanceContainer addSubview:distButton];
        
        if(i == 0)[distButton setTitle:@"<1 mi" forState:UIControlStateNormal];
        else if(i == 1) [distButton setTitle:@"<3 mi" forState:UIControlStateNormal];
        else if(i == 2) [distButton setTitle:@"<5 mi" forState:UIControlStateNormal];
        else if (i == 3) [distButton setTitle:@"<8 mi" forState:UIControlStateNormal];
        else{
            distButton.frame = CGRectMake(self.distanceContainer.bounds.size.width * 0.72, 0.0, self.distanceContainer.frame.size.width * 0.27, self.distanceContainer.bounds.size.height);
            distButton.titleLabel.numberOfLines = 2;
            distButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithString:@"adventure\n(8+ mi)"];
            [attTitle addAttributes:@{NSFontAttributeName : [UIFont nun_fontWithSize:12.0], NSForegroundColorAttributeName : UIColorFromRGB(0x949494)} range:NSMakeRange(9, attTitle.length - 9)];
            [distButton setAttributedTitle:attTitle forState:UIControlStateNormal];
            [distButton setTitle:@"adventure\n(8+ mi)" forState:UIControlStateNormal];
        }
    }
    
    self.distances = @[@"1600", @"4828", @"8046", @"12874", @"30000"];
}

- (void)toggleApplyButton{
    if (self.openNowFilter || self.priceFilters.count > 0 || self.distanceFilter) {
        [UIView animateWithDuration:0.25 animations:^{
            self.applyButton.alpha = 1.0;
            self.clearButton.alpha = 1.0;

        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.applyButton.alpha = 0.0;
            self.clearButton.alpha = 0.0;
        }];
    }
}

- (void)clearAllFilters{
    //Get each button selected and reset values
    if (self.priceFilters.count > 0) {
        for (UIButton *priceBtn in self.priceArray) {
            priceBtn.backgroundColor = [UIColor whiteColor];
        }
        [self.priceFilters removeAllObjects];
    }
    
    if (self.distanceFilter) {
        UIButton *distance = self.distanceArray[[self.distanceFilter integerValue]];
        distance.backgroundColor = [UIColor whiteColor];
        self.distanceFilter = nil;
    }
    
    self.openNow.backgroundColor = [UIColor whiteColor];
    self.openNowFilter = nil;

    [self toggleApplyButton];
}

- (void)exit{
    [self clearAllFilters];
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark - Delegate methods

- (void)selectOpenNow{
    if ([self.openNowFilter boolValue]) {
        self.openNow.backgroundColor = [UIColor whiteColor];
        self.openNowFilter = @(0);
    }else{
        self.openNow.backgroundColor = UIColorFromRGB(0xDEEDFD);
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
        [self.priceFilters removeObject:@(btnIndex + 1)];
    }else{
        price.backgroundColor = UIColorFromRGB(0xDEEDFD);
        NSInteger index = [self.priceArray indexOfObject:price];
        [self.priceFilters addObject:@(index + 1)];
    }
    [self toggleApplyButton];
}

- (void)didSelectDistance:(UIButton *)distance{
    if (self.distanceFilter) {
        //Deselect previous distance if there was one
        UIButton *prevDist = self.distanceArray[[self.distanceFilter integerValue]];
        prevDist.backgroundColor = [UIColor whiteColor];
        self.distanceFilter = nil;
    }else{
        [distance setBackgroundColor:UIColorFromRGB(0xDEEDFD)];
        NSInteger index = [self.distanceArray indexOfObject:distance];
        self.distanceFilter = @(index);
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
    
    [self clearAllFilters];
    
    if ([self.delegate respondsToSelector:@selector(didSelectFilters:)]) {
        [self.delegate didSelectFilters:filters];
    }
}

@end
