//
//  LocationPermissionView.m
//  FoodWise
//
//  Created by Brian Wong on 1/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "LocationPermissionView.h"
#import "LocationManager.h"

@interface LocationPermissionView() <LocationManagerDelegate>

@property (nonatomic, strong)LocationManager *manager;

@property (nonatomic, strong) UILabel *locationPrompt;
@property (nonatomic, strong) UITextView *locationText;
@property (nonatomic, strong) UIButton *permissionButton;

@end

@implementation LocationPermissionView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        self.locationPrompt = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width * 0.5 - frame.size.width * 0.3, frame.size.height * 0.14 - frame.size.height * 0.1, frame.size.width * 0.6, frame.size.height * 0.2)];
        self.locationPrompt.text = @"Enable location";
        self.locationPrompt.font = [UIFont systemFontOfSize:28.0];
        self.locationPrompt.backgroundColor = [UIColor clearColor];
        self.locationPrompt.textColor = [UIColor grayColor];
        self.locationPrompt.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.locationPrompt];
        
        self.locationText = [[UITextView alloc]initWithFrame:CGRectMake(frame.size.width * 0.5 - frame.size.width * 0.4, CGRectGetMaxY(self.locationPrompt.frame) + frame.size.height * 0.05, frame.size.width * 0.8, frame.size.height * 0.4)];
        self.locationText.editable = NO;
        self.locationText.font = [UIFont systemFontOfSize:26.0];
        self.locationText.userInteractionEnabled = NO;
        self.locationText.text = @"GIVE\nUS\nYOUR FUCKING\nLOCATION";
        self.locationText.textAlignment = NSTextAlignmentCenter;
        self.locationText.backgroundColor = [UIColor clearColor];
        self.locationText.textColor = [UIColor grayColor];
        [self addSubview:self.locationText];
        
        self.permissionButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.5 - frame.size.width * 0.3, frame.size.height * 0.8 - frame.size.height * 0.04, frame.size.width * 0.6, frame.size.height * 0.08)];
        self.permissionButton.layer.cornerRadius = 14.0;
        self.permissionButton.backgroundColor = [UIColor grayColor];
        [self.permissionButton setTitle:@"Enable" forState:UIControlStateNormal];
        [self.permissionButton addTarget:self action:@selector(requestLocationAuth) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.permissionButton];
    }
    
    return self;
}

- (void)requestLocationAuth
{
    [[LocationManager sharedLocationInstance]requestLocationAuthorization];
}


@end
