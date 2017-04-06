//
//  UsernamePromptViewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/15/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UsernamePromptViewController.h"
#import "UserAuthManager.h"
#import "AppDelegate.h"
#import "PermissionViewController.h"
#import "UIFont+Extension.h"
#import "NSString+IsEmpty.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface UsernamePromptViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *usernamePrompt;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *skipButton;

@end

@implementation UsernamePromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.usernamePrompt = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - self.view.frame.size.width * 0.3, self.view.frame.size.height * 0.12, self.view.frame.size.width * 0.6, self.view.frame.size.height * 0.12)];
    self.usernamePrompt.numberOfLines = 2;
    self.usernamePrompt.textAlignment = NSTextAlignmentCenter;
    self.usernamePrompt.text = @"Create a username\nto finish signup";
    self.usernamePrompt.font = [UIFont nun_boldFontWithSize:self.usernamePrompt.frame.size.height * 0.25];
    self.usernamePrompt.textColor = [UIColor blackColor];
    self.usernamePrompt.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.usernamePrompt];
    
    self.usernameField  = [[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.4, CGRectGetMaxY(self.usernamePrompt.frame) + self.view.frame.size.height * 0.08, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.1)];
    self.usernameField.placeholder = @"Username (min. 6 characters)";
    self.usernameField.font = [UIFont nun_fontWithSize:self.view.frame.size.height * 0.03];
    self.usernameField.delegate = self;
    self.usernameField.backgroundColor = [UIColor clearColor];
    [self.usernameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.usernameField];
    
    UIView *nameLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.usernameField.frame) - self.view.frame.size.width * 0.02, CGRectGetMaxY(self.usernameField.frame) - self.usernameField.frame.size.height * 0.12, self.view.frame.size.width * 0.84, 1.0)];
    nameLine.backgroundColor = UIColorFromRGB(0xB0B0B0);
    nameLine.alpha = 0.7;
    [self.view addSubview:nameLine];
    
    self.doneButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.4, CGRectGetMaxY(self.usernameField.frame) + self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.1)];
    self.doneButton.backgroundColor = APPLICATION_BLUE_COLOR;
    self.doneButton.layer.cornerRadius = self.doneButton.frame.size.height/2;
    self.doneButton.titleLabel.font = [UIFont nun_boldFontWithSize:self.doneButton.frame.size.height * 0.3];
    self.doneButton.alpha = 0.0;
    [self.doneButton setTitle:@"Finish" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(submitUsername) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setEnabled:NO];
    [self.view addSubview:self.doneButton];
}

- (void)submitUsername{
    UserAuthManager *authManager = [UserAuthManager sharedInstance];
    NSDictionary *usernameParam = @{@"username" : self.usernameField.text};
    [authManager updateCurrentUserWithParams:usernameParam completionHandler:^(id user) {
        if (self.isOnboarding) {
            PermissionViewController *permissionVC = [[PermissionViewController alloc]init];
            [self.navigationController pushViewController:permissionVC animated:YES];
        }else{
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter]postNotificationName:SIGNUP_NOTIFICATION object:nil];
            }];
        }
    } failureHandler:^(id error) {
        NSDictionary *userInfo = [error userInfo];
        NSString* errorStr = userInfo[NSLocalizedDescriptionKey];
        if (![NSString isEmpty:errorStr]) {
            [SVProgressHUD setContainerView:self.view];
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
            [SVProgressHUD setForegroundColor:[UIColor redColor]];
            [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
            [SVProgressHUD setFont:[UIFont nun_fontWithSize:16.0]];
            [SVProgressHUD setMinimumDismissTimeInterval:1.5];
            if ([errorStr containsString:STATUS_CODE_CONFLICT]) {
                [SVProgressHUD showErrorWithStatus:@"Username taken"];
            }else if ([errorStr containsString:STATUS_NO_INTERNET]){//No connection to retrieve current user so use cached user info if there is any
                [SVProgressHUD showErrorWithStatus:@"There was an error creating your username. Please check your connection and try again!"];
            }
        }
    }];
}

- (void)textFieldDidChange:(UITextField *)textfield{
    NSRange whiteSpaceRange = [textfield.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];//Checks for white space
    if (textfield.text.length >= 6 && ![NSString isEmpty:textfield.text] && whiteSpaceRange.location == NSNotFound) {
        [UIView animateWithDuration:0.25 animations:^{
            self.doneButton.alpha = 1.0;
            [self.doneButton setEnabled:YES];
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.doneButton.alpha = 0.0;
           [self.doneButton setEnabled:NO];
        }];
    }
}



@end
