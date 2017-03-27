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

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UILabel *loginTitle;

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

- (void)setupUI{
    [self.navigationController.navigationBar setHidden:YES];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.fbLoginButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.25, self.view.frame.size.height/2.5, self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.2)];
    [self.fbLoginButton setTitle:@"FB LOGIN" forState:UIControlStateNormal];
    self.fbLoginButton.backgroundColor = [UIColor cyanColor];
    [self.fbLoginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fbLoginButton];
    
    self.skipLoginButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.8 - self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.2)];
    self.skipLoginButton.backgroundColor = [UIColor clearColor];
    [self.skipLoginButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipLoginButton addTarget:self action:@selector(didPressSkip) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipLoginButton];
    
//    UIButton *instaButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 200.0, 50.0)];
//    instaButton.backgroundColor = [UIColor purpleColor];
//    instaButton.center = CGPointMake(self.view.frame.size.width/2, CGRectGetMaxY(self.fbLoginButton.frame) + 30.0);
//    [instaButton setTitle:@"Insta" forState:UIControlStateNormal];
//    [instaButton addTarget:self action:@selector(instaLogin) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:instaButton];
}


//To be called from callback when we recieve auth token or user skips
- (void)loginWasSuccessful{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate changeRootViewControllerFor:RootViewTypeCharts withAnimation:YES];
}

- (void)didPressSkip{
    [self.authManager loginAnonymously];
    [self loginWasSuccessful];
}


- (void)loginButtonClicked{
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc]init];
    [manager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"%@", error.description);
        }else if (result.isCancelled){
            //Cancelled
        }else{
            //Logged in
            [SVProgressHUD show];
            [self.authManager loginWithFb:[result token] completionHandler:^(User *userResponse) {
                if(userResponse){
                    NSLog(@"LOGIN RESPONSE: %@", userResponse);
                    
                    User *currentUser = userResponse;
                    if (!currentUser.username) {//New user
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            UsernamePromptViewController *userPrompt = [[UsernamePromptViewController alloc]init];
                            userPrompt.currentUser = currentUser;
                            [self.navigationController pushViewController:userPrompt animated:YES];
                        });
                    }else{//User has already signed up before, but deleted app or signed on different phone so just ask them for permissions if the device isn't authorized
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            //Not possible right now since no log out
//                            if ([LocationManager sharedLocationInstance].authorizedStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
//                                [self loginWasSuccessful];
//                            }else{
                                PermissionViewController *permissionView = [[PermissionViewController alloc]init];
                                [self.navigationController pushViewController:permissionView animated:YES];
//                            }
                        });
                    }
                }
            } failureHandler:^(id error) {
                NSLog(@"Failed FB LOGIN: %@", error);
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
