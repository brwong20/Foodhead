//
//  ServiceErrorView.m
//  Foodhead
//
//  Created by Brian Wong on 3/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "ServiceErrorView.h"
#import "UIFont+Extension.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "LayoutBounds.h"

@interface ServiceErrorView ()

@property (nonatomic, strong) UILabel *errorTitle;
@property (nonatomic, strong) UITextView *errorTextView;
@property (nonatomic, strong) UIImageView *errorImgView;

//Refresh for charts
@property (nonatomic, strong) UITapGestureRecognizer *refreshGesture;
@property (nonatomic, strong) UIActivityIndicatorView *refreshIndicator;

@end

@implementation ServiceErrorView

- (instancetype)initWithFrame:(CGRect)frame andErrorType:(ServiceErrorType)errorType{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.errorType = errorType;
        
        self.errorTitle = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.2, frame.size.height * 0.15, frame.size.width * 0.4, frame.size.height * 0.1)];
        self.errorTitle.backgroundColor = [UIColor clearColor];
        self.errorTitle.textAlignment = NSTextAlignmentCenter;
        self.errorTitle.text = @"Uh-oh!";
        self.errorTitle.font = [UIFont nun_boldFontWithSize:frame.size.height * 0.035];
        [self addSubview:self.errorTitle];
        
        self.errorTextView = [[UITextView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.425, CGRectGetMaxY(self.errorTitle.frame), frame.size.width * 0.85, frame.size.height * 0.3)];
        self.errorTextView.backgroundColor = [UIColor clearColor];
        self.errorTextView.textAlignment = NSTextAlignmentCenter;
        self.errorTextView.editable = NO;
        self.errorTextView.userInteractionEnabled = NO;
        self.errorTextView.textColor = UIColorFromRGB(0x4D4E51);
        self.errorTextView.font = [UIFont nun_fontWithSize:frame.size.height * 0.025];
        [self showErrorMessage];
        [self addSubview:self.errorTextView];
        
        self.errorImgView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.17, CGRectGetMaxY(self.errorTextView.frame), frame.size.width * 0.34, frame.size.height * 0.25)];
        self.errorImgView.contentMode = UIViewContentModeScaleAspectFit;
        self.errorImgView.backgroundColor = [UIColor clearColor];
        [self.errorImgView setImage:[UIImage imageNamed:@"owl_dead"]];
        [self addSubview:self.errorImgView];
        
        self.refreshGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapRefresh)];
        self.refreshGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:self.refreshGesture];
        
        self.refreshIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.refreshIndicator.center = CGPointMake(self.center.x, self.center.y - self.bounds.size.height * 0.12);
        CGAffineTransform scaleUp = CGAffineTransformMakeScale(1.4, 1.4);
        self.refreshIndicator.transform = scaleUp;
        self.refreshIndicator.hidesWhenStopped = YES;
        [self addSubview:self.refreshIndicator];        
    }
    return self;
}

- (void)showErrorMessage{
    //Either no service or no location
    if (_errorType == ServiceErrorTypeLocation) {
        self.errorTextView.text = @"We need location access to\nsuggest you restuaurants.\n\nGo to Settings > Privacy >\nLocation Services > turn on Foodhead";
    }else if (_errorType == ServiceErrorTypeData){
        self.errorTextView.text = @"Please check your connection then tap to reload restaurants near you!";
        self.refreshGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapRefresh)];
        self.refreshGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:self.refreshGesture];
    }
}

- (void)didTapRefresh{
    if ([self.delegate respondsToSelector:@selector(serviceErrorViewToggledRefresh)] && !self.refreshIndicator.isAnimating) {
        [self.delegate serviceErrorViewToggledRefresh];
        
        if (_errorType == ServiceErrorTypeData) {
            [UIView animateWithDuration:0.25 animations:^{
                self.errorTitle.alpha = 0.0;
                self.errorTextView.alpha = 0.0;
                [self.refreshIndicator startAnimating];
            }];
        }
    }
}

- (void)stopRefreshing{
    if (_errorType == ServiceErrorTypeData) {
        [UIView animateWithDuration:0.25 animations:^{
            self.errorTitle.alpha = 1.0;
            self.errorTextView.alpha = 1.0;
            [self.refreshIndicator stopAnimating];
        }];
    }
}


@end
