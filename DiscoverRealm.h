//
//  DiscoverRealm.h
//  Foodhead
//
//  Created by Brian Wong on 5/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Realm/Realm.h>
#import "TPLRestaurant.h"

@interface DiscoverRealm : RLMObject

//No need to worry about property attributes b/c Realm takes care of that
@property NSString *foursqId;
@property NSString *name;
@property NSString *primaryCategory;

@property NSNumber<RLMFloat> *foursq_rating;
@property NSNumber<RLMFloat> *distance;
@property NSNumber<RLMFloat> *lat;
@property NSNumber<RLMFloat> *lng;
@property NSNumber<RLMBool> *hasVideo;

//Photo
@property NSString *thumbnailPhotoLink;
@property NSNumber<RLMInt> *thumbnailPhotoWidth;
@property NSNumber<RLMInt> *thumbnailPhotoHeight;

//Video
@property NSString *thumbnailVideoLink;
@property NSNumber<RLMInt> *thumbnailVideoWidth;
@property NSNumber<RLMInt> *thumbnailVideoHeight;

//If restaurant was from a blog
@property NSString *sourceBlogName;
@property NSString *sourceBlogProfilePhoto;

//Creation date used to sort by most recent
@property NSDate *creationDate;

@end

