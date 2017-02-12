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

#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    //Must create window here ourselves if not using storyboard
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    //Check if user has a valid login or if they skipped - need an NSUserDefault for skipped?
    if(![UserAuthManager isUserLoggedIn]){
        [self changeRootViewControllerFor:RootViewTypeLogin];
    }else{
        [self changeRootViewControllerFor:RootViewTypeCharts];
    }
    return YES;
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *root;
    
    if(type == RootViewTypeLogin){
        root = (LoginViewController*)[storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    }
    else if (type == RootViewTypeCharts)
    {
        root = (ChartsViewController*)[storyboard instantiateViewControllerWithIdentifier:@"mainView"];
    }
    
    //Fade-out transition
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:root];
    
    if(type == RootViewTypeCharts){
//        UIView *snapshot = [self.window snapshotViewAfterScreenUpdates:YES];
//        [navController.view addSubview:snapshot];
//        
//        //TODO: Need to change animation for sign out.
//        [UIView animateWithDuration:0.5 animations:^{
//            snapshot.layer.opacity = 0;
//            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
//        } completion:^(BOOL finished) {
//            [snapshot removeFromSuperview];
//        }];
    }
    
    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];
}

@end
