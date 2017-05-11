//
//  BrowseVideo.h
//  Foodhead
//
//  Created by Brian Wong on 4/30/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface BrowseVideo : MTLModel

@property (nonatomic, copy) NSString *profileURLStr;
@property (nonatomic, copy) NSString *uploaderName;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *videoLink;
@property (nonatomic, copy) NSString *thumbnailLink;
@property (nonatomic, copy) NSNumber *height;
@property (nonatomic, copy) NSNumber *width;
@property (nonatomic, copy) NSNumber *isYoutubeVideo;
@property (nonatomic, copy) NSNumber *viewCount;

@end
