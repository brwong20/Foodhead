//
//  TPLRestaurant.h
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Mantle/Mantle.h>

@import CoreLocation;

@interface TPLRestaurant : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy)NSString *venue_id;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *address;
@property (nonatomic, copy)NSString *menuLink;
@property (nonatomic, copy)NSString *category;
@property (nonatomic, copy)NSString *price;
@property (nonatomic, copy)NSString *phone_number;
@property (nonatomic, copy)NSString *fb_places_id;
@property (nonatomic, copy)NSString *fb_cover_photo;

@property (nonatomic)CLLocationCoordinate2D locationCoordinate;

@property (nonatomic, copy)NSNumber *current_distance;
@property (nonatomic, copy)NSNumber *foursq_rating;
@property (nonatomic, copy)NSNumber *num_foursq_ratings;
@property (nonatomic, copy)NSNumber *foursq_price_tier;

@property (nonatomic, copy)NSArray *hours;
@property (nonatomic, strong)NSArray *foursq_featured_photos;

//@property (nonatomic, assign)BOOL openNow;

@end
