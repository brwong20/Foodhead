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
#import <AFNetworking/AFNetworking.h>
#import <SAMKeychain/SAMKeychain.h>

//Create enum for providers(or anon) and pass in type from loginVC?

@interface UserAuthManager ()

@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation UserAuthManager

+ (UserAuthManager *)sharedInstance
{
    static UserAuthManager *managerInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        managerInstance = [[self alloc]init];
    });
    return managerInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.sessionManager = [[AFHTTPSessionManager alloc]init];
    }
    return self;
}

#pragma mark - Login/Logout

- (void)loginWithFb:(FBSDKAccessToken *)token
  completionHandler:(void (^)(id authResponse))loginSuccess
     failureHandler:(void (^)(id error))loginFailure
{
    if (token) {
        [self.sessionManager GET:[NSString stringWithFormat:YUM_PROVIDER_AUTH, FB_PROVIDER_PATH] parameters:@{@"token" : token.tokenString} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if(responseObject){
                NSError *error = nil;
                self.currentUser = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:responseObject error:&error];
                if (error) {
                    NSLog(@"Couldn't deserialize user info");
                }
                [[NSUserDefaults standardUserDefaults]setObject:[self.currentUser.userId stringValue] forKey:LAST_USER_DEFAULT];//Store to save previous valid user login
                NSString *auth_token = responseObject[@"auth_token"];
                [SAMKeychain setPassword:auth_token forService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];//Encrypt auth_token in keychain and compare to current user credentials
                loginSuccess(self.currentUser);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Provider auth failed!");
            loginFailure(error);
        }];
    }else{
        NSLog(@"FB_AUTH_FAILED");
    }
}

- (void)loginAnonymously{
    //Delete all stored user credentials and switch to charts
    [SAMKeychain deletePasswordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:LAST_USER_DEFAULT];
}

//Delete auth token from cache and Realm object!!!
- (void)logoutUser:(void (^)(id completed))completionHandler
    failureHandler:(void (^)(id error))failureHandler
{
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    NSDictionary *params = @{AUTH_TOKEN_PARAM : authToken};
    [self.sessionManager DELETE:YUM_CHECK_SESSION parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //Clear all data concerning current user
        [SAMKeychain deletePasswordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:LAST_USER_DEFAULT];
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc]init];
        [loginManager logOut];
        
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];
}

#pragma mark - User Session

//Checks to see if user is already logged in with their auth_token from webserver. This can either be nil, present, or expired(which we will refresh using checkUserSessionActive)
- (BOOL)isUserLoggedIn{
    NSString *loggedInUser = [[NSUserDefaults standardUserDefaults]objectForKey:LAST_USER_DEFAULT];//Use NSUserDefault to check if user ever logged out. If not, check keychain for auth_token!
    if (loggedInUser.length > 0) {
        [self checkUserSessionActive:^(id sessionInfo) {
            
        } failureHandler:^(id error) {
            
        }];
        return YES;
    }
    return NO;
}

//Checks if user is logged in or not (based on auth token). If they are logged in, also check for auth_token validity. If expired, will return refreshed token
- (void)checkUserSessionActive:(void (^)(id sessionInfo))sessionHandler
                     failureHandler:(void (^)(id error))sessionFailure
{
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    [self.sessionManager.requestSerializer setValue:authToken forHTTPHeaderField:AUTH_TOKEN_PARAM];
    [self.sessionManager GET:YUM_CHECK_SESSION parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //Refresh cached token as well
//        if (![responseObject[@"authToken"] isEqualToString:authToken]) {
//            
//        }
        
        //Get current logged in user based on auth token and compare with last id
        //NSString *loggedInUser = [[NSUserDefaults standardUserDefaults]objectForKey:@"last_user_id"];
        
#warning Refresh keychain if expired (with response)
        sessionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //User isn't logged in
        sessionFailure(error);
    }];
}

#warning For when we need updated user info after they change something or achieve - will probably be using the actual method for either of these instead and just updating currentUser object
- (void)retrieveCurrentUser:(void (^)(id user))completionHandler
          failureHandler:(void (^)(id error))failureHandler
{
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    [self.sessionManager.requestSerializer setValue:authToken forHTTPHeaderField:AUTH_TOKEN_PARAM];
    [self.sessionManager GET:YUM_GET_USER_INFO parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        self.currentUser = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:responseObject error:&error];
        if (!error) {
            completionHandler(self.currentUser);
        }else{
            NSLog(@"Couldn't deserealize JSON: %@", error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to retrieve user info: %@", error.description);
        failureHandler(error);
    }];
}

#warning to be used everywhere else after we get current user from charts
- (User *)getCurrentUser{
    return self.currentUser;
}

@end
