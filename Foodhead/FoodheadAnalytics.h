//
//  FoodheadAnalytics.h
//  Foodhead
//
//  Created by Brian Wong on 3/30/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Flurry.h"
#import "FoodWiseDefines.h"

@interface FoodheadAnalytics : NSObject

+ (void)beginFlurrySession;

//Specific event logging
+ (void)logEvent:(NSString *)string;
+ (void)logEvent:(NSString *)string withParameters:(NSDictionary *)params;
+ (void)beginTimedEvent:(NSString *)string;
+ (void)endTimedEvent:(NSString *)string withParameters:(NSDictionary *)params;

@end
