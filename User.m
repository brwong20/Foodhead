//
//  User.m
//  FoodWise
//
//  Created by Brian Wong on 2/16/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"userId" : @"id",
             @"firstName" : @"first_name",
             @"lastName" : @"last_name",
             @"username" : @"username",
             @"email" : @"email",
             @"authToken" : @"auth_token"};
}

@end
