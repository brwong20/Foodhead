//
//  TPLRestaurant.h
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@import CoreLocation;

@interface TPLRestaurant : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *restaurantId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *fb_places_id;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;

@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *thumbnailPrefix;
@property (nonatomic, copy) NSString *thumbnailSuffix;
@property (nonatomic, copy) NSNumber *thumbnailWidth;
@property (nonatomic, copy) NSNumber *thumbnailHeight;

//Foursquare data
@property (nonatomic, copy) NSString *foursqId;
@property (nonatomic, copy) NSString *menuLink;
@property (nonatomic, copy) NSNumber *openNowExplore; //From foursquare explore instead of our detailed openNow we calculate in case the restaurant is cached in db.
@property (nonatomic, copy) NSString *openNowStatus;
@property (nonatomic, copy) NSArray *categories; //When not pulled from restaurant page (i.e. from Explore endpoint) the first object will be the restaurant's primary category


//Suggestion API properties
@property (nonatomic, copy) NSString *suggestion_address;
@property (nonatomic, copy) NSString *suggestion_city;
@property (nonatomic, copy) NSString *suggestion_zip;
@property (nonatomic, copy) NSString *suggestion_state;


//Blog Metadata
@property (nonatomic, copy) NSString *blogName;
@property (nonatomic, copy) NSString *blogTitle;
@property (nonatomic, copy) NSString *blogProfileLink;

//Image - can also be the thumbnail for a video (from instagram only)
@property (nonatomic, copy) NSString *blogPhotoLink;
@property (nonatomic, copy) NSNumber *blogPhotoWidth;
@property (nonatomic, copy) NSNumber *blogPhotoHeight;

//Video
@property (nonatomic, copy) NSNumber *hasVideo;
@property (nonatomic, copy) NSString *blogVideoLink;
@property (nonatomic, copy) NSNumber *blogVideoWidth;
@property (nonatomic, copy) NSNumber *blogVideoHeight;


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
@property (nonatomic, copy) NSNumber *foursq_rating;
@property (nonatomic, copy) NSNumber *foursq_price_tier;

@property (nonatomic, copy) NSArray *hours;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *instagram_images;

@property (nonatomic, copy) NSNumber *openNow;

@end
