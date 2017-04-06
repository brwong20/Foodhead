//
//  UserReview.h
//  Foodhead
//
//  Created by Brian Wong on 3/20/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface UserReview : MTLModel<MTLJSONSerializing>

//Review
@property (nonatomic, copy) NSNumber *healthiness;
@property (nonatomic, copy) NSNumber *reviewId;
@property (nonatomic, copy) NSNumber *overall;
@property (nonatomic, copy) NSNumber *price;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *thumbnailURL;

//User
@property (nonatomic, copy, readonly) NSNumber *userId;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *avatarURL;

//Place (where review was submitted)
@property (nonatomic, copy) NSNumber *restaurantId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fb_places_id;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSNumber *foursq_price_tier;


@end
