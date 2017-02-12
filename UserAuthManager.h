//
//  UserAuthManager.h
//  FoodWise
//
//  Created by Brian Wong on 1/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@protocol UserAuthDelegate <NSObject>

- (void)didAuthWithInstagram;

@end

@interface UserAuthManager : NSObject

+ (BOOL)isUserLoggedIn;

@end
