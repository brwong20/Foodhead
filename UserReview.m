//
//  UserReview.m
//  Foodhead
//
//  Created by Brian Wong on 3/20/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UserReview.h"

@implementation UserReview

+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"healthiness" : @"healthiness",
             @"reviewId" : @"id",
             @"overall" : @"like",
             @"price" : @"price",
             @"imageURL" : @"url",
             @"thumbnailURL" : @"thumbnail_url"
             };
}

- (void)mergeValuesForKeysFromModel:(id<MTLModel>)model{
    [super mergeValuesForKeysFromModel:model];
}

//Used to make sure there are never any duplicate reviews being shown in user profile, restaurant page, etc.
- (BOOL)isEqual:(id)object{
    UserReview *otherReview = (UserReview *)object;
    if (self == object || self.reviewId == otherReview.reviewId) {
        return YES;
    }else{
        return NO;
    }
}

@end
