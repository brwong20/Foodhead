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

@property (nonatomic, copy) NSNumber *restaurantId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *category;

@property (nonatomic, copy) NSString *fb_places_id;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSString *thumbnail;

//Foursquare data
@property (nonatomic, copy) NSString *foursqId;
@property (nonatomic, copy) NSNumber *foursq_rating;
@property (nonatomic, copy) NSNumber *foursq_price_tier;
@property (nonatomic, copy) NSString *menuLink;


//Suggestion API properties
@property (nonatomic, copy) NSString *suggestion_address;
@property (nonatomic, copy) NSString *suggestion_city;
@property (nonatomic, copy) NSString *suggestion_zip;
@property (nonatomic, copy) NSString *suggestion_state;


//Merged properties from TPLDetailedRestaurant

@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zipCode;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *mobileMenu;
@property (nonatomic, copy) NSString *menu;
@property (nonatomic, copy) NSString *website;

@property (nonatomic, copy) NSNumber *distance;
@property (nonatomic, copy) NSNumber *foursq_num_ratings;

@property (nonatomic, copy) NSArray *hours;
@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *instagram_images;

@property (nonatomic, assign)BOOL openNow;

@end
