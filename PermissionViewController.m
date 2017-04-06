//
//  PermissionViewController.m
//  Foodhead
//
//  Created by Brian Wong on 3/16/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "PermissionViewController.h"
#import "LocationManager.h"
#import "AppDelegate.h"
#import "UIFont+Extension.h"

@interface PermissionViewController () <LocationManagerDelegate>

@property (nonatomic, strong)LocationManager *manager;

@property (nonatomic, strong) UILabel *locationPrompt;
@property (nonatomic, strong) UITextView *locationText;
@property (nonatomic, strong) UIButton *permissionButton;
@property (nonatomic, strong) UIImageView *pinImg;
@property (nonatomic, strong) UIButton *skipButton;

@end

@implementation PermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.locationPrompt = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - self.view.frame.size.width * 0.3, self.view.frame.size.height * 0.12, self.view.frame.size.width * 0.6, self.view.frame.size.height * 0.07)];
    self.locationPrompt.text = @"Enable location";
    self.locationPrompt.font = [UIFont nun_boldFontWithSize:self.locationPrompt.frame.size.height * 0.5];
    self.locationPrompt.backgroundColor = [UIColor clearColor];
    self.locationPrompt.textColor = [UIColor blackColor];
    self.locationPrompt.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.locationPrompt];
    
    self.locationText = [[UITextView alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - self.view.frame.size.width * 0.45, CGRectGetMaxY(self.locationPrompt.self.frame) + self.view.frame.size.height * 0.07, self.view.frame.size.width * 0.9, self.view.frame.size.height * 0.15)];
    self.locationText.editable = NO;
    self.locationText.font = [UIFont nun_fontWithSize:self.locationText.frame.size.height * 0.2];
    self.locationText.userInteractionEnabled = NO;
    self.locationText.text = @"Foodhead requires location access to suggest restaurants near you";
    self.locationText.textAlignment = NSTextAlignmentCenter;
    self.locationText.backgroundColor = [UIColor clearColor];
    self.locationText.textColor = [UIColor grayColor];
    [self.view addSubview:self.locationText];
    
    self.pinImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.05, CGRectGetMaxY(self.locationText.frame) + self.view.frame.size.height * 0.05, self.view.frame.size.width * 0.1, self.view.frame.size.height * 0.1)];
    self.pinImg.backgroundColor = [UIColor clearColor];
    self.pinImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.pinImg setImage:[UIImage imageNamed:@"location_permission"]];
    [self.view addSubview:self.pinImg];
    
    self.permissionButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - self.view.frame.size.width * 0.4, CGRectGetMaxY(self.pinImg.frame) + self.view.frame.size.height * 0.04, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.1)];
    self.permissionButton.layer.cornerRadius = self.permissionButton.frame.size.height/2;
    self.permissionButton.backgroundColor = APPLICATION_BLUE_COLOR;
    self.permissionButton.titleLabel.font = [UIFont nun_boldFontWithSize:self.permissionButton.frame.size.height * 0.3];
    [self.permissionButton setTitle:@"Allow" forState:UIControlStateNormal];
    [self.permissionButton addTarget:self action:@selector(requestLocationAuth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.permissionButton];
}

- (void)requestLocationAuth
{
    [LocationManager sharedLocationInstance].locationDelegate = self;
    [[LocationManager sharedLocationInstance]checkLocationAuthorization];
}

- (void)locationWasAuthorizedWithStatus:(CLAuthorizationStatus)status{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate changeRootViewControllerFor:RootViewTypeCharts withAnimation:YES];
}

@end
