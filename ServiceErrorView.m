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

@property (nonatomic, strong) UITapGestureRecognizer *refreshGesture;

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
        
        //[LayoutBounds drawBoundsForAllLayers:self];
        
    }
    return self;
}

- (void)showErrorMessage{
    //Either no service or no location
    if (_errorType == ServiceErrorTypeLocation) {
        self.errorTextView.text = @"We need location access to\nsuggest you restuaurants.\n\nGo to Settings > Privacy >\nLocation Services > turn on Foodhead";
    }else if (_errorType == ServiceErrorTypeData){
        self.errorTextView.text = @"Please check your connection then tap to retry!";
        self.refreshGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapRefresh)];
        self.refreshGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:self.refreshGesture];
    }
}

- (void)didTapRefresh{
    if ([self.delegate respondsToSelector:@selector(serviceErrorViewToggledRefresh)]) {
        [self.delegate serviceErrorViewToggledRefresh];
    }
}

- (void)startRefreshing{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setForegroundColor:APPLICATION_BLUE_COLOR];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD show];
}

- (void)stopRefreshing{
    [SVProgressHUD dismiss];
}

@end
