//
//  BrowsePlayerNode.m
//  Foodhead
//
//  Created by Brian Wong on 4/29/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "BrowsePlayerNode.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "UIImage+Utilities.h"

@interface BrowsePlayerNode () <ASVideoPlayerNodeDelegate>

@property (nonatomic, strong) ASDisplayNode *videoDisplayNode;
@property (nonatomic, strong) ASImageNode *placeholderImageNode;
@property (nonatomic, assign) BOOL isFullscreen;
//@property (nonatomic, assign) BOOL controlsHidden;

@property (nonatomic, strong) BrowseVideo *videoInfo;

@property (nonatomic, strong) ASTextNode *titleNode;
@property (nonatomic, strong) ASTextNode *sourceNameNode;
@property (nonatomic, strong) ASTextNode *categoryNode;

@property (nonatomic, strong) ASImageNode *bookmarkImgNode;
@property (nonatomic, strong) ASTextNode *bookmarkCountNode;

@property (nonatomic, strong) ASImageNode *viewsImgNode;
@property (nonatomic, strong) ASTextNode *viewCountNode;

@property (nonatomic, strong) ASNetworkImageNode *sourceImgNode;

@property (nonatomic, strong) ASButtonNode *bookmarkNode;

@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;

@end

@implementation BrowsePlayerNode

- (instancetype)initWithVideo:(BrowseVideo *)videoInfo andPrimaryKey:(NSNumber *)primaryKey{
    self = [super init];
    if (self) {
        // Automatically manage subnode add, removal, animation, etc.
        self.automaticallyManagesSubnodes = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _videoInfo = videoInfo;
        _primaryKey = primaryKey;
        
        _videoNode = [[ASVideoPlayerNode alloc]init];
        _videoNode.delegate = self;
        _videoNode.backgroundColor = [UIColor blackColor];
        _videoNode.muted = NO;
        _videoNode.gravity = AVLayerVideoGravityResizeAspect;
        _videoNode.controlsDisabled = YES;
        _videoWidth = _videoInfo.width.floatValue;
        _videoHeight = _videoInfo.height.floatValue;

        _placeholderImageNode = [[ASImageNode alloc]init];
        _placeholderImageNode.backgroundColor = [UIColor clearColor];
        _placeholderImageNode.contentMode = UIViewContentModeScaleAspectFill;
        
        _sourceImgNode = [[ASNetworkImageNode alloc]init];
        _sourceImgNode.URL = [NSURL URLWithString:videoInfo.profileURLStr];
        [_sourceImgNode setImageModificationBlock:^UIImage *(UIImage *image) {
            return [UIImage drawRoundedCornersForImage:image withCornerRadius:image.size.height/2];
        }];
        _sourceImgNode.contentMode = UIViewContentModeScaleAspectFit;
        _sourceImgNode.layerBacked = YES;
        _sourceImgNode.backgroundColor = [UIColor whiteColor];
        
        _sourceNameNode = [[ASTextNode alloc]init];
        _sourceNameNode.attributedText = [[NSAttributedString alloc]initWithString:videoInfo.uploaderName attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _sourceNameNode.maximumNumberOfLines = 1;
        
        _categoryNode = [[ASTextNode alloc]init];
        _categoryNode.backgroundColor = [UIColor clearColor];
        _categoryNode.attributedText = [[NSAttributedString alloc]initWithString:videoInfo.tag attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _categoryNode.maximumNumberOfLines = 1;
        
        _titleNode = [[ASTextNode alloc]init];
        _titleNode.backgroundColor = [UIColor clearColor];
        _titleNode.attributedText = [[NSAttributedString alloc]initWithString:videoInfo.caption attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16.0], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _titleNode.layerBacked = YES;
        
        _bookmarkNode = [[ASButtonNode alloc]init];
        _bookmarkNode.backgroundColor = [UIColor clearColor];
        _bookmarkNode.contentMode = UIViewContentModeScaleAspectFit;
        [_bookmarkNode setImage:[UIImage imageNamed:@"favorite_browse"] forState:UIControlStateNormal];
        [_bookmarkNode addTarget:self action:@selector(bookmarkClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        
        _viewsImgNode = [[ASImageNode alloc]init];
        _viewsImgNode.backgroundColor = [UIColor clearColor];
        _viewsImgNode.image = [UIImage imageNamed:@"watch-dark-eye"];
        _viewsImgNode.layerBacked = YES;
        
        _viewCountNode = [[ASTextNode alloc]init];
        _viewCountNode.attributedText = [[NSAttributedString alloc]initWithString:_videoInfo.viewCount.stringValue attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _viewCountNode.backgroundColor = [UIColor clearColor];
        _viewCountNode.maximumNumberOfLines = 1;
        _viewCountNode.layerBacked = YES;
        
//        _bookmarkCountNode.backgroundColor = [UIColor grayColor];
//        _viewCountNode.backgroundColor = [UIColor grayColor];
//        _videoNode.backgroundColor = [UIColor greenColor];
//        _titleNode.backgroundColor = [UIColor redColor];
//        _categoryNode.backgroundColor = [UIColor magentaColor];
//        _sourceNameNode.backgroundColor = [UIColor cyanColor];
//        _sourceImgNode.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)didLoad{
    [super didLoad];
    _videoNode.layer.cornerRadius = 10.0;
    _videoNode.layer.masksToBounds = YES;
    _videoNode.clipsToBounds = YES;

    _placeholderImageNode.cornerRadius = 10.0;
    _placeholderImageNode.clipsToBounds = YES;
}

- (instancetype)initWithSavedVideo:(BrowseVideoRealm *)videoInfo{
    self = [super init];
    if (self) {
        // Automatically manage subnode add, removal, animation, etc.
        self.automaticallyManagesSubnodes = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _savedVideoInfo = videoInfo;
        _primaryKey = videoInfo.videoId;
        
        _videoNode = [[ASVideoPlayerNode alloc]init];
        _videoNode.delegate = self;
        _videoNode.backgroundColor = [UIColor blackColor];
        _videoNode.muted = NO;
        _videoNode.gravity = AVLayerVideoGravityResizeAspect;
        _videoNode.controlsDisabled = YES;
        _videoWidth = _savedVideoInfo.width.floatValue;
        _videoHeight = _savedVideoInfo.height.floatValue;
        _videoNode.clipsToBounds = YES;
        
        _placeholderImageNode = [[ASImageNode alloc]init];
        _placeholderImageNode.backgroundColor = [UIColor clearColor];
        _placeholderImageNode.contentMode = UIViewContentModeScaleAspectFill;
        _placeholderImageNode.cornerRadius = 10.0;
        //        _placeholderImageNode.layer.masksToBounds = YES;
        _placeholderImageNode.clipsToBounds = YES;
        
        _sourceImgNode = [[ASNetworkImageNode alloc]init];
        _sourceImgNode.URL = [NSURL URLWithString:_savedVideoInfo.profileURLStr];
        [_sourceImgNode setImageModificationBlock:^UIImage *(UIImage *image) {
            return [UIImage drawRoundedCornersForImage:image withCornerRadius:image.size.height/2];
        }];
        _sourceImgNode.contentMode = UIViewContentModeScaleAspectFit;
        _sourceImgNode.layerBacked = YES;
        _sourceImgNode.backgroundColor = [UIColor whiteColor];
        
        _sourceNameNode = [[ASTextNode alloc]init];
        _sourceNameNode.attributedText = [[NSAttributedString alloc]initWithString:videoInfo.uploaderName attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _sourceNameNode.maximumNumberOfLines = 1;
        
        _categoryNode = [[ASTextNode alloc]init];
        _categoryNode.backgroundColor = [UIColor clearColor];
        _categoryNode.attributedText = [[NSAttributedString alloc]initWithString:videoInfo.tag attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _categoryNode.maximumNumberOfLines = 1;
        
        _titleNode = [[ASTextNode alloc]init];
        _titleNode.backgroundColor = [UIColor clearColor];
        _titleNode.attributedText = [[NSAttributedString alloc]initWithString:videoInfo.caption attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16.0], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _titleNode.layerBacked = YES;
        //_titleNode.maximumNumberOfLines = 2;
        
        _bookmarkNode = [[ASButtonNode alloc]init];
        _bookmarkNode.backgroundColor = [UIColor clearColor];
        _bookmarkNode.contentMode = UIViewContentModeScaleAspectFit;
        [_bookmarkNode setImage:[UIImage imageNamed:@"favorite_browse_fill"] forState:UIControlStateNormal];
        [_bookmarkNode addTarget:self action:@selector(bookmarkClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        
        _viewsImgNode = [[ASImageNode alloc]init];
        _viewsImgNode.backgroundColor = [UIColor clearColor];
        _viewsImgNode.image = [UIImage imageNamed:@"watch-dark-eye"];
        _viewsImgNode.layerBacked = YES;
        
        _viewCountNode = [[ASTextNode alloc]init];
        _viewCountNode.attributedText = [[NSAttributedString alloc]initWithString:_savedVideoInfo.viewCount.stringValue attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _viewCountNode.backgroundColor = [UIColor clearColor];
        _viewCountNode.maximumNumberOfLines = 1;
        _viewCountNode.layerBacked = YES;
        
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
//    if (!self.isFullscreen) {
        //For the header with source info
    
    ASStackLayoutSpec *headerStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    headerStack.alignSelf = ASStackLayoutAlignSelfStart;
    headerStack.flexShrink = 1.0;
    headerStack.children = @[_sourceNameNode, _categoryNode];
    
    ASStackLayoutSpec *sourceStack = [ASStackLayoutSpec horizontalStackLayoutSpec];
    sourceStack.alignItems = ASStackLayoutAlignItemsCenter;
    sourceStack.spacing = 10.0;
    _sourceImgNode.preferredFrameSize = CGSizeMake(35, 35);
    _bookmarkNode.preferredFrameSize = CGSizeMake(35.0, 35.0);
    _bookmarkNode.alignSelf = ASStackLayoutAlignSelfEnd;
    
    //Add spacer to push favorite button to the end
    ASLayoutSpec *spec = [ASLayoutSpec new];
    spec.style.flexGrow = 1.0;

    sourceStack.children = @[_sourceImgNode, headerStack, spec, _bookmarkNode];
    
    //Height & Width are changed when dealing with portrait mode
    CGFloat ratio = _videoHeight / _videoWidth;
    ASRatioLayoutSpec *videoRatioSpec = [ASRatioLayoutSpec
                                         ratioLayoutSpecWithRatio:ratio
                                         child:self.videoNode];
    videoRatioSpec.alignSelf = ASStackLayoutAlignSelfCenter;
    //videoRatioSpec.spacingBefore = 1.5;
    //videoRatioSpec.spacingAfter = 6.0;
    
    ASRatioLayoutSpec *placeHolderRatioSpec = [ASRatioLayoutSpec ratioLayoutSpecWithRatio:ratio child:self.placeholderImageNode];
    ASOverlayLayoutSpec *placeholderOverlaySpec = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:videoRatioSpec overlay:placeHolderRatioSpec];
    placeholderOverlaySpec.alignSelf = ASStackLayoutAlignSelfCenter;
    placeholderOverlaySpec.spacingAfter = 6.0;
    placeholderOverlaySpec.spacingBefore = 1.5;

    //Video details and metrics layout
    ASStackLayoutSpec *vidDetailsStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    vidDetailsStack.alignSelf = ASStackLayoutAlignSelfStart;
    //vidDetailsStack.spacing = 5.0;

    ASStackLayoutSpec *viewStack = [ASStackLayoutSpec horizontalStackLayoutSpec];
    viewStack.alignSelf = ASStackLayoutAlignSelfStart;
    viewStack.alignItems = ASStackLayoutAlignItemsCenter;
    viewStack.flexShrink = 1.0;
    viewStack.spacing = 7.0;
    _viewCountNode.flexShrink = 1.0;
    _viewsImgNode.style.preferredSize = CGSizeMake(26.0, 18.0);
    
    viewStack.children = @[_viewsImgNode, _viewCountNode];

    vidDetailsStack.children = @[_titleNode];
    
    //Place all elements into a vertical layout spec
    NSMutableArray *verticalChildren = [NSMutableArray array];
    ASStackLayoutSpec *verticalStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    verticalStack.spacingAfter = 25.0;

    [verticalChildren addObject:[ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0) child:sourceStack]];
    [verticalChildren addObject:placeholderOverlaySpec];
    [verticalChildren addObject:[ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0) child:vidDetailsStack]];
    
    verticalStack.children = verticalChildren;
    verticalStack.justifyContent = ASStackLayoutJustifyContentStart;
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 15.0, 20.0, 15.0) child:verticalStack];
    
//    }else{
//        self.backgroundColor = [UIColor blackColor];
//        [UIView animateWithDuration:0.3 animations:^{
//            self.videoNode.transform = CATransform3DMakeRotation(90.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
//        }];
//        
//        ASStackLayoutSpec *videoStack = [ASStackLayoutSpec horizontalStackLayoutSpec];
//        videoStack.style.preferredSize = CGSizeMake(APPLICATION_FRAME.size.height, APPLICATION_FRAME.size.width);
//        _videoNode.backgroundColor = [UIColor greenColor];
//        
//        CGFloat ratio = self.videoInfo.height.floatValue / self.videoInfo.width.floatValue;
//        ASRatioLayoutSpec *videoRatioSpec = [ASRatioLayoutSpec
//                                             ratioLayoutSpecWithRatio:ratio
//                                             child:self.videoNode];
//        videoRatioSpec.alignSelf = ASStackLayoutAlignSelfCenter;
//        videoRatioSpec.style.flexBasis = ASDimensionMake(@"100%");
//        
//        videoStack.alignItems = ASStackLayoutAlignItemsCenter;
//        videoStack.justifyContent = ASStackLayoutJustifyContentCenter;
//        videoStack.children = @[videoRatioSpec];
//        
//        NSLog(@"%@", videoStack.asciiArtString);
//        
//        return videoStack;
//    }
}

#pragma mark ASVideoPlayerNodeDelegate methods

- (UIActivityIndicatorViewStyle)videoPlayerNodeSpinnerStyle:(ASVideoPlayerNode *)videoPlayer{
    return UIActivityIndicatorViewStyleWhite;
}


//- (NSArray *)videoPlayerNodeNeededDefaultControls:(ASVideoPlayerNode *)videoPlayer{
//    return @[ @(ASVideoPlayerNodeControlTypePlaybackButton),
//              @(ASVideoPlayerNodeControlTypeElapsedText),
//              @(ASVideoPlayerNodeControlTypeScrubber),
//              @(ASVideoPlayerNodeControlTypeDurationText)];
//    
//}

//If user purposely play/pauses a specific video, pause all other videos
- (void)didTapPlayBackButton:(ASControlNode *)controlNode withState:(ASVideoNodePlayerState)state{
    //[self.delegate playBackButtonTappedForNode:self withState:state];
}

#pragma mark - Helper methods

- (void)bookmarkClicked{
    if (self.primaryKey) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObject:[BrowseVideoRealm objectForPrimaryKey:self.primaryKey]];
        NSError *err;
        [realm commitWriteTransaction:&err];
        if (err) {
            NSLog(@"Failed to remove video from Realm: %@", err);
        }else{
            [self toggleUnfavorite];
        }
    }else{
        BrowseVideoRealm *videoRealm = [[BrowseVideoRealm alloc]init];
        videoRealm.videoId = _videoInfo.videoId;
        videoRealm.profileURLStr = _videoInfo.profileURLStr;
        videoRealm.uploaderName = _videoInfo.uploaderName;
        videoRealm.caption = _videoInfo.caption;
        videoRealm.tag = _videoInfo.tag;
        videoRealm.videoLink = _videoInfo.videoLink;
        videoRealm.thumbnailLink = _videoInfo.thumbnailLink;
        videoRealm.height = _videoInfo.height;
        videoRealm.width = _videoInfo.width;
        videoRealm.isYoutubeVideo = _videoInfo.isYoutubeVideo;
        videoRealm.viewCount = _videoInfo.viewCount;
        videoRealm.creationDate = [NSDate date];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:videoRealm];
        NSError *err;
        [realm commitWriteTransaction:&err];
        if (err) {
            NSLog(@"Failed to add video to Realm: %@", err);
        }else{
            [_bookmarkNode setImage:[UIImage imageNamed:@"favorite_browse_fill"] forState:UIControlStateNormal];
            if ([self.delegate respondsToSelector:@selector(browsePlayerNode:wasFavorited:)]) {
                [self.delegate browsePlayerNode:self wasFavorited:videoRealm];
            }
            self.primaryKey = _videoInfo.videoId;
            self.savedVideoInfo = videoRealm;
        }
    }
}

- (void)setPlaceholderImage:(UIImage *)image{
    _placeholderImageNode.image = image;
}

- (void)videoPlayerNodeDidStartInitialLoading:(ASVideoPlayerNode *)videoPlayer{
    //Make placeholder pulse
//    CABasicAnimation *theAnimation;
//    
//    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
//    theAnimation.duration=1.0;
//    theAnimation.repeatCount = HUGE_VALF;
//    theAnimation.autoreverses = YES;
//    theAnimation.fromValue = [NSNumber numberWithFloat:1.0];
//    theAnimation.toValue = [NSNumber numberWithFloat:0.7];
//    [self.placeholderImageNode.layer addAnimation:theAnimation forKey:@"animateOpacity"];
}

- (void)videoPlayerNodeDidFinishInitialLoading:(ASVideoPlayerNode *)videoPlayer{
//    [self.placeholderImageNode.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.25 animations:^{
        _placeholderImageNode.alpha = 0.0;
    }completion:^(BOOL finished) {
        //_placeholderImageNode.hidden = YES;
    }];
}

- (void)didTapVideoPlayerNode:(ASVideoPlayerNode *)videoPlayer{
    ASVideoNodePlayerState state = videoPlayer.playerState;
    if (state == ASVideoNodePlayerStatePlaying) {
        [videoPlayer pause];
    }else if (state == ASVideoNodePlayerStateFinished){
        [videoPlayer seekToTime:0.0];
        [videoPlayer play];
    }else if (state == ASVideoNodePlayerStatePaused || state == ASVideoNodePlayerStateReadyToPlay || state == ASVideoNodePlayerStatePlaybackLikelyToKeepUpButNotPlaying){
        [videoPlayer play];
    }
    
    if ([self.delegate respondsToSelector:@selector(browsePlayerNode:didChangePlayerState:)]) {
        [self.delegate browsePlayerNode:self didChangePlayerState:videoPlayer.playerState];
    }
}

- (void)toggleUnfavorite{
    [_bookmarkNode setImage:[UIImage imageNamed:@"favorite_browse"] forState:UIControlStateNormal];
    self.primaryKey = nil;
    self.savedVideoInfo = nil;
}

@end

