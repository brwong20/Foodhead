//
//  TPLDetailedRestaurant.h
//  FoodWise
//
//  Created by Brian Wong on 3/5/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TPLDetailedRestaurant : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zipCode;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *mobileMenu;
@property (nonatomic, copy) NSString *menu;
@property (nonatomic, copy) NSString *website;

@property (nonatomic, copy) NSNumber *foursq_num_ratings;
@property (nonatomic, copy) NSNumber *foursq_rating;
@property (nonatomic, copy) NSNumber *foursq_price_tier;
@property (nonatomic, copy) NSNumber *distance;

@property (nonatomic, copy) NSArray *hours;
@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, copy) NSArray *images;

@property (nonatomic, copy) NSNumber *openNow;

//User metrics
@property (nonatomic, copy) NSNumber *userOverall;
@property (nonatomic, copy) NSNumber *userAvgPrice;
@property (nonatomic, copy) NSNumber *userHealth;

@end
