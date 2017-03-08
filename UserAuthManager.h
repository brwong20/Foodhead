//
//  UserAuthManager.h
//  FoodWise
//
//  Created by Brian Wong on 1/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "User.h"
#import "AFNetworking.h"

@protocol UserAuthDelegate <NSObject>

- (void)didLoginWithFB:(FBSDKAccessToken *)auth_token;

@end

@interface UserAuthManager : NSObject

+ (UserAuthManager *)sharedInstance;

- (User *)getCurrentUser;

- (BOOL)isUserLoggedIn;

- (void)loginWithFb:(FBSDKAccessToken *)token
  completionHandler:(void (^)(id))loginSuccess
     failureHandler:(void (^)(id))loginFailure;

- (void)loginAnonymously;

//Verifies currently stored access token
- (void)checkUserSessionActive:(void (^)(id sessionInfo))sessionHandler
                failureHandler:(void (^)(id error))sessionFailure;

//Get most updated user info. Also used to verify that this was the last user logged in.
- (void)retrieveCurrentUser:(void (^)(id user))completionHandler
             failureHandler:(void (^)(id error))failureHandler;

- (void)logoutUser:(void (^)(id completed))completionHandler
    failureHandler:(void (^)(id error))failureHandler;
@end
