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
             @"restaurantId" : @"id",
             @"foursqId" : @"four_square_id",
             @"name" : @"name",
             @"latitude" : @"lat",
             @"longitude" : @"lng",
             @"thumbnail" : @"avatar",
             @"thumbnailPrefix" : @"fs_avatar_prefix",
             @"thumbnailPrefix" : @"fs_avatar_suffix",
             @"thumbnailWidth" : @"fs_avatar_width",
             @"thumbnailHeight" : @"fs_avatar_height",
             @"categories" : @"categories",
             @"openNowStatus" : @"open_status",
             @"openNowExplore" : @"open_now",
             @"suggestion_address" : @"location_address",
             @"suggestion_city" : @"location_city",
             @"suggestion_zip" : @"location_postal_code",
             @"suggestion_state" : @"location_state",
             @"blogName" : @"instagram_user.full_name",
             @"blogTitle" : @"instagram_user.title",
             @"blogProfileLink" : @"instagram_user.profile_pic_url_hd",
             @"blogPhotoLink" : @"instagram_contents.images.standard_resolution.url",
             @"blogPhotoWidth" : @"instagram_contents.images.standard_resolution.width",
             @"blogPhotoHeight" : @"instagram_contents.images.standard_resolution.height",
             @"hasVideo" : @"instagram_contents.is_video",
             @"blogVideoLink" : @"instagram_contents.videos.standard_resolution.url",
             @"blogVideoWidth" : @"instagram_contents.videos.standard_resolution.width",
             @"blogVideoHeight" : @"instagram_contents.videos.standard_resolution.height"
             };
    
}

- (void)mergeValuesForKeysFromModel:(id<MTLModel>)model{
    [super mergeValuesForKeysFromModel:model];
}


@end
