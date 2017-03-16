//
//  LoginViewController.m
//  FoodWise
//
//  Created by Brian Wong on 1/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "LoginViewController.h"
#import "UserAuthManager.h"
#import "AppDelegate.h"
#import "UsernamePromptViewController.h"
#import "FoodWiseDefines.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController () <UIWebViewDelegate, FBSDKLoginButtonDelegate>

@property (nonatomic, strong) UILabel *loginTitle;

@property (nonatomic, strong) UserAuthManager *authManager;
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) FBSDKLoginButton *fbLoginButton;
@property (nonatomic, strong) UIButton *skipLoginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.authManager = [UserAuthManager sharedInstance];
    
    [self setupUI];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    //FB provides default
    self.fbLoginButton = [[FBSDKLoginButton alloc]init];
    self.fbLoginButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height * 0.5);
    self.fbLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.fbLoginButton.delegate = self;
    [self.view addSubview:self.fbLoginButton];
    
    self.skipLoginButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.8 - self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.2)];
    self.skipLoginButton.backgroundColor = [UIColor clearColor];
    [self.skipLoginButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipLoginButton addTarget:self action:@selector(didPressSkip) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipLoginButton];
}


//To be called from callback when we recieve auth token or user skips
- (void)loginWasSuccessful{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate changeRootViewControllerFor:RootViewTypeCharts];
}

- (void)didPressSkip{
    [self.authManager loginAnonymously];
    [self loginWasSuccessful];
}

#pragma mark - UIWebViewDelegate methods


// Grab the access token when insta calls our redirect URI
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    //Check here if host is insta or FB, pull out auth_token then store in keychain
//    NSURL *responseURL = [request URL];
//    NSString *responseString = [responseURL absoluteString];
//    
//#warning TODO: Delete auth_token from keychain when user logs out in profile page 
//    
//    //Parse out auth_token
//    NSRange access_token_range = [responseString rangeOfString:@"access_token="];
//    if (access_token_range.length > 0) {
//        int from_index = (int)(access_token_range.location + access_token_range.length);
//        NSString *access_token = [responseString substringFromIndex:from_index];
//
//        //Save token here to keychain
////        [SAMKeychain setPassword:access_token forService:INSTAGRAM_SERVICE account:KEYCHAIN_ACCOUNT];
////        NSLog(@"////USER_ACCESS_TOKEN////: %@", [SAMKeychain passwordForService:INSTAGRAM_SERVICE account:KEYCHAIN_ACCOUNT]);
//        
//        NSLog(@"%@", access_token);
//
//        //Animate this better?
//        [self loginWasSuccessful];
//        return NO;
//    }
//
//    //If auth token is valid, dismiss VC. If not present view and dismiss webview
//    return YES;
//}

#pragma mark - FBSDKLoginButtonDelegate methods

- (void)loginButton:(FBSDKLoginButton *)loginButton
            didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error{
    
#warning Need to present some kind of placeholder screen for login so they don't see Facebook logout button
    
    [self.authManager loginWithFb:[result token] completionHandler:^(id authResponse) {
        if(authResponse){
            NSLog(@"LOGIN RESPONSE: %@", authResponse);
            dispatch_async(dispatch_get_main_queue(), ^{
                //Check if user is logging in for the first time by retrieving user info. If no username, prompt for it. If not, just pass to charts
                [self loginWasSuccessful];
            });
        }
    } failureHandler:^(id error) {
        NSLog(@"Failed FB LOGIN: %@", error);
    }];
}

@end
