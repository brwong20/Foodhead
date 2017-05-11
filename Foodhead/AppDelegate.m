//
//  AppDelegate.m
//  FoodWise
//
//  Created by Brian Wong on 1/12/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "AppDelegate.h"
#import "UserAuthManager.h"
#import "LoginViewController.h"
#import "ChartsViewController.h"
#import "TabCameraViewController.h"
#import "UserProfileViewController.h"
#import "FoodWiseDefines.h"
#import "FoodheadAnalytics.h"
#import "SearchViewController.h"
#import "DiscoverViewController.h"
#import "BrowseViewController.h"

#import "Flurry.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL fbLaunched = [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

#if PRODUCTION
    [FoodheadAnalytics beginFlurrySession];
#endif
    
    //Must create window here ourselves if not using storyboard
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    //Check if user has a valid login or if they skipped - need an NSUserDefault for skipped?
    UserAuthManager *authManager = [UserAuthManager sharedInstance];
    if ([authManager isUserLoggedIn]) {
        [self changeRootViewControllerFor:RootViewTypeCharts withAnimation:NO];
    }else{
        [self changeRootViewControllerFor:RootViewTypeLogin withAnimation:NO];
    }
    return fbLaunched;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)changeRootViewControllerFor:(RootViewType)type withAnimation:(BOOL)animation{
    UIViewController *root = nil;
    if(type == RootViewTypeLogin){
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        loginVC.isOnboarding = YES;
        UINavigationController *loginNav = [[UINavigationController alloc]initWithRootViewController:loginVC];
        root = loginNav;
        
        [self.window setRootViewController:root];
        [self.window makeKeyAndVisible];
    }
    else if (type == RootViewTypeCharts){
        self.tabBarController = [[UITabBarController alloc]init];
        [[UITabBar appearance]setBackgroundColor:[UIColor whiteColor]];
        self.tabBarController.tabBar.translucent = NO;
    
        //ChartsViewController *chartsVC = [[ChartsViewController alloc]init];
        DiscoverViewController *discoverVC = [[DiscoverViewController alloc]init];
        UINavigationController *chartsNav = [[UINavigationController alloc]initWithRootViewController:discoverVC];
        
        SearchViewController *searchVC = [[SearchViewController alloc]init];
        UINavigationController *searchNav = [[UINavigationController alloc]initWithRootViewController:searchVC];
        
        BrowseViewController *browseVC = [[BrowseViewController alloc]init];
        //TabCameraViewController *camVC = [[TabCameraViewController alloc]init];
        UINavigationController *browseNav = [[UINavigationController alloc]initWithRootViewController:browseVC];
        
        UserProfileViewController *profileVC = [[UserProfileViewController alloc]init];
        UINavigationController *profileNav = [[UINavigationController alloc]initWithRootViewController:profileVC];
        
        NSArray *controllers = [NSArray arrayWithObjects:chartsNav, browseNav, searchNav ,profileNav, nil];
        self.tabBarController.viewControllers = controllers;
        
        UIEdgeInsets tabItemInsets = UIEdgeInsetsMake(7.0, 0.0, -7.0, 0.0);
        
        discoverVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"home"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        discoverVC.tabBarItem.imageInsets = tabItemInsets;
        discoverVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_active"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        discoverVC.tabBarItem.tag = CHART_TAB_TAG;
        
        browseVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"browse"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        browseVC.tabBarItem.imageInsets = tabItemInsets;
        browseVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"browse_active"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        browseVC.tabBarItem.tag = BROWSE_TAB_TAG;
        
        searchVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"search"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        searchVC.tabBarItem.imageInsets = tabItemInsets;
        searchVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"search_active"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        searchVC.tabBarItem.tag = SEARCH_TAB_TAG;

        profileVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"profile"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        profileVC.tabBarItem.imageInsets = tabItemInsets;
        profileVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"profile_active"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        profileVC.tabBarItem.tag = PROFILE_TAB_TAG;
        
        self.window.backgroundColor = [UIColor whiteColor];
        root = self.tabBarController;
        [self.window makeKeyAndVisible];
        
        if(animation){
            [UIView transitionWithView:self.window duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.window setRootViewController:root];
                [self.window makeKeyAndVisible];
            } completion:nil];
        }else{
            [self.window setRootViewController:root];
            [self.window makeKeyAndVisible];
        }
        
        //Pre load the video metadata on app launch
        for(UINavigationController * viewController in self.tabBarController.viewControllers){
//            if ([viewController isKindOfClass:[BrowseViewController class]]) {
                [[viewController.viewControllers firstObject] view];
//            }
        }
    }
}

@end
