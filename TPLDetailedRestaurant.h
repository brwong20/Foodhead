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
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *menuURL;

@property (nonatomic, copy) NSNumber *distance;
//@property (nonatomic, copy) NSNumber *num_foursq_ratings;

@property (nonatomic, copy) NSArray *hours;
@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, copy) NSArray *foursq_images;
@property (nonatomic, copy) NSArray *instagram_images;

@end
