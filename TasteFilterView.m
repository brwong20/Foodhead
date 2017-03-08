//
//  TasteFilterView.m
//  FoodWise
//
//  Created by Brian Wong on 2/7/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TasteFilterView.h"

@interface TasteFilterView ()

@property (nonatomic, strong) NSNumber *tasteRating;
@property (nonatomic, strong) UIView *tasteView;

@property (nonatomic, strong) UIButton *taste1;
@property (nonatomic, strong) UIButton *taste2;
@property (nonatomic, strong) UIButton *taste3;
@property (nonatomic, strong) UIButton *taste4;
@property (nonatomic, strong) UIButton *taste5;
@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation TasteFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.filterTitle = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2 - 150.0, 100.0, 300.0, 50.0)];
        self.filterTitle.backgroundColor = [UIColor clearColor];
        self.filterTitle.textColor = [UIColor whiteColor];
        self.filterTitle.font = [UIFont boldSystemFontOfSize:40.0];
        self.filterTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.filterTitle];
        
        self.filterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height)];
        self.filterImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.filterImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.filterImageView];
        
        self.taste1 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.15, frame.size.height * 0.8, 50.0, 50.0)];
        self.taste1.layer.cornerRadius = self.taste1.frame.size.height/2;
        self.taste1.backgroundColor = [UIColor whiteColor];
        self.taste1.layer.borderColor = [UIColor redColor].CGColor;
        self.taste1.layer.borderWidth = 2.0;
        [self.taste1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.taste1 setTitle:@"1" forState:UIControlStateNormal];
        [self.taste1 addTarget:self action:@selector(didSelectTasteRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.taste1];
        
        self.taste2 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.3, frame.size.height * 0.8, 50.0, 50.0)];
        self.taste2.layer.cornerRadius = self.taste2.frame.size.height/2;
        self.taste2.backgroundColor = [UIColor whiteColor];
        self.taste2.layer.borderColor = [UIColor yellowColor].CGColor;
        self.taste2.layer.borderWidth = 2.0;
        [self.taste2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.taste2 setTitle:@"2" forState:UIControlStateNormal];
        [self.taste2 addTarget:self action:@selector(didSelectTasteRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.taste2];
        
        self.taste3 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.45, frame.size.height * 0.8, 50.0, 50.0)];
        self.taste3.layer.cornerRadius = self.taste3.frame.size.height/2;
        self.taste3.backgroundColor = [UIColor whiteColor];
        self.taste3.layer.borderColor = [UIColor yellowColor].CGColor;
        self.taste3.layer.borderWidth = 2.0;
        [self.taste3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.taste3 setTitle:@"3" forState:UIControlStateNormal];
        [self.taste3 addTarget:self action:@selector(didSelectTasteRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.taste3];
        
        self.taste4 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.6, frame.size.height * 0.8, 50.0, 50.0)];
        self.taste4.layer.cornerRadius = self.taste4.frame.size.height/2;
        self.taste4.backgroundColor = [UIColor whiteColor];
        self.taste4.layer.borderColor = [UIColor yellowColor].CGColor;
        self.taste4.layer.borderWidth = 2.0;
        [self.taste4 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.taste4 setTitle:@"4" forState:UIControlStateNormal];
        [self.taste4 addTarget:self action:@selector(didSelectTasteRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.taste4];
        
        self.taste5 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.75, frame.size.height * 0.8, 50.0, 50.0)];
        self.taste5.layer.cornerRadius = self.taste5.frame.size.height/2;
        self.taste5.backgroundColor = [UIColor whiteColor];
        self.taste5.layer.borderColor = [UIColor greenColor].CGColor;
        self.taste5.layer.borderWidth = 2.0;
        [self.taste5 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.taste5 setTitle:@"5" forState:UIControlStateNormal];
        [self.taste5 addTarget:self action:@selector(didSelectTasteRating:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.taste5];
        
        self.buttonArray = [NSMutableArray array];
        [self.buttonArray addObject:self.taste1];
        [self.buttonArray addObject:self.taste2];
        [self.buttonArray addObject:self.taste3];
        [self.buttonArray addObject:self.taste4];
        [self.buttonArray addObject:self.taste5];
    }
    return self;
}

- (void)didSelectTasteRating:(UIButton *)ratingButton{
    if ([ratingButton isEqual:self.taste1]) {
        self.tasteRating = @(1);
    }else if ([ratingButton isEqual:self.taste2]){
        self.tasteRating = @(2);
    }else if ([ratingButton isEqual:self.taste3]){
        self.tasteRating = @(3);
    }else if ([ratingButton isEqual:self.taste4]){
        self.tasteRating = @(4);
    }else{
        self.tasteRating = @(5);
    }
    [self.delegate didRateTaste:self.tasteRating];
    [self highlightButtonsUpTo:self.tasteRating.integerValue];
}

- (void)highlightButtonsUpTo:(NSUInteger)num{
    //Reset all colors first
    for (UIButton *tasteButton in self.buttonArray) {
        [tasteButton setBackgroundColor:[UIColor clearColor]];
    }
    
    //Fill based on rating
    for (int i = 0; i < num; ++i) {
        UIButton *tasteButton = self.buttonArray[i];
        [tasteButton setBackgroundColor:[UIColor cyanColor]];
    }
}

@end
