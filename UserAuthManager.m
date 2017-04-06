//
//  UserAuthManager.m
//  FoodWise
//
//  Created by Brian Wong on 1/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UserAuthManager.h"
#import "FoodWiseDefines.h"
#import "NSString+IsEmpty.h"

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

#pragma mark - Sign in / Sign out

- (void)loginWithFb:(FBSDKAccessToken *)token
  completionHandler:(void (^)(User *userResponse))loginSuccess
     failureHandler:(void (^)(id error))loginFailure{
    if (token) {
        [self.sessionManager GET:[NSString stringWithFormat:API_SESSION_AUTHORIZE, FB_PROVIDER_PATH] parameters:@{@"token" : token.tokenString} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if(responseObject){
                self.currentUser = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:responseObject error:nil];
                self.currentUser.avatarImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentUser.avatarURL]]];
                
                //Store to save previous valid user login. Since our currentUser object is custom, we must convert it to NSData first.
                NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.currentUser];
                [currentDefaults setObject:data forKey:LAST_USER_DEFAULT];

                //If this is an anon user logging in, they've already seen the tooltips so don't show again.
                if (![[NSUserDefaults standardUserDefaults]boolForKey:ANON_USER]) {
                    [self addTooltipDefaults];
                }
                
                //Encrypt auth_token for user api calls
                NSString *auth_token = responseObject[@"auth_token"];
                [SAMKeychain setPassword:auth_token forService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];//Encrypt auth_token in keychain and compare to current user credentials
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:ANON_USER];
                loginSuccess(self.currentUser);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:ANON_USER];
    [self addTooltipDefaults];
}

//Delete auth token from cache and Realm object!!!
- (void)logoutUser:(void (^)(id completed))completionHandler
    failureHandler:(void (^)(id error))failureHandler
{
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    NSDictionary *params = @{AUTH_TOKEN_PARAM : authToken};
    [self.sessionManager DELETE:API_SESSION_STATUS parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

//User either has to be already logged in or anonymously logged in to be taken to the charts page.
- (BOOL)isUserLoggedIn{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_USER_DEFAULT];
    User *lastUser;
    if (data) {
        lastUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    BOOL anonLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ANON_USER];
    if (lastUser || anonLogin) return YES;
    
    return NO;
}

//Checks if user is logged in or not (based on auth token). If they are logged in, also check for auth_token validity. If expired, will return refreshed token
- (void)checkUserSessionActive:(void (^)(id sessionInfo))sessionHandler
                     failureHandler:(void (^)(id error))sessionFailure
{
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    [self.sessionManager.requestSerializer setValue:authToken forHTTPHeaderField:AUTH_TOKEN_PARAM];
    [self.sessionManager GET:API_SESSION_STATUS parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {        
#warning Refresh keychain if expired (with response)
        sessionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //User isn't logged in
        sessionFailure(error);
    }];
}

#pragma mark - User Info

//For when we need updated user info after they change something or achieve - will probably be using the actual method for either of these instead and just updating currentUser object
- (void)retrieveCurrentUser:(void (^)(id user))completionHandler
          failureHandler:(void (^)(id error))failureHandler{
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    [self.sessionManager.requestSerializer setValue:authToken forHTTPHeaderField:AUTH_TOKEN_PARAM];
    
    //See if there was a previously logged in user no matter what first. This will let us load user appropriate user info even if user hasn't been verified yet (i.e. slow connection)
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_USER_DEFAULT];
    if (data) {
        User *lastUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.currentUser = lastUser;
    }
    
    [self.sessionManager GET:API_USER parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.currentUser = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:responseObject error:nil];
        self.currentUser.avatarImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentUser.avatarURL]]];
        completionHandler(self.currentUser);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *userInfo = [error userInfo];
        NSString* errorCode = userInfo[NSLocalizedDescriptionKey];
        if (![NSString isEmpty:errorCode]) {
            if ([errorCode containsString:STATUS_CODE_UNAUTHORIZED]) {
                NSLog(@"Anonymous user has logged in.");
            }else if ([errorCode containsString:STATUS_NO_INTERNET]){//No connection to retrieve current user so use cached user info if there is any
                NSLog(@"No internet connection, couldn't retrieve logged in user.");
            }
        }
        failureHandler(error);
    }];
}

- (void)updateCurrentUserWithParams:(NSDictionary *)params
                  completionHandler:(void (^)(id))completionHandler
                     failureHandler:(void (^)(id))failureHandler{
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    [self.sessionManager.requestSerializer setValue:authToken forHTTPHeaderField:AUTH_TOKEN_PARAM];
    
    [self.sessionManager POST:API_USER parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.currentUser = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:responseObject error:nil];
        self.currentUser.avatarImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentUser.avatarURL]]];

        //Make sure to update cached user as well.
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.currentUser];
        [currentDefaults setObject:data forKey:LAST_USER_DEFAULT];
        
        completionHandler(self.currentUser);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to update user info: %@", error.description);
        failureHandler(error);
    }];
}

- (void)retrieveUserReviews:(void (^)(id reviews))completionHandler
             failureHandler:(void (^)(id error))failureHandler{
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    [self.sessionManager.requestSerializer setValue:authToken forHTTPHeaderField:AUTH_TOKEN_PARAM];
    
    [self.sessionManager GET:API_USER_REVIEWS parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];
}

#pragma mark - Helper Methods

- (User *)getCurrentUser{
    return self.currentUser;
}

- (void)addTooltipDefaults{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:CAMERA_CAPTURE_TOOLTIP];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:CAMERA_RATING_TOOLTIP];
}

@end
