//
//  BrowseVideoRealm.h
//  Foodhead
//
//  Created by Brian Wong on 5/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Realm/Realm.h>
#import "BrowseVideo.h"

@interface BrowseVideoRealm : RLMObject

@property NSNumber<RLMInt> *videoId;

@property NSString *profileURLStr;
@property NSString *uploaderName;
@property NSString *caption;
@property NSString *tag;
@property NSString *videoLink;
@property NSString *thumbnailLink;

@property NSNumber<RLMInt> *height;
@property NSNumber<RLMInt> *width;
@property NSNumber<RLMBool> *isYoutubeVideo;
@property NSNumber<RLMInt> *viewCount;

//Creation date used to sort by most recent
@property NSDate *creationDate;

@end
