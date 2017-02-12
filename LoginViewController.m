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
#import "FoodWiseDefines.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController () <UIWebViewDelegate, FBSDKLoginButtonDelegate>

@property (nonatomic, strong)UILabel *loginTitle;

@property (nonatomic, strong)UserAuthManager *userAuth;
@property (nonatomic, strong)UIWebView *webView;

@property (nonatomic, strong)FBSDKLoginButton *fbLoginButton;
@property (nonatomic, strong)UIButton *instaLoginButton;
@property (nonatomic, strong)UIButton *skipLoginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userAuth = [[UserAuthManager alloc]init];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.webView = [[UIWebView alloc]init];
    self.webView.delegate = self;
    self.webView.scrollView.scrollEnabled = NO;
    
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
    
    self.instaLoginButton = [[UIButton alloc]initWithFrame:self.fbLoginButton.frame];
    self.instaLoginButton.backgroundColor = [UIColor purpleColor];
    self.instaLoginButton.center = CGPointMake(self.view.frame.size.width/2, CGRectGetMaxY(self.fbLoginButton.frame) + self.view.frame.size.height * 0.1);
    [self.instaLoginButton setTitle:@"Login with Instagram" forState:UIControlStateNormal];
    [self.instaLoginButton addTarget:self action:@selector(loginWithInstagram) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.instaLoginButton];
    
    self.skipLoginButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.25, CGRectGetMaxY(self.instaLoginButton.frame) + self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.2)];
    self.skipLoginButton.backgroundColor = [UIColor clearColor];
    [self.skipLoginButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipLoginButton addTarget:self action:@selector(loginWasSuccessful) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipLoginButton];
}

- (void)loginWithInstagram{
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame), self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.webView];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect webViewFrame = self.webView.frame;
        webViewFrame.origin.y = 0;
        self.webView.frame = webViewFrame;
        
        NSString *instaUrlString = [NSString stringWithFormat:INSTAGRAM_AUTH_URL, INSTAGRAM_CLIENT_ID, REDIRECT_URI];
        NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:instaUrlString]];
        [self.webView scalesPageToFit];
        [self.webView loadRequest: urlReq];
    }completion:^(BOOL finished) {
    }];
}

//To be called from callback when we recieve auth token or user skips
- (void)loginWasSuccessful{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate changeRootViewControllerFor:RootViewTypeCharts];

#warning - Throw NSNotification here to fetch charts data
}

#pragma mark - UIWebViewDelegate methods


// Grab the access token when insta calls our redirect URI
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //Check here if host is insta or FB, pull out auth_token then store in keychain
    NSURL *responseURL = [request URL];
    NSString *responseString = [responseURL absoluteString];
    
#warning TODO: Delete auth_token from keychain when user logs out in profile page 
    
    //Parse out auth_token
    NSRange access_token_range = [responseString rangeOfString:@"access_token="];
    if (access_token_range.length > 0) {
        int from_index = (int)(access_token_range.location + access_token_range.length);
        NSString *access_token = [responseString substringFromIndex:from_index];

        //Save token here to keychain
//        [SAMKeychain setPassword:access_token forService:INSTAGRAM_SERVICE account:KEYCHAIN_ACCOUNT];
//        NSLog(@"////USER_ACCESS_TOKEN////: %@", [SAMKeychain passwordForService:INSTAGRAM_SERVICE account:KEYCHAIN_ACCOUNT]);
        
        NSLog(@"%@", access_token);

        //Animate this better?
        [self loginWasSuccessful];
        return NO;
    }

    //If auth token is valid, dismiss VC. If not present view and dismiss webview
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@", error.localizedDescription);
}


#pragma mark - FBSDKLoginButtonDelegate methods

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    if([result token]){
        [self loginWasSuccessful];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

@end
