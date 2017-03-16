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
             @"menuURL" : @"menu_mobile_url",
             @"distance" : @"distance",
             @"foursq_images" : @"images",
             @"instagram_images" : @"instagram_images",
             @"categories" : @"categories"
             };
}

@end
