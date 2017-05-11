//
//  VideoPlayerNode.m
//  Foodhead
//
//  Created by Brian Wong on 4/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "VideoPlayerNode.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "UIImage+Utilities.h"

@interface VideoPlayerNode () <ASVideoNodeDelegate, ASVideoPlayerNodeDelegate>

@property (nonatomic, strong) TPLRestaurant *restaurantInfo;

@property (nonatomic, strong) ASButtonNode *bookmarkNode;
@property (nonatomic, strong) ASTextNode *titleNode;
@property (nonatomic, strong) ASNetworkImageNode *sourceImgNode;
@property (nonatomic, strong) ASTextNode *sourceNode;

@end

@implementation VideoPlayerNode

- (instancetype)initWithRestaurant:(TPLRestaurant *)restaurant{
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.restaurantInfo = restaurant;
        
        self.playerNode = [[ASVideoNode alloc]init];
        self.playerNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
        self.playerNode.delegate = self;
        self.playerNode.shouldAutoplay = NO;
        self.playerNode.shouldAutorepeat = YES;
        self.playerNode.muted = YES;
        self.playerNode.cornerRadius = 8.0;
        self.playerNode.clipsToBounds = YES;
        self.playerNode.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        _bookmarkNode = [[ASButtonNode alloc]init];
        _bookmarkNode.backgroundColor = [UIColor clearColor];
        [_bookmarkNode setImage:[UIImage imageNamed:@"bookmark_btn"] forState:UIControlStateNormal];
        [_bookmarkNode addTarget:self action:@selector(bookmarkClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        
        _titleNode = [[ASTextNode alloc]init];
        _titleNode.attributedText = [[NSAttributedString alloc]initWithString:_restaurantInfo.name attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:REST_PAGE_DETAIL_FONT_SIZE], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _titleNode.backgroundColor = [UIColor clearColor];
        _titleNode.maximumNumberOfLines = 2;
        _titleNode.layerBacked = YES;
        
        _sourceImgNode = [[ASNetworkImageNode alloc]init];
        _sourceImgNode.backgroundColor = [UIColor whiteColor];
        _sourceImgNode.URL = [NSURL URLWithString:_restaurantInfo.blogProfileLink];
        //Corner radius is an expensive UIKit property that runs on the main trhead so we will round corners on a background thread instead.
        [_sourceImgNode setImageModificationBlock:^UIImage *(UIImage *image) {
            return [UIImage drawRoundedCornersForImage:image withCornerRadius:image.size.height/2];
        }];
        _sourceImgNode.layerBacked = YES;
        
        _sourceNode = [[ASTextNode alloc]init];
        _sourceNode.backgroundColor = [UIColor clearColor];
        _sourceNode.maximumNumberOfLines = 1;
        _sourceNode.layerBacked = YES;
        _sourceNode.attributedText = [[NSAttributedString alloc]initWithString:_restaurantInfo.blogName attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:REST_PAGE_DETAIL_FONT_SIZE], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        
        //self.sourceNode.backgroundColor = [UIColor greenColor];
        //self.sourceImgNode.backgroundColor = [UIColor blueColor];
        //self.titleNode.backgroundColor = [UIColor blackColor];
        
        self.automaticallyManagesSubnodes = YES;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    ASStackLayoutSpec *verticalStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    
    CGFloat ratio = self.restaurantInfo.blogVideoHeight.floatValue / self.restaurantInfo.blogVideoWidth.floatValue;
    ASRatioLayoutSpec *videoRatioSpec = [ASRatioLayoutSpec
                                         ratioLayoutSpecWithRatio:ratio
                                         child:self.playerNode];
    videoRatioSpec.alignSelf = ASStackLayoutAlignSelfCenter;
    //Always place bookmark button in bottom right corner relative to ratio layout.
    _bookmarkNode.style.preferredSize = CGSizeMake(40.0, 40.0);
    ASRelativeLayoutSpec *relativeSpec = [ASRelativeLayoutSpec relativePositionLayoutSpecWithHorizontalPosition:ASRelativeLayoutSpecPositionEnd verticalPosition:ASRelativeLayoutSpecPositionEnd sizingOption:ASRelativeLayoutSpecSizingOptionDefault child:_bookmarkNode];
    ASOverlayLayoutSpec *imageSpec = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:videoRatioSpec overlay:relativeSpec];
    
    UIEdgeInsets detailsInsets = UIEdgeInsetsMake(0.0, 3.0, 0.0, 3.0);
    
    ASStackLayoutSpec *sourceStack = [ASStackLayoutSpec horizontalStackLayoutSpec];
    sourceStack.spacing = 2.0;
    sourceStack.style.flexShrink = 1.0;
    sourceStack.alignSelf = ASStackLayoutAlignSelfStart;
    _sourceImgNode.style.preferredSize = CGSizeMake(22.0, 22.0);
    sourceStack.children = @[[ASInsetLayoutSpec insetLayoutSpecWithInsets:detailsInsets child:_sourceImgNode], [ASInsetLayoutSpec insetLayoutSpecWithInsets:detailsInsets child:_sourceNode]];
    
    ASStackLayoutSpec *detailStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    detailStack.spacing = 2.0;
    detailStack.style.flexShrink = 1.0;
    detailStack.spacingAfter = DISCOVER_NODE_SPACING;
    detailStack.alignSelf = ASStackLayoutAlignSelfStart;
    detailStack.children = @[[ASInsetLayoutSpec insetLayoutSpecWithInsets:detailsInsets child:_titleNode], sourceStack];
    
    verticalStack.justifyContent = ASStackLayoutJustifyContentStart;
    verticalStack.children = @[imageSpec, detailStack];
    
    return verticalStack;
}

#pragma VideoNodePlayer Delegate methods

- (void)didTapVideoNode:(ASVideoNode *)videoNode{
    [videoNode.player seekToTime:kCMTimeZero];
    [videoNode.player play];
}


#pragma mark - Helper methods
- (void)bookmarkClicked{
    
}

@end
