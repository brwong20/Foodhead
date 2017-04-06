//
//  UsernamePromptViewController.h
//  FoodWise
//
//  Created by Brian Wong on 2/15/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "User.h"

@interface UsernamePromptViewController : UIViewController

@property (nonatomic, strong) User *currentUser;
@property (nonatomic, assign) BOOL isOnboarding;

@end
