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
             @"foursq_num_ratings" : @"rating_signals",
             @"foursq_price_tier" : @"price",
             @"foursq_rating" : @"rating",
             @"thumbnail" : @"avatar",
             @"thumbnailPrefix" : @"fs_avatar_prefix",
             @"thumbnailPrefix" : @"fs_avatar_suffix",
             @"thumbnailWidth" : @"fs_avatar_width",
             @"thumbnailHeight" : @"fs_avatar_height"
             };
}

@end
