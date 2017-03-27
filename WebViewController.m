//
//  MenuViewController.m
//  Foodhead
//
//  Created by Brian Wong on 3/16/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "MenuViewController.h"

@import WebKit;

@interface MenuViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationController.navigationBar.
    
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.menuLink]]];
    [self.view addSubview:self.webView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 22.0, self.view.frame.size.height/2, 44.0, 44.0)];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicator.color = [UIColor grayColor];
    [self.view addSubview:self.activityIndicator];
    
}

- (void)exitMenu
{
    [self.navigationController popViewControllerAnimated:YES];
}


//Activity indic
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}



@end
