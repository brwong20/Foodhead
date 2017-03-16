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

@property (nonatomic, copy) NSString *phone_number;
@property (nonatomic, copy) NSString *fb_places_id;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSString *thumbnail;

//Foursquare data
@property (nonatomic, copy) NSString *foursqId;
@property (nonatomic, copy) NSNumber *foursq_rating;
@property (nonatomic, copy) NSNumber *foursq_price_tier;
@property (nonatomic, copy) NSString *menuLink;

//@property (nonatomic, assign)BOOL openNow;


//Merged properties from TPLDetailedRestaurant

@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *menuURL;

@property (nonatomic, copy) NSNumber *distance;
//@property (nonatomic, copy) NSNumber *num_foursq_ratings;

@property (nonatomic, copy) NSArray *hours;
@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, copy) NSArray *foursq_images;
@property (nonatomic, copy) NSArray *instagram_images;

@end
