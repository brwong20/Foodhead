//
//  User.m
//  FoodWise
//
//  Created by Brian Wong on 2/16/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"userId" : @"user.id",
             @"firstName" : @"user.first_name",
             @"lastName" : @"user.last_name",
             @"username" : @"user.username",
             @"email" : @"user.email",
             @"avatarURL": @"user.avatar_url"};
}

@end
