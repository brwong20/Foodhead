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

- (void)didLoginWithFB:(FBSDKAccessToken *)auth_token;

@end

@interface UserAuthManager : NSObject

+ (BOOL)isUserLoggedIn;

- (void)loginWithFb:(FBSDKAccessToken *)token
  completionHandler:(void (^)(id))loginSuccess
     failureHandler:(void (^)(id))loginFailure;

- (void)checkUserSessionWithHandler:(void (^)(id))sessionHandler
                     failureHandler:(void (^)(id))sessionFailure;

- (void)retrieveUserInfo:(void (^)(id userInfo))completionHandler
          failureHandler:(void (^)(id error))failureHandler;
@end
