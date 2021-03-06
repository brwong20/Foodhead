//
//  WebViewController.m
//  Foodhead
//
//  Created by Brian Wong on 3/16/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "WebViewController.h"
#import "FoodWiseDefines.h"

#import <SVProgressHUD/SVProgressHUD.h>

@import WebKit;

@interface WebViewController () <WKNavigationDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.popupView) {
        self.navigationItem.title = @"Become a Foodhead";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"filter_exit_btn"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exitWebView)];
    }else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"arrow_back"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exitWebView)];
    }

    
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views
    self.webView.scrollView.contentInset = adjustForTabbarInsets;
    self.webView.scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webLink]]];
    [self.view addSubview:self.webView];
    
    [SVProgressHUD setContainerView:self.view];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    //[SVProgressHUD setMinimumSize:CGSizeMake(self.view.frame.size.width * 0.4, self.view.frame.size.width * 0.4)];
    [SVProgressHUD setForegroundColor:APPLICATION_BLUE_COLOR];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;//Preserves swipe back gesture
}

- (void)exitWebView
{
    if (_popupView) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [SVProgressHUD show];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [SVProgressHUD dismiss];
}

@end
