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
@property (nonatomic, assign) BOOL isFullscreen;
@property (nonatomic, assign) BOOL controlsHidden;

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

@end

@implementation BrowsePlayerNode

- (instancetype)initWithVideo:(BrowseVideo *)videoInfo{
    self = [super init];
    if (self) {
        // Automatically manage subnode add, removal, animation, etc.
        self.automaticallyManagesSubnodes = YES;
//        self.cornerRadius = 10.0;
//        self.clipsToBounds = YES;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _videoInfo = videoInfo;
        
        _videoNode = [[ASVideoPlayerNode alloc]init];
        _videoNode.delegate = self;
        _videoNode.backgroundColor = [UIColor blackColor];
        _videoNode.muted = NO;
        _videoNode.gravity = AVLayerVideoGravityResizeAspect;
//        _videoNode.cornerRadius = 7.0;
        self.controlsHidden = YES;
        
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
        //_titleNode.maximumNumberOfLines = 2;
        
//        _bookmarkNode = [[ASButtonNode alloc]init];
//        _bookmarkNode.backgroundColor = [UIColor clearColor];
//        [_bookmarkNode setImage:[UIImage imageNamed:@"bookmark_btn"] forState:UIControlStateNormal];
//        [_bookmarkNode addTarget:self action:@selector(bookmarkClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        
//        _bookmarkImgNode = [[ASImageNode alloc]init];
//        _bookmarkImgNode.backgroundColor = [UIColor clearColor];
//        _bookmarkImgNode.image = [UIImage imageNamed:@"bookmark"];
//        _bookmarkImgNode.layerBacked = YES;
//        
//        _bookmarkCountNode = [[ASTextNode alloc]init];
//        _bookmarkCountNode.backgroundColor = [UIColor clearColor];
//        _bookmarkCountNode.attributedText = [[NSAttributedString alloc]initWithString:@"68923" attributes:textAttributes];
//        _bookmarkCountNode.maximumNumberOfLines = 1;
//        _bookmarkCountNode.layerBacked = YES;
        
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

//- (void)didEnterVisibleState{
//    [super didEnterVisibleState];
//}
//
//- (void)didExitVisibleState{
//    [super didExitVisibleState];
//    self.videoNode.asset = nil;
//}


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
    sourceStack.children = @[_sourceImgNode, headerStack];
    
    //Height & Width are changed when dealing with portrait mode
    CGFloat ratio = self.videoInfo.height.floatValue / self.videoInfo.width.floatValue;
    ASRatioLayoutSpec *videoRatioSpec = [ASRatioLayoutSpec
                                         ratioLayoutSpecWithRatio:ratio
                                         child:self.videoNode];
    videoRatioSpec.alignSelf = ASStackLayoutAlignSelfCenter;
    videoRatioSpec.spacingBefore = 1.5;
    videoRatioSpec.spacingAfter = 6.0;

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
    [verticalChildren addObject:videoRatioSpec];
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

- (void)videoPlayerNodeDidFinishInitialLoading:(ASVideoPlayerNode *)videoPlayer{
    [self.videoNode hideControlsAnimated:YES];
}

- (NSArray *)videoPlayerNodeNeededDefaultControls:(ASVideoPlayerNode *)videoPlayer{
    return @[ @(ASVideoPlayerNodeControlTypePlaybackButton),
              @(ASVideoPlayerNodeControlTypeElapsedText),
              @(ASVideoPlayerNodeControlTypeScrubber),
              @(ASVideoPlayerNodeControlTypeDurationText)];
    
}

//If user purposely play/pauses a specific video, pause all other videos
- (void)didTapPlayBackButton:(ASControlNode *)controlNode withState:(ASVideoNodePlayerState)state{
    [self.delegate playBackButtonTappedForNode:self withState:state];
}

#pragma mark - Helper methods

- (void)bookmarkClicked{
    
}

- (void)didTapVideoPlayerNode:(ASVideoPlayerNode *)videoPlayer{
    if (self.controlsHidden) {
        [self.videoNode showControlsAnimated:YES];
        self.controlsHidden = NO;
    }else{
        [self.videoNode hideControlsAnimated:YES];
        self.controlsHidden = YES;
    }
}

- (void)didTapFullScreenButtonNode:(ASButtonNode *)buttonNode{
    if (self.isFullscreen) {
        self.isFullscreen = NO;
        if ([self.delegate respondsToSelector:@selector(fullScreenWasDisabled)]) {
            [self.delegate fullScreenWasDisabled];
        }
    }else{
        self.isFullscreen = YES;
        if ([self.delegate respondsToSelector:@selector(fullScreenWasEnabled)]) {
            [self.delegate fullScreenWasEnabled];
        }
    }
    [self setNeedsLayout];
}

#pragma mark - Helper methods


@end

