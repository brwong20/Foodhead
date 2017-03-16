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
#import "SWRevealViewController.h"
#import "SlideOutViewController.h"
#import "User.h"

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
        [self changeRootViewControllerFor:RootViewTypeCharts];
    }else{
        [self changeRootViewControllerFor:RootViewTypeLogin];
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
    
    return YES;
}

- (void)changeRootViewControllerFor:(RootViewType)type{
    UIViewController *root = nil;
    
    if(type == RootViewTypeLogin){
        root = [[LoginViewController alloc]init];
    }
    else if (type == RootViewTypeCharts)
    {
        ChartsViewController *chartsVC = [[ChartsViewController alloc]init];
        UINavigationController *chartsNav = [[UINavigationController alloc]initWithRootViewController:chartsVC];
        
        SlideOutViewController *sidePanelVC = [[SlideOutViewController alloc]init];
        
        CGRect screenBounds = [[UIScreen mainScreen]bounds];
        
        SWRevealViewController *mainRevealVC = [[SWRevealViewController alloc]initWithRearViewController:sidePanelVC frontViewController:chartsNav];
        mainRevealVC.toggleAnimationType = SWRevealToggleAnimationTypeEaseOut;
        mainRevealVC.toggleAnimationDuration = 0.3;
        mainRevealVC.rearViewRevealWidth = screenBounds.size.width - SLIDED_PANEL_WIDTH;
        mainRevealVC.draggableBorderWidth = screenBounds.size.width/7;//Bounds the pan gesture to a specific width
        root = mainRevealVC;
    }

    [self.window setRootViewController:root];
    [self.window makeKeyAndVisible];
}

@end
