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
#import "SlideOutViewController.h"
#import "User.h"

#import "ChartsViewController.h"
#import "TabCameraViewController.h"
#import "UserProfileViewController.h"
#import "CameraViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL fbLaunched = [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

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
        UINavigationController *loginNav = [[UINavigationController alloc]initWithRootViewController:loginVC];
        root = loginNav;
        
        [self.window setRootViewController:root];
        [self.window makeKeyAndVisible];
    }
    else if (type == RootViewTypeCharts)
    {
        self.tabBarController = [[UITabBarController alloc]init];
    
        ChartsViewController *chartsVC = [[ChartsViewController alloc]init];
        UINavigationController *chartsNav = [[UINavigationController alloc]initWithRootViewController:chartsVC];
        
        TabCameraViewController *camVC = [[TabCameraViewController alloc]init];
        UINavigationController *camNav = [[UINavigationController alloc]initWithRootViewController:camVC];
        
        UserProfileViewController *profileVC = [[UserProfileViewController alloc]init];
        UINavigationController *profileNav = [[UINavigationController alloc]initWithRootViewController:profileVC];
        
        NSArray *controllers = [NSArray arrayWithObjects:chartsNav, camNav, profileNav, nil];
        self.tabBarController.viewControllers = controllers;
        
        //Pre-load the camera view so it's always ready the second a user clicks on the camera tab.
        NSArray *viewArr = self.tabBarController.viewControllers;
        UINavigationController *cam = [viewArr objectAtIndex:1];
        [[[cam viewControllers]firstObject]view];
        
        chartsVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"home_tab"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        chartsVC.tabBarItem.tag = CHART_TAB_TAG;
        
        camVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"camera_tab"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        camVC.tabBarItem.tag = CAMERA_TAB_TAG;
        
        profileVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"profile_tab"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        profileVC.tabBarItem.tag = PROFILE_TAB_TAG;
        
        self.window.backgroundColor = [UIColor whiteColor];
        root = self.tabBarController;
        [self.window makeKeyAndVisible];
        
        if(animation){
            [UIView transitionWithView:self.window duration:0.3 options:UIViewAnimationOptionTransitionCurlDown animations:^{
                [self.window setRootViewController:root];
                [self.window makeKeyAndVisible];
            } completion:nil];
        }else{
            [self.window setRootViewController:root];
            [self.window makeKeyAndVisible];
        }
    }
}

@end
