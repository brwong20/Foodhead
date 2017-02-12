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

@property (nonatomic, strong)UILabel *title;
@property (nonatomic, strong)UITextView *locationText;
@property (nonatomic, strong)UIButton *permissionButton;

@end

@implementation LocationPermissionView

- (instancetype)initWithFrame:(CGRect)frame{
    
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor cyanColor];
        
        //TODO: Setup UI - Button press prompts location permission
        self.permissionButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.5 - frame.size.width * 0.4, frame.size.height * 0.5 - frame.size.height * 0.1, frame.size.width * 0.8, frame.size.height * 0.2)];
        [self.permissionButton setTitle:@"Enabled permiss" forState:UIControlStateNormal];
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
