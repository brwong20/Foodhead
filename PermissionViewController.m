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
#import "LayoutBounds.h"

#import <UserNotifications/UserNotifications.h>

@interface PermissionViewController () <LocationManagerDelegate>

@property (nonatomic, strong)LocationManager *manager;

@property (nonatomic, strong) UILabel *locationPrompt;
@property (nonatomic, strong) UITextView *locationText;
@property (nonatomic, strong) UILabel *locationCaption;
@property (nonatomic, strong) UIButton *permissionButton;
@property (nonatomic, strong) UIImageView *pinImg;
@property (nonatomic, strong) UIButton *skipButton;

@property (nonatomic, strong) UNUserNotificationCenter *notifCenter;
@property (nonatomic, strong) UIButton *notificationButton;

@property (nonatomic, assign) BOOL locationDone;
@property (nonatomic, assign) BOOL notificationDone;

@end

@implementation PermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.notifCenter = [UNUserNotificationCenter currentNotificationCenter];
    
    self.locationDone = NO;
    self.notificationDone = NO;
    
    self.locationPrompt = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - self.view.frame.size.width * 0.3, self.view.frame.size.height * 0.15, self.view.frame.size.width * 0.6, self.view.frame.size.height * 0.05)];
    self.locationPrompt.text = @"Enable permissions";
    self.locationPrompt.font = [UIFont nun_mediumFontWithSize:self.view.frame.size.width * 0.05];
    self.locationPrompt.backgroundColor = [UIColor clearColor];
    self.locationPrompt.textColor = [UIColor blackColor];
    self.locationPrompt.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.locationPrompt];
    
    self.locationText = [[UITextView alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - self.view.frame.size.width * 0.45, CGRectGetMaxY(self.locationPrompt.self.frame) + self.view.frame.size.height * 0.04, self.view.frame.size.width * 0.9, self.view.frame.size.height * 0.09)];
    self.locationText.editable = NO;
    self.locationText.font = [UIFont nun_fontWithSize:self.view.frame.size.width * 0.05];
    self.locationText.userInteractionEnabled = NO;
    self.locationText.text = @"Foodhead needs location access to\nshow you the best nearby restaurants";
    self.locationText.textAlignment = NSTextAlignmentCenter;
    self.locationText.backgroundColor = [UIColor clearColor];
    self.locationText.textColor = UIColorFromRGB(0x4D4E51);
    [self.view addSubview:self.locationText];
    
    self.locationCaption = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - self.view.frame.size.width * 0.45, CGRectGetMaxY(self.locationText.self.frame), self.view.frame.size.width * 0.9, self.view.frame.size.height * 0.04)];
    self.locationCaption.backgroundColor = [UIColor clearColor];
    self.locationCaption.text = @"(we never share your location!)";
    self.locationCaption.font = [UIFont nun_fontWithSize:self.view.frame.size.width * 0.035];
    self.locationCaption.textAlignment = NSTextAlignmentCenter;
    self.locationCaption.textColor = UIColorFromRGB(0x4D4E51);
    [self.view addSubview:self.locationCaption];
    
    self.pinImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.05, CGRectGetMaxY(self.locationCaption.frame) + self.view.frame.size.height * 0.03, self.view.frame.size.width * 0.1, self.view.frame.size.height * 0.1)];
    self.pinImg.backgroundColor = [UIColor clearColor];
    self.pinImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.pinImg setImage:[UIImage imageNamed:@"location_permission"]];
    [self.view addSubview:self.pinImg];
    
    self.permissionButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - self.view.frame.size.width * 0.39, CGRectGetMaxY(self.pinImg.frame) + self.view.frame.size.height * 0.02, self.view.frame.size.width * 0.78, self.view.frame.size.height * 0.09)];
    self.permissionButton.layer.cornerRadius = self.permissionButton.frame.size.height/2;
    self.permissionButton.backgroundColor = [UIColor whiteColor];
    self.permissionButton.layer.borderColor = APPLICATION_BLUE_COLOR.CGColor;
    self.permissionButton.layer.borderWidth = 2.0;
    self.permissionButton.titleLabel.font = [UIFont nun_mediumFontWithSize:self.permissionButton.frame.size.height * 0.3];
    [self.permissionButton setTitleColor:APPLICATION_BLUE_COLOR forState:UIControlStateNormal];
    [self.permissionButton setTitle:@"Location" forState:UIControlStateNormal];
    [self.permissionButton addTarget:self action:@selector(requestLocationAuth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.permissionButton];
    
    self.notificationButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - self.view.frame.size.width * 0.39, CGRectGetMaxY(self.permissionButton.frame) + self.view.frame.size.height * 0.02, self.view.frame.size.width * 0.78, self.view.frame.size.height * 0.09)];
    self.notificationButton.layer.cornerRadius = self.notificationButton.frame.size.height/2;
    self.notificationButton.backgroundColor = [UIColor whiteColor];
    self.notificationButton.layer.borderColor = APPLICATION_BLUE_COLOR.CGColor;
    self.notificationButton.layer.borderWidth = 2.0;
    self.notificationButton.titleLabel.font = [UIFont nun_mediumFontWithSize:self.notificationButton.frame.size.height * 0.3];
    [self.notificationButton setTitleColor:APPLICATION_BLUE_COLOR forState:UIControlStateNormal];
    [self.notificationButton setTitle:@"Notifications" forState:UIControlStateNormal];
    [self.notificationButton addTarget:self action:@selector(promptPushPermission) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.notificationButton];
}

- (void)requestLocationAuth
{
    [LocationManager sharedLocationInstance].locationDelegate = self;
    [[LocationManager sharedLocationInstance]checkLocationAuthorization];
}

- (void)promptPushPermission{
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge;
    [self.notifCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        self.notificationDone = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                self.notificationButton.backgroundColor = APPLICATION_BLUE_COLOR;
                [self.notificationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }completion:^(BOOL finished) {
                [self checkBothPermissionsDone];
            }];
        });
    }];
}

- (void)locationWasAuthorizedWithStatus:(CLAuthorizationStatus)status{
    self.locationDone = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.permissionButton.backgroundColor = APPLICATION_BLUE_COLOR;
        [self.permissionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }completion:^(BOOL finished) {
        [self checkBothPermissionsDone];
    }];
}

- (void)checkBothPermissionsDone{
    if (self.notificationDone && self.notificationDone) {
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate changeRootViewControllerFor:RootViewTypeCharts withAnimation:YES];
    }
}

@end
