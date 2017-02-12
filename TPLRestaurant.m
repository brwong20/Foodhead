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
             @"venue_id" : @"venue.id",
             @"name" : @"venue.name",
             @"foursq_rating" : @"venue.rating",
             @"num_foursq_ratings" : @"venue.ratingSignals",
             @"foursq_price_tier" : @"venue.price.tier",
             @"phone_number" : @"venue.contact.formattedPhone",
             @"locationCoordinate" : @"venue.location",
             @"foursq_featured_photos" : @"venue.featuredPhotos.items",
             @"fb_places_id" : @"venue.contact.facebook"
    };
    
}

//value = dictionary[@"location"] from what we defined above so just pull out lat and lng
+ (NSValueTransformer *)locationCoordinateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *coordinateDict, BOOL *success, NSError *__autoreleasing *error) {
        CLLocationDegrees lat = [coordinateDict[@"lat"] doubleValue];
        CLLocationDegrees lng = [coordinateDict[@"lng"] doubleValue];
        return [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(lat, lng)];
    } reverseBlock:^id(NSValue *value, BOOL *success, NSError *__autoreleasing *error) {
        CLLocationCoordinate2D coordinate = [value MKCoordinateValue];
        return @{@"lat" : @(coordinate.latitude), @"lng" : @(coordinate.longitude)};
    }];
}



@end
