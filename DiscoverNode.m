//
//  DiscoverNode.m
//  Foodhead
//
//  Created by Brian Wong on 4/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "DiscoverNode.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "NSString+IsEmpty.h"
#import "UIImage+Utilities.h"

#import <AsyncDisplayKit/UIView+ASConvenience.h>
#import <AsyncDisplayKit/UIImage+ASConvenience.h>

@interface DiscoverNode () <ASNetworkImageNodeDelegate>

@property (nonatomic, strong) ASNetworkImageNode *thumbnailImageNode;
@property (nonatomic, strong) ASButtonNode *bookmarkNode;
@property (nonatomic, strong) ASTextNode *titleNode;
@property (nonatomic, strong) ASNetworkImageNode *sourceImgNode;
@property (nonatomic, strong) ASTextNode *sourceNode;

@end

@implementation DiscoverNode

- (instancetype)initWithRestauarnt:(TPLRestaurant *)restaurant{
    self = [super init];
    if (self) {
        //[[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //self.backgroundColor = [UIColor redColor];
        
        _restaurantInfo = restaurant;
        
        _thumbnailImageNode = [[ASNetworkImageNode alloc]init];
        if (![NSString isEmpty:restaurant.blogPhotoLink]) {
            _thumbnailImageNode.URL = [NSURL URLWithString:restaurant.blogPhotoLink];
        }else{
            _thumbnailImageNode.URL = [NSURL URLWithString:restaurant.thumbnail];
        }
        _thumbnailImageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
        _thumbnailImageNode.placeholderFadeDuration = 0.15;
        _thumbnailImageNode.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageNode.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        [_thumbnailImageNode setImageModificationBlock:^UIImage *(UIImage *image){
            //Round corners on a background thread since it's a very inefficient UIKit property
            //https://github.com/facebookarchive/AsyncDisplayKit/issues/490
            weakSelf.thumbnailImageNode.cornerRadius = 7.0;
            weakSelf.thumbnailImageNode.clipsToBounds = YES;
            return image;
        }];

        _bookmarkNode = [[ASButtonNode alloc]init];
        _bookmarkNode.backgroundColor = [UIColor clearColor];
        [_bookmarkNode setImage:[UIImage imageNamed:@"bookmark_btn"] forState:UIControlStateNormal];
        [_bookmarkNode addTarget:self action:@selector(bookmarkClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        
        _titleNode = [[ASTextNode alloc]init];
        _titleNode.attributedText = [[NSAttributedString alloc]initWithString:_restaurantInfo.name attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:REST_PAGE_DETAIL_FONT_SIZE], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _titleNode.backgroundColor = [UIColor clearColor];
        _titleNode.maximumNumberOfLines = 2;
        _titleNode.layerBacked = YES;
        
        
        _sourceNode = [[ASTextNode alloc]init];
        _sourceNode.backgroundColor = [UIColor clearColor];
        _sourceNode.maximumNumberOfLines = 1;
        _sourceNode.layerBacked = YES;
        
        NSString *sourceName;
        NSString *sourceImg;
        if (_restaurantInfo.blogName) {
            sourceName = _restaurantInfo.blogTitle;
            sourceImg = _restaurantInfo.blogProfileLink;
        }else{
            if(_restaurantInfo.categories.count > 0){
                sourceName = [_restaurantInfo.categories firstObject];
            }
        }
        _sourceNode.attributedText = [[NSAttributedString alloc]initWithString:sourceName attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:REST_PAGE_DETAIL_FONT_SIZE], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        
        _sourceImgNode = [[ASNetworkImageNode alloc]init];
        _sourceImgNode.backgroundColor = [UIColor clearColor];
        _sourceImgNode.URL = [NSURL URLWithString:sourceImg];
        _sourceImgNode.contentMode = UIViewContentModeScaleAspectFit;
        
        [_sourceImgNode setImageModificationBlock:^UIImage *(UIImage *image) {
            return [UIImage drawRoundedCornersForImage:image withCornerRadius:image.size.width/2];
        }];
        _sourceImgNode.layerBacked = YES;
        _sourceImgNode.shouldRasterizeDescendants = YES;

        //self.sourceNode.backgroundColor = [UIColor greenColor];
        //self.sourceImgNode.backgroundColor = [UIColor blueColor];
        //self.titleNode.backgroundColor = [UIColor blackColor];
        
        self.automaticallyManagesSubnodes = YES;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    ASStackLayoutSpec *verticalStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    verticalStack.spacing = 2.0;
    
    CGFloat ratio;
    if (self.restaurantInfo.blogName) {
        ratio = self.restaurantInfo.blogPhotoHeight.floatValue / self.restaurantInfo.blogPhotoWidth.floatValue;
    }else if(self.restaurantInfo.thumbnail){
        ratio = _restaurantInfo.thumbnailHeight.floatValue / _restaurantInfo.thumbnailWidth.floatValue;
    }else{
        //No image, use square placeholder - set better placeholder
        ratio = 1.0;
    }

    ASRatioLayoutSpec *mediaRatioSpec = [ASRatioLayoutSpec
                                         ratioLayoutSpecWithRatio:ratio
                                         child:self.thumbnailImageNode];
    mediaRatioSpec.alignSelf = ASStackLayoutAlignSelfCenter;
    
//    //Always place bookmark button in bottom right corner relative to ratio layout.
//    _bookmarkNode.style.preferredSize = CGSizeMake(40.0, 40.0);
//    ASRelativeLayoutSpec *relativeSpec = [ASRelativeLayoutSpec relativePositionLayoutSpecWithHorizontalPosition:ASRelativeLayoutSpecPositionEnd verticalPosition:ASRelativeLayoutSpecPositionEnd sizingOption:ASRelativeLayoutSpecSizingOptionDefault child:_bookmarkNode];
//    ASOverlayLayoutSpec *imageSpec = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:mediaRatioSpec overlay:relativeSpec];
    
    UIEdgeInsets detailsInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0);
    UIEdgeInsets blogInsets = UIEdgeInsetsMake(4.0, 6.0, 0.0, 6.0);
    
    ASStackLayoutSpec *sourceStack = [ASStackLayoutSpec horizontalStackLayoutSpec];
    sourceStack.style.flexShrink = 1.0;
    sourceStack.spacing = 1.0;
    sourceStack.alignSelf = ASStackLayoutAlignSelfStart;
    sourceStack.alignItems = ASStackLayoutAlignItemsCenter;
    _sourceImgNode.style.preferredSize = CGSizeMake(25.0, 25.0);
    
    if (_restaurantInfo.blogName) {
        sourceStack.children = @[[ASInsetLayoutSpec insetLayoutSpecWithInsets:blogInsets child:_sourceImgNode], [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0) child:_sourceNode]];
    }else{
        sourceStack.children = @[[ASInsetLayoutSpec insetLayoutSpecWithInsets:detailsInsets child:_sourceNode]];
    }
    
    ASStackLayoutSpec *detailStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    detailStack.spacingBefore = 4.0;
    detailStack.spacingAfter = DISCOVER_NODE_SPACING;
    detailStack.style.flexShrink = 1.0;
    detailStack.alignSelf = ASStackLayoutAlignSelfStart;
    detailStack.children = @[[ASInsetLayoutSpec insetLayoutSpecWithInsets:detailsInsets child:_titleNode], sourceStack];
    
//    imageSpec.style.flexBasis = ASDimensionMake(@"90%");
//    detailStack.style.flexBasis = ASDimensionMake(@"10%");
    
    verticalStack.justifyContent = ASStackLayoutJustifyContentStart;
    verticalStack.children = @[mediaRatioSpec, detailStack];
    
    return verticalStack;
}

- (void)imageNode:(ASNetworkImageNode *)imageNode didLoadImage:(UIImage *)image{
    //Dynamically resize here after getting image dimensions?

}

- (void)bookmarkClicked{

}

#pragma mark - Helper methods


@end
