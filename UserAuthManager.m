//
//  UserAuthManager.m
//  FoodWise
//
//  Created by Brian Wong on 1/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UserAuthManager.h"
#import "FoodWiseDefines.h"
#import "User.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AFNetworking/AFNetworking.h>
#import <SAMKeychain/SAMKeychain.h>

//Create enum for providers(or anon) and pass in type from loginVC?

@interface UserAuthManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation UserAuthManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.sessionManager = [[AFHTTPSessionManager alloc]init];
    }
    return self;
}

#pragma mark - Login/Logout

+ (BOOL)isUserLoggedIn{
    //Successful insta login
    //    NSString *auth_token = [SAMKeychain passwordForService:INSTAGRAM_SERVICE account:KEYCHAIN_ACCOUNT];
    //    if (auth_token.length > 0) return YES;
    
    //Successful Facebook login
    if ([FBSDKAccessToken currentAccessToken]) return YES;
    
    return NO;
}

- (void)loginWithFb:(FBSDKAccessToken *)token
  completionHandler:(void (^)(id authResponse))loginSuccess
     failureHandler:(void (^)(id error))loginFailure
{
    if (token) {
        [self.sessionManager GET:[NSString stringWithFormat:YUM_PROVIDER_AUTH, @"facebook"] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if(responseObject){
                NSString *authToken = responseObject[@"auth_token"];
                [SAMKeychain setPassword:authToken forService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
                NSLog(@"////USER_ACCESS_TOKEN////: %@", [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT]);
                loginSuccess(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Provider auth failed!");
            loginFailure(error);
        }];
    }else{
        NSLog(@"FB_AUTH_FAILED");
    }
}

//Delete auth token from cache and Realm object!!!

//- (void)logoutUser
//{
//    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
//    NSDictionary *params = @{@"AUTHTOKEN" : authToken};
//    [self.sessionManager DELETE:YUM_CHECK_SESSION parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//    }];
//}

#pragma mark - User Session

- (void)checkUserSessionWithHandler:(void (^)(id sessionInfo))sessionHandler
                     failureHandler:(void (^)(id error))sessionFailure
{
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    [self.sessionManager.requestSerializer setValue:authToken forHTTPHeaderField:@"AUTHTOKEN"];
    [self.sessionManager GET:YUM_CHECK_SESSION parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //Refresh cached token as well
//        if (![responseObject[@"authToken"] isEqualToString:authToken]) {
//            
//        }
        sessionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error.description);
        sessionFailure(error);
    }];
}

- (void)retrieveUserInfo:(void (^)(id userInfo))completionHandler
          failureHandler:(void (^)(id error))failureHandler
{
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    [self.sessionManager.requestSerializer setValue:authToken forHTTPHeaderField:@"AUTHTOKEN"];
    [self.sessionManager GET:YUM_GET_USER_INFO parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *userDict = responseObject[@"user"];
        NSError *error;
        User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:userDict error:&error];
        if (!error) {
            NSLog(@"Couldn't deserealize JSON: %@", error);
            completionHandler(user);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to retrieve user info: %@", error.description);
        failureHandler(error);
    }];
}

@end
