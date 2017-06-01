//  DiscoverNode.h
//  Foodhead
//
//  Created by Brian Wong on 4/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "TPLRestaurant.h"
#import "DiscoverRealm.h"

@class DiscoverNode;

@protocol DiscoverNodeDelegate <NSObject>

- (void)discoverNode:(DiscoverNode *)node didClickVideoWithRestaurant:(TPLRestaurant *)restInfo;

- (void)promptUserSignup;

@end

@interface DiscoverNode : ASCellNode

- (instancetype)initWithRestauarnt:(TPLRestaurant *)restaurant andPrimaryKey:(NSString *)primaryKey;
- (instancetype)initWithSavedRestaurant:(DiscoverRealm *)rlmRestaurant;

@property (nonatomic, strong) TPLRestaurant *restaurantInfo;
@property (nonatomic, strong) DiscoverRealm *savedRestaurantInfo;
@property (nonatomic, weak) id<DiscoverNodeDelegate> delegate;

@property (nonatomic, strong) ASVideoNode *playerNode;//If the restaurant has a video link, we swap out the thumbnailImageNode with this


//Because of threading issues, we'll use the primary key of a DiscoverRealm to find update it instead. This also helps us initially set a restaurant to be a favorite or not (For DiscoverViewController)
@property (nonatomic, strong) NSString *restPrimaryKey;


//Only used when we need to reflect a favorite from somewhere else (e.g. Rest page favorites a place, so update it's cell in DiscoverVC)
- (void)favoriteNodeWithInfo:(DiscoverRealm *)fav;
- (void)unfavoriteNode;


@end
