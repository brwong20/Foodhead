//
//  TPLDetailedRestaurant.m
//  FoodWise
//
//  Created by Brian Wong on 3/5/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLDetailedRestaurant.h"

@implementation TPLDetailedRestaurant

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"address" : @"address",
             @"city" : @"city",
             @"phoneNumber" : @"phone",
             @"hours" : @"hours",
             @"menu" : @"menu_url",
             @"mobileMenu" : @"menu_mobile_url",
             @"distance" : @"distance",
             @"images" : @"images",
             @"categories" : @"categories",
             @"website" : @"url",
             @"zipCode" : @"location_postal_code",
             @"city" : @"city",
             @"state" : @"location_state",
             @"openNow" : @"is_open_now",
             @"foursq_num_ratings" : @"rating_signals"
             };
}

@end
