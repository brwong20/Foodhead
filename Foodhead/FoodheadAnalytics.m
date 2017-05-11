//
//  FoodheadAnalytics.m
//  Foodhead
//
//  Created by Brian Wong on 3/30/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "FoodheadAnalytics.h"

@implementation FoodheadAnalytics

#pragma mark - Analytics Lifecycle

+ (void)beginFlurrySession{
    FlurrySessionBuilder* builder = [[[[[FlurrySessionBuilder new]
                                        withLogLevel:FlurryLogLevelCriticalOnly]
                                       withCrashReporting:YES]
                                      withSessionContinueSeconds:10]
                                     withAppVersion:@"1.1.2"];
    
    [Flurry setBackgroundSessionEnabled:NO];
    [Flurry startSession:FLURRY_API_KEY withSessionBuilder:builder];
}

#pragma mark - Specific Event Logging

+ (void)logEvent:(NSString *)string{
    [Flurry logEvent:string];
}

+ (void)logEvent:(NSString *)string withParameters:(NSDictionary *)params{
    [Flurry logEvent:string withParameters:params];
}

+ (void)beginTimedEvent:(NSString *)string{
    [Flurry logEvent:string timed:YES];
}

+ (void)endTimedEvent:(NSString *)string withParameters:(NSDictionary *)params{
    [Flurry endTimedEvent:string withParameters:params];
}

@end
