//
//  AppDelegate.h
//  FoodWise
//
//  Created by Brian Wong on 1/12/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodWiseDefines.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabBarController;

- (void)changeRootViewControllerFor:(RootViewType)type withAnimation:(BOOL)animation;

@end

