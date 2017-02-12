//
//  UserAuthManager.m
//  FoodWise
//
//  Created by Brian Wong on 1/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UserAuthManager.h"
#import "FoodWiseDefines.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>

//Should prob have a completion handler here or delegate to signal LoginViewController to present/dismiss(loginWasSuccessful)

@implementation UserAuthManager

+ (BOOL)isUserLoggedIn{
    //Successful insta login
//    NSString *auth_token = [SAMKeychain passwordForService:INSTAGRAM_SERVICE account:KEYCHAIN_ACCOUNT];
//    if (auth_token.length > 0) return YES;
    
    //Successful Facebook login
    if ([FBSDKAccessToken currentAccessToken]) return YES;

    return NO;
}

@end
