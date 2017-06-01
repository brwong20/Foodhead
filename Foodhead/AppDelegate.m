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
#import <UserNotifications/UserNotifications.h>
#import <SAMKeychain/SAMKeychain.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@property (nonatomic, assign) UIApplicationState appState;

@property (nonatomic, strong) DiscoverViewController *discoverVC;
@property (nonatomic, strong) BrowseViewController *browseVC;
@property (nonatomic, strong) SearchViewController *searchVC;
@property (nonatomic, strong) UserProfileViewController *profileVC;
@property (nonatomic, assign) UNAuthorizationStatus authStatus;

@end

@implementation AppDelegate

#pragma mark - App Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#if PRODUCTION
    [FoodheadAnalytics beginFlurrySession];
#endif
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    BOOL fbLaunched = [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    //Allow audio to mix
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    [[UNUserNotificationCenter currentNotificationCenter]getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        self.authStatus = settings.authorizationStatus;
    }];
    
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

- (void)applicationWillEnterForeground:(UIApplication *)application{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    //If user wants to turn off push notifs in app
//    NSString *uniqueId = [self getUniqueDeviceIdentifierAsString];
//    [[UNUserNotificationCenter currentNotificationCenter]getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
//        UNAuthorizationStatus authStatus = settings.authorizationStatus;
//        //Auth status changed from initial status, update user push subscription
//        if (self.authStatus != authStatus) {
//            self.authStatus = authStatus;
//            BOOL authorized;
//            if (authStatus == UNAuthorizationStatusAuthorized) {
//                authorized = YES;
//            }else if(authStatus == UNAuthorizationStatusDenied){
//                authorized = NO;
//            }else{
//                //Authorization not determined
//            }
//            
//            [[UserAuthManager sharedInstance]updateUserSubscriptionToBeEnabled:authorized withUniqueId:uniqueId completionHandler:^(id user) {
//                DLog(@"Push subscription successfully updated");
//            } failureHandler:^(id error) {
//                DLog(@"Push subscription failed to update");
//            }];
//        }
//    }];
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

#pragma mark - UNUserNotificationDelegate Methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *token = [self stringWithDeviceToken:deviceToken];
    NSString *uniqueId = [self getUniqueDeviceIdentifierAsString];
    [[UserAuthManager sharedInstance]subscribeUserForAPNSWithToken:token withUniqueId:uniqueId completionHandler:^(id user) {
        DLog(@"Successfully subscribed for push");
    } failureHandler:^(id error) {
        DLog(@"Failed to subscribe for push");
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if ([application applicationState] == UIApplicationStateInactive) {
        self.appState = UIApplicationStateInactive;
    }else if ([application applicationState] == UIApplicationStateBackground){
        self.appState = UIApplicationStateBackground;
    }else{
        self.appState = UIApplicationStateActive;
    }
}

//Handle push notification from background
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary *customData = response.notification.request.content.userInfo[@"custom_data"];
    NSString *path = customData[@"route_path"];
    if ([path isEqualToString:@"Browse"]) {
        [self.browseVC refreshContent];
        [self.tabBarController setSelectedIndex:1];
    }else if ([path  isEqualToString:@"Home"]){
        [self.discoverVC refreshData];
        [self.tabBarController setSelectedIndex:0];
    }
    completionHandler();
}

//Handle push notification from foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary *customData = notification.request.content.userInfo[@"custom_data"];
    NSString *path = customData[@"route_path"];
    if ([path isEqualToString:@"Browse"]) {
        [self.browseVC refreshContent];
    }else if ([path  isEqualToString:@"Home"]){
        [self.discoverVC refreshData];
    }
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

#pragma mark - Helper methods

//Parse out device token
- (NSString *)stringWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    return [token copy];
}

//Necessary in order for us to invalidate old device tokens (for push notifs) on a reinstalled app
- (NSString *)getUniqueDeviceIdentifierAsString{
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString *strApplicationUUID = [SAMKeychain passwordForService:appName account:@"uniqueVendorId"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SAMKeychain setPassword:strApplicationUUID forService:appName account:@"uniqueVendorId"];
    }
    return strApplicationUUID;
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
        self.discoverVC = [[DiscoverViewController alloc]init];
        UINavigationController *chartsNav = [[UINavigationController alloc]initWithRootViewController:_discoverVC];
        
        self.searchVC = [[SearchViewController alloc]init];
        UINavigationController *searchNav = [[UINavigationController alloc]initWithRootViewController:_searchVC];
        
        self.browseVC = [[BrowseViewController alloc]init];
        //TabCameraViewController *camVC = [[TabCameraViewController alloc]init];
        UINavigationController *browseNav = [[UINavigationController alloc]initWithRootViewController:_browseVC];
        
        self.profileVC = [[UserProfileViewController alloc]init];
        UINavigationController *profileNav = [[UINavigationController alloc]initWithRootViewController:_profileVC];
        
        NSArray *controllers = [NSArray arrayWithObjects:chartsNav, browseNav, searchNav, profileNav, nil];
        self.tabBarController.viewControllers = controllers;
        
        UIEdgeInsets tabItemInsets = UIEdgeInsetsMake(7.0, 0.0, -7.0, 0.0);
        
        _discoverVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"home"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        _discoverVC.tabBarItem.imageInsets = tabItemInsets;
        _discoverVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_active"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _discoverVC.tabBarItem.tag = CHART_TAB_TAG;
        
        _browseVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"browse"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        _browseVC.tabBarItem.imageInsets = tabItemInsets;
        _browseVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"browse_active"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _browseVC.tabBarItem.tag = BROWSE_TAB_TAG;
        
        _searchVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"search"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        _searchVC.tabBarItem.imageInsets = tabItemInsets;
        _searchVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"search_active"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _searchVC.tabBarItem.tag = SEARCH_TAB_TAG;

        _profileVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:@"profile"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:nil];
        _profileVC.tabBarItem.imageInsets = tabItemInsets;
        _profileVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"profile_active"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _profileVC.tabBarItem.tag = PROFILE_TAB_TAG;
        
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
        
        //Load all tabs at once
        for(UINavigationController * viewController in self.tabBarController.viewControllers){
            [[viewController.viewControllers firstObject] view];
        }
    }
}

@end
