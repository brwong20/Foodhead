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
//    return @{
//             @"venue_id" : @"venue.id",
//             @"name" : @"venue.name",
//             @"foursq_rating" : @"venue.rating",
//             @"num_foursq_ratings" : @"venue.ratingSignals",
//             @"foursq_price_tier" : @"venue.price.tier",
//             @"phone_number" : @"venue.contact.formattedPhone",
//             @"locationCoordinate" : @"venue.location",
//             @"foursq_featured_photos" : @"venue.featuredPhotos.items",
//             @"fb_places_id" : @"venue.contact.facebook"
//    };
    
    return @{
             @"restaurantId" : @"id",
             @"foursqId" : @"four_square_id",
             @"name" : @"name",
             @"foursq_price_tier" : @"price",
             @"latitude" : @"lat",
             @"longitude" : @"lng",
             @"foursq_rating" : @"rating",
             @"thumbnail" : @"avatar"
             };
    
}

- (void)mergeValuesForKeysFromModel:(id<MTLModel>)model{
    [super mergeValuesForKeysFromModel:model];
}

@end
