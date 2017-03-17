//
//  TPLRestaurant.m
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLRestaurant.h"


//Will eventually be its own class and added to our own server's model objects! 

@implementation TPLRestaurant

+ (NSDictionary *)JSONKeyPathsByPropertyKey{    
    return @{
             @"restaurantId" : @"id",
             @"foursqId" : @"four_square_id",
             @"name" : @"name",
             @"foursq_price_tier" : @"price",
             @"latitude" : @"lat",
             @"longitude" : @"lng",
             @"foursq_rating" : @"rating",
             @"thumbnail" : @"avatar",
             @"suggestion_address" : @"location_address",
             @"suggestion_city" : @"location_city",
             @"suggestion_zip" : @"location_postal_code",
             @"suggestion_state" : @"location_state"
             };
    
}

- (void)mergeValuesForKeysFromModel:(id<MTLModel>)model{
    [super mergeValuesForKeysFromModel:model];
}

@end
