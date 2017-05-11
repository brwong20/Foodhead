//
//  BrowsePlayerNode.h
//  Foodhead
//
//  Created by Brian Wong on 4/29/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "BrowseVideo.h"

@class BrowsePlayerNode;

@protocol BrowsePlayerNodeDelegate <NSObject>

- (void)fullScreenWasEnabled;
- (void)fullScreenWasDisabled;
- (void)playBackButtonTappedForNode:(BrowsePlayerNode *)node withState:(ASVideoNodePlayerState)state;

@end

@interface BrowsePlayerNode : ASCellNode

//@property (nonatomic, strong) ASVideoNode *videoNode;
@property (nonatomic, strong) ASVideoPlayerNode *videoNode;
@property (nonatomic, weak) id<BrowsePlayerNodeDelegate> delegate;

- (instancetype)initWithVideo:(BrowseVideo *)videoInfo;

@end
