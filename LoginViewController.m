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
#import "LayoutBounds.h"
#import "PermissionViewController.h"
#import "LocationManager.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <SDWebImage/UIImage+GIF.h>

#import "UIFont+Extension.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UILabel *loginTitle;
@property (nonatomic, strong) UILabel *loginCaption;

@property (nonatomic, strong) UIImageView *owlImage;
@property (nonatomic, strong) UIImageView *splashImage;

@property (nonatomic, strong) UserAuthManager *authManager;
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) UIButton *fbLoginButton;
@property (nonatomic, strong) UIButton *skipLoginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.authManager = [UserAuthManager sharedInstance];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)setupUI{
    [self.navigationController.navigationBar setHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.splashImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.splashImage.backgroundColor = [UIColor whiteColor];
    self.splashImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.splashImage setImage:[UIImage imageNamed:@"login_background"]];
    [self.view addSubview:self.splashImage];
    
    if (self.isOnboarding) {
        self.owlImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.29, self.view.frame.size.height * 0.15, self.view.frame.size.width * 0.58, self.view.frame.size.height * 0.3)];
    }else{
        self.owlImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.225, self.view.frame.size.height * 0.15, self.view.frame.size.width * 0.45, self.view.frame.size.height * 0.28)];
    }
    self.owlImage.contentMode = UIViewContentModeScaleAspectFit;
    self.owlImage.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.owlImage];
    
    self.loginCaption = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.45, CGRectGetMaxY(self.owlImage.frame), self.view.frame.size.width * 0.9, self.view.frame.size.height * 0.1)];
    self.loginCaption.backgroundColor = [UIColor clearColor];
    self.loginCaption.textAlignment = NSTextAlignmentCenter;
    self.loginCaption.numberOfLines = 0;
    self.loginCaption.font = [UIFont nun_mediumFontWithSize:self.loginCaption.frame.size.height * 0.3];
    self.loginCaption.textColor = [UIColor whiteColor];
    [self.view addSubview:self.loginCaption];
    
    self.fbLoginButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.4, self.view.frame.size.height * 0.75, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.08)];
    self.fbLoginButton.layer.cornerRadius = self.fbLoginButton.frame.size.height/2;
    self.fbLoginButton.backgroundColor = UIColorFromRGB(0x718BEC);
    self.fbLoginButton.titleLabel.font = [UIFont nun_mediumFontWithSize:self.fbLoginButton.frame.size.height * 0.35];
    [self.fbLoginButton setTitle:@"Sign up with Facebook" forState:UIControlStateNormal];
    [self.fbLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.fbLoginButton addTarget:self action:@selector(didPressLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fbLoginButton];
    
    self.skipLoginButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.2, CGRectGetMaxY(self.fbLoginButton.frame) + self.view.frame.size.height * 0.02, self.view.frame.size.width * 0.4, self.view.frame.size.height * 0.05)];
    self.skipLoginButton.backgroundColor = [UIColor clearColor];
    self.skipLoginButton.titleLabel.font  = [UIFont nun_mediumFontWithSize:self.skipLoginButton.frame.size.height * 0.5];
    [self.skipLoginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.skipLoginButton addTarget:self action:@selector(didPressSkip) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipLoginButton];
    
    if (self.isOnboarding) {
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.3, self.view.frame.size.height * 0.04, self.view.frame.size.width * 0.6, self.view.frame.size.height * 0.08)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"Foodhead";
        titleLabel.font = [UIFont nun_boldFontWithSize:self.view.frame.size.height * 0.06];
        titleLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:titleLabel];
        
        self.loginCaption.text = @"Mouth orgasms, delivered daily";
        [self.loginCaption sizeToFit];
        self.loginCaption.center = CGPointMake(self.view.frame.size.width/2, CGRectGetMaxY(self.owlImage.frame) + self.loginCaption.frame.size.height * 0.5);
        [self.owlImage setImage:[UIImage sd_animatedGIFNamed:@"logo"]];
        [self.skipLoginButton setTitle:@"Skip" forState:UIControlStateNormal];
    }else{
        self.loginCaption.font = [UIFont nun_mediumFontWithSize:self.loginCaption.frame.size.height * 0.3];
        self.loginCaption.text = @"Create a free account to favorite\nrestaurants, videos, & more";
        [self.loginCaption sizeToFit];
        self.loginCaption.center = CGPointMake(self.view.frame.size.width/2, CGRectGetMaxY(self.owlImage.frame) + self.loginCaption.frame.size.height * 0.5);
        [self.owlImage setImage:[UIImage imageNamed:@"owl_openarms"]];
        [self.skipLoginButton setTitle:@"Go back" forState:UIControlStateNormal];
      }
}

#pragma LoginViewDelegate methods

//To be called from callback when we recieve auth token or user skips
- (void)didPressSkip{
    if (self.isOnboarding) {
        [self.authManager loginAnonymously];
//        UsernamePromptViewController *namePromptVC = [[UsernamePromptViewController alloc]init];
//        [self.navigationController pushViewController:namePromptVC animated:YES];
        PermissionViewController *permissionVC = [[PermissionViewController alloc]init];
        [self.navigationController pushViewController:permissionVC animated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)didPressLogin{
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc]init];
    [manager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_location"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            //NSLog(@"%@", error.description);
        }else if (result.isCancelled){
            //Cancelled
        }else{
            //Logged in
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
            [SVProgressHUD setForegroundColor:APPLICATION_BLUE_COLOR];
            [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
            [SVProgressHUD setFont:[UIFont nun_fontWithSize:16.0]];
            [SVProgressHUD showWithStatus:@"Logging in"];
            [self.authManager loginWithFb:[result token] completionHandler:^(User *userResponse) {
                [SVProgressHUD dismiss];
                if(userResponse){
                    [SVProgressHUD dismiss];
                    User *currentUser = userResponse;
                    if ([currentUser.username isEqualToString:@""]) {
                        //New user or anon rating flow
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UsernamePromptViewController *userPrompt = [[UsernamePromptViewController alloc]init];
                            userPrompt.isOnboarding = self.isOnboarding;
                            userPrompt.currentUser = currentUser;
                            [self.navigationController pushViewController:userPrompt animated:YES];
                        });
                    }else{//User has signed up before and created account, but either deleted app or is using a new, unauthorized phone.
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.isOnboarding) {
                                PermissionViewController *permissionView = [[PermissionViewController alloc]init];
                                [self.navigationController pushViewController:permissionView animated:YES];
                            }else{
                                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                    [[NSNotificationCenter defaultCenter]postNotificationName:SIGNUP_NOTIFICATION object:nil];
                                }];
                            }
                        });
                    }
                }
            } failureHandler:^(id error) {
                [SVProgressHUD dismiss];
                UIAlertController *usernameFail = [UIAlertController alertControllerWithTitle:@"Failed to sign up" message:@"Sorry, there was a problem when trying to sign you up. Please check your connection and try again!" preferredStyle:UIAlertControllerStyleAlert];
                [usernameFail addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:usernameFail animated:YES completion:nil];
            }];
        }
    }];
}

#pragma mark - UIWebViewDelegate methods

//- (void)instaLogin{
//    NSString *instaURL = @"https://api.instagram.com/oauth/authorize/?client_id=000aae551418404b91d05cf81a21ea55&redirect_uri=http://Foodheadapp.com&response_type=token&scope=public_content";
//    
//    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.frame];
//    webView.delegate = self;
//    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:instaURL]];
//    
//    [self.view addSubview:webView];
//    [webView loadRequest:req];
//}
//
//// Grab the access token when insta calls our redirect URI
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    //Check here if host is insta or FB, pull out auth_token then store in keychain
//    NSURL *responseURL = [request URL];
//    NSString *responseString = [responseURL absoluteString];
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

@end
