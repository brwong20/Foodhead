//
//  BrowsePlayerNode.h
//  Foodhead
//
//  Created by Brian Wong on 4/29/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "BrowseVideo.h"
#import "BrowseVideoRealm.h"

@class BrowsePlayerNode;

@protocol BrowsePlayerNodeDelegate <NSObject>

- (void)fullScreenWasEnabled;
- (void)fullScreenWasDisabled;

- (void)browsePlayerNode:(BrowsePlayerNode *)node wasUnfavorited:(NSNumber *)primaryKey;
- (void)browsePlayerNode:(BrowsePlayerNode *)node wasFavorited:(BrowseVideoRealm *)favorite;
- (void)browsePlayerNode:(BrowsePlayerNode *)node didChangePlayerState:(ASVideoNodePlayerState)state;

@end

@interface BrowsePlayerNode : ASCellNode

@property (nonatomic, strong) ASVideoPlayerNode *videoNode;
@property (nonatomic, strong) BrowseVideoRealm *savedVideoInfo;
@property (nonatomic, weak) id<BrowsePlayerNodeDelegate> delegate;
@property (nonatomic, strong) NSNumber *primaryKey;

- (instancetype)initWithVideo:(BrowseVideo *)videoInfo andPrimaryKey:(NSNumber *)primaryKey;
- (instancetype)initWithSavedVideo:(BrowseVideoRealm *)videoInfo;

- (void)setPlaceholderImage:(UIImage *)image;

- (void)toggleUnfavorite;

@end
