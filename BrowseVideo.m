//
//  BrowseVideo.m
//  Foodhead
//
//  Created by Brian Wong on 4/30/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "BrowseVideo.h"

@implementation BrowseVideo

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"profileURLStr" : @"profile_photo",
             @"uploaderName" : @"uploader_name",
             @"caption" : @"caption",
             @"tag" : @"tag",
             @"videoLink" : @"url_to_post",
             @"width" : @"width",
             @"height" : @"height",
             @"isYoutubeVideo" : @"youtube_video",
             @"viewCount" : @"views"
            };
}

@end
