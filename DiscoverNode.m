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
#import "FoodheadAnalytics.h"
#import "UserAuthManager.h"

@interface DiscoverNode () <ASNetworkImageNodeDelegate, ASVideoNodeDelegate>

@property (nonatomic, strong) ASNetworkImageNode *thumbnailImageNode;
@property (nonatomic, strong) ASButtonNode *bookmarkNode;
@property (nonatomic, strong) ASTextNode *titleNode;
@property (nonatomic, strong) ASNetworkImageNode *sourceImgNode;
@property (nonatomic, strong) ASTextNode *sourceNode;
@property (nonatomic, strong) ASTextNode *categoryNode;


//IMPORTANT : need to do this because we can't acess our RLMObject's properties on different threads (which layoutAspecThatFits run on) so create a copy of our RLMObject's properties to be used on any thread we want...
@property (nonatomic, assign) CGFloat mediaWidth;
@property (nonatomic, assign) CGFloat mediaHeight;
@property (nonatomic, assign) BOOL isBlogContent;

@end

@implementation DiscoverNode

- (instancetype)initWithRestauarnt:(TPLRestaurant *)restaurant andPrimaryKey:(NSString *)primaryKey{
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _restaurantInfo = restaurant;
        
        if (restaurant.hasVideo.boolValue) {
            self.playerNode = [[ASVideoNode alloc]init];
            self.playerNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
            self.playerNode.delegate = self;
            self.playerNode.shouldAutoplay = NO;
            self.playerNode.shouldAutorepeat = YES;
            self.playerNode.muted = YES;
            _playerNode.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _mediaHeight = _restaurantInfo.blogVideoHeight.floatValue;
            _mediaWidth = _restaurantInfo.blogVideoWidth.floatValue;
        }else{
            _thumbnailImageNode = [[ASNetworkImageNode alloc]init];
            if (![NSString isEmpty:restaurant.blogPhotoLink]) {
                _thumbnailImageNode.URL = [NSURL URLWithString:restaurant.blogPhotoLink];
                _mediaHeight = _restaurantInfo.blogPhotoHeight.floatValue;
                _mediaWidth = _restaurantInfo.blogPhotoWidth.floatValue;
            }else{
                _thumbnailImageNode.URL = [NSURL URLWithString:restaurant.thumbnail];
                _mediaHeight = _restaurantInfo.thumbnailHeight.floatValue;
                _mediaWidth = _restaurantInfo.thumbnailWidth.floatValue;
            }
            _thumbnailImageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
            _thumbnailImageNode.placeholderFadeDuration = 0.15;
            _thumbnailImageNode.contentMode = UIViewContentModeScaleAspectFill;
            _thumbnailImageNode.delegate = self;
            
            //__weak typeof(self) weakSelf = self;
            //        [_thumbnailImageNode setImageModificationBlock:^UIImage *(UIImage *image){
            //            //Round corners on a background thread since it's a very inefficient UIKit property
            //            //https://github.com/facebookarchive/AsyncDisplayKit/issues/490
            //            weakSelf.thumbnailImageNode.cornerRadius = 7.0;
            //            weakSelf.thumbnailImageNode.clipsToBounds = YES;
            //            return image;
            //        }];
        }

        _bookmarkNode = [[ASButtonNode alloc]init];
        _bookmarkNode.backgroundColor = [UIColor clearColor];
        if (primaryKey) {
            self.restPrimaryKey = primaryKey;
            [_bookmarkNode setImage:[UIImage imageNamed:@"bookmark_filled"] forState:UIControlStateNormal];
        }else{
            [_bookmarkNode setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
        }
        [_bookmarkNode addTarget:self action:@selector(bookmarkClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        
        _titleNode = [[ASTextNode alloc]init];
        _titleNode.attributedText = [[NSAttributedString alloc]initWithString:_restaurantInfo.name attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:REST_PAGE_DETAIL_FONT_SIZE], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _titleNode.backgroundColor = [UIColor clearColor];
        _titleNode.maximumNumberOfLines = 2;
        _titleNode.layerBacked = YES;
        
        _categoryNode = [[ASTextNode alloc]init];
        _categoryNode.backgroundColor = [UIColor clearColor];
        _categoryNode.maximumNumberOfLines = 1;
        _categoryNode.layerBacked = YES;
        if(_restaurantInfo.categories.count > 0){
            _categoryNode.attributedText = [[NSAttributedString alloc]initWithString:[_restaurantInfo.categories firstObject] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:REST_PAGE_DETAIL_FONT_SIZE], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        }
        
        _sourceNode = [[ASTextNode alloc]init];
        _sourceNode.backgroundColor = [UIColor clearColor];
        _sourceNode.maximumNumberOfLines = 1;
        _sourceNode.layerBacked = YES;
        
        NSString *sourceImg;
        if (_restaurantInfo.blogTitle) {
            sourceImg = _restaurantInfo.blogProfileLink;
            _sourceNode.attributedText = [[NSAttributedString alloc]initWithString:_restaurantInfo.blogTitle attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:REST_PAGE_DETAIL_FONT_SIZE], NSForegroundColorAttributeName : [UIColor blackColor]}];
            _isBlogContent = YES;
        }else{
            _isBlogContent = NO;
        }
        
        _sourceImgNode = [[ASNetworkImageNode alloc]init];
        _sourceImgNode.backgroundColor = [UIColor clearColor];
        _sourceImgNode.URL = [NSURL URLWithString:sourceImg];
        _sourceImgNode.contentMode = UIViewContentModeScaleAspectFit;
//        [_sourceImgNode setImageModificationBlock:^UIImage *(UIImage *image) {
//            return [UIImage drawRoundedCornersForImage:image withCornerRadius:image.size.width/2];
//        }];
        _sourceImgNode.layerBacked = YES;
        _sourceImgNode.shouldRasterizeDescendants = YES;
        
        self.automaticallyManagesSubnodes = YES;
        
        //self.sourceNode.backgroundColor = [UIColor greenColor];
        //self.sourceImgNode.backgroundColor = [UIColor blueColor];
        //self.titleNode.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)didLoad{
    [super didLoad];
    _playerNode.cornerRadius = 8.0;
    _playerNode.clipsToBounds = YES;
    
    _thumbnailImageNode.cornerRadius = 7.0;
    _thumbnailImageNode.clipsToBounds = YES;
    
    _sourceImgNode.clipsToBounds = YES;
    _sourceImgNode.cornerRadius = 14.0;
    _sourceImgNode.borderColor = UIColorFromRGB(0x979797).CGColor;
    _sourceImgNode.borderWidth = 0.6;
    _sourceImgNode.contentMode = UIViewContentModeCenter;
    _sourceImgNode.layer.shouldRasterize = YES;
    _sourceImgNode.layer.rasterizationScale = [[UIScreen mainScreen]scale];
}

#warning This isn't all necessary - just use the original TPLRestaurant, but check if it matches with an entry in Realm then set bookmark to be filled..

- (instancetype)initWithSavedRestaurant:(DiscoverRealm *)rlmRestaurant{
    self = [super init];
    if (self) {
        _savedRestaurantInfo = rlmRestaurant;
        
        if (rlmRestaurant.hasVideo.boolValue)
        {
            _playerNode = [[ASVideoNode alloc]init];
            _playerNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
            _playerNode.delegate = self;
            _playerNode.shouldAutoplay = NO;
            _playerNode.shouldAutorepeat = YES;
            _playerNode.muted = YES;

            _playerNode.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            _mediaHeight = _restaurantInfo.blogVideoHeight.floatValue;
            _mediaWidth = _restaurantInfo.blogVideoWidth.floatValue;
        }else{
            _thumbnailImageNode = [[ASNetworkImageNode alloc]init];
            if (rlmRestaurant.thumbnailPhotoLink) {
                _thumbnailImageNode.URL = [NSURL URLWithString:rlmRestaurant.thumbnailPhotoLink];
                _mediaHeight = rlmRestaurant.thumbnailPhotoHeight.floatValue;
                _mediaWidth = rlmRestaurant.thumbnailPhotoWidth.floatValue;
            }
            _thumbnailImageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
            _thumbnailImageNode.placeholderFadeDuration = 0.15;
            _thumbnailImageNode.contentMode = UIViewContentModeScaleAspectFill;
            _thumbnailImageNode.delegate = self;
            
            //__weak typeof(self) weakSelf = self;
            //        [_thumbnailImageNode setImageModificationBlock:^UIImage *(UIImage *image){
            //            //Round corners on a background thread since it's a very inefficient UIKit property
            //            //https://github.com/facebookarchive/AsyncDisplayKit/issues/490
            //            weakSelf.thumbnailImageNode.cornerRadius = 7.0;
            //            weakSelf.thumbnailImageNode.clipsToBounds = YES;
            //            return image;
            //        }];
        }
        
        
        _thumbnailImageNode = [[ASNetworkImageNode alloc]init];
        if (![NSString isEmpty:_savedRestaurantInfo.thumbnailPhotoLink]) {
            _thumbnailImageNode.URL = [NSURL URLWithString:_savedRestaurantInfo.thumbnailPhotoLink];
        }
        _thumbnailImageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
        _thumbnailImageNode.placeholderFadeDuration = 0.15;
        _thumbnailImageNode.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageNode.delegate = self;

        
        _bookmarkNode = [[ASButtonNode alloc]init];
        _bookmarkNode.backgroundColor = [UIColor clearColor];
        [_bookmarkNode setImage:[UIImage imageNamed:@"bookmark_filled"] forState:UIControlStateNormal];
        [_bookmarkNode addTarget:self action:@selector(bookmarkClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        
        _titleNode = [[ASTextNode alloc]init];
        _titleNode.attributedText = [[NSAttributedString alloc]initWithString:_savedRestaurantInfo.name attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:REST_PAGE_DETAIL_FONT_SIZE], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        _titleNode.backgroundColor = [UIColor clearColor];
        _titleNode.maximumNumberOfLines = 2;
        _titleNode.layerBacked = YES;
        
        _categoryNode = [[ASTextNode alloc]init];
        _categoryNode.backgroundColor = [UIColor clearColor];
        _categoryNode.maximumNumberOfLines = 1;
        _categoryNode.layerBacked = YES;
        if(_savedRestaurantInfo.primaryCategory){
            _categoryNode.attributedText = [[NSAttributedString alloc]initWithString:_savedRestaurantInfo.primaryCategory attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:REST_PAGE_DETAIL_FONT_SIZE], NSForegroundColorAttributeName : UIColorFromRGB(0x585858)}];
        }
        
        _sourceNode = [[ASTextNode alloc]init];
        _sourceNode.backgroundColor = [UIColor clearColor];
        _sourceNode.maximumNumberOfLines = 1;
        _sourceNode.layerBacked = YES;
        
        NSString *sourceImg;
        if (_savedRestaurantInfo.sourceBlogName) {
            sourceImg = _savedRestaurantInfo.sourceBlogProfilePhoto;
            _sourceNode.attributedText = [[NSAttributedString alloc]initWithString:_savedRestaurantInfo.sourceBlogName attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:REST_PAGE_DETAIL_FONT_SIZE], NSForegroundColorAttributeName : [UIColor blackColor]}];
            _isBlogContent = YES;
        }else{
            _isBlogContent = NO;
        }
    
        _sourceImgNode = [[ASNetworkImageNode alloc]init];
        _sourceImgNode.backgroundColor = [UIColor clearColor];
        _sourceImgNode.URL = [NSURL URLWithString:sourceImg];
        _sourceImgNode.contentMode = UIViewContentModeScaleAspectFit;

        if (_savedRestaurantInfo.thumbnailPhotoLink) {
            _mediaHeight = _savedRestaurantInfo.thumbnailPhotoHeight.floatValue;
            _mediaWidth = _savedRestaurantInfo.thumbnailPhotoWidth.floatValue;
        }else{
            _mediaHeight = _savedRestaurantInfo.thumbnailVideoHeight.floatValue;
            _mediaWidth = _savedRestaurantInfo.thumbnailVideoWidth.floatValue;
        }
        
//        [_sourceImgNode setImageModificationBlock:^UIImage *(UIImage *image) {
//            return [UIImage drawRoundedCornersForImage:image withCornerRadius:image.size.width/2];
//        }];
        _sourceImgNode.layerBacked = YES;
        
        self.restPrimaryKey = _savedRestaurantInfo.foursqId;
        self.automaticallyManagesSubnodes = YES;
        
        //Layout debugging
        //self.sourceNode.backgroundColor = [UIColor greenColor];
        //self.sourceImgNode.backgroundColor = [UIColor blueColor];
        //self.titleNode.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    ASStackLayoutSpec *verticalStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    verticalStack.spacing = 2.0;
    
    CGFloat ratio;
    if (_mediaWidth > 0 && _mediaHeight > 0) {
        ratio = _mediaHeight/_mediaWidth;
    }else{
        ratio = 1.0;
    }

    ASRatioLayoutSpec *mediaRatioSpec;
    if (self.playerNode) {
        mediaRatioSpec = [ASRatioLayoutSpec
                          ratioLayoutSpecWithRatio:ratio
                          child:self.playerNode];
    }else{
        mediaRatioSpec = [ASRatioLayoutSpec
                          ratioLayoutSpecWithRatio:ratio
                          child:self.thumbnailImageNode];
    }
    mediaRatioSpec.alignSelf = ASStackLayoutAlignSelfCenter;
    
    //Always place bookmark button in bottom right corner relative to ratio layout.
    _bookmarkNode.style.preferredSize = CGSizeMake(40.0, 40.0);
    ASRelativeLayoutSpec *relativeSpec = [ASRelativeLayoutSpec relativePositionLayoutSpecWithHorizontalPosition:ASRelativeLayoutSpecPositionEnd verticalPosition:ASRelativeLayoutSpecPositionEnd sizingOption:ASRelativeLayoutSpecSizingOptionDefault child:_bookmarkNode];
    ASOverlayLayoutSpec *imageSpec = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:mediaRatioSpec overlay:relativeSpec];
    
    UIEdgeInsets detailsInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0);
    UIEdgeInsets blogInsets = UIEdgeInsetsMake(3.0, 6.0, 0.0, 6.0);
    
    ASStackLayoutSpec *sourceStack = [ASStackLayoutSpec horizontalStackLayoutSpec];
    sourceStack.style.flexShrink = 1.0;
    sourceStack.alignSelf = ASStackLayoutAlignSelfStart;
    sourceStack.alignItems = ASStackLayoutAlignItemsCenter;
    _sourceImgNode.style.preferredSize = CGSizeMake(28.0, 28.0);
    sourceStack.children = @[[ASInsetLayoutSpec insetLayoutSpecWithInsets:blogInsets child:_sourceImgNode], _sourceNode];
    
    ASStackLayoutSpec *detailStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    detailStack.spacingBefore = 4.0;
    detailStack.spacingAfter = DISCOVER_NODE_SPACING;
    detailStack.style.flexShrink = 1.0;
    detailStack.alignSelf = ASStackLayoutAlignSelfStart;
    
    if (self.isBlogContent) {
        if (_categoryNode.attributedText) {
            detailStack.children = @[[ASInsetLayoutSpec insetLayoutSpecWithInsets:detailsInsets child:_titleNode], [ASInsetLayoutSpec insetLayoutSpecWithInsets:detailsInsets child:_categoryNode], sourceStack];
        }else{
            detailStack.children = @[[ASInsetLayoutSpec insetLayoutSpecWithInsets:detailsInsets child:_titleNode], sourceStack];
        }
    }else{
        detailStack.children = @[[ASInsetLayoutSpec insetLayoutSpecWithInsets:detailsInsets child:_titleNode], [ASInsetLayoutSpec insetLayoutSpecWithInsets:detailsInsets child:_categoryNode]];
    }

    verticalStack.justifyContent = ASStackLayoutJustifyContentStart;
    verticalStack.children = @[imageSpec, detailStack];
    return verticalStack;
}

- (void)bookmarkClicked{
    //Don't allow user to bookmark if they don't sign up
    if (![[UserAuthManager sharedInstance]getCurrentUser]) {
        if([self.delegate respondsToSelector:@selector(promptUserSignup)]){
            [self.delegate promptUserSignup];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.restaurantInfo];
            [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"favoritedRestaurant"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        return;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    //If we have a primary key stored, the restaurant is a favorite so delete it from Realm.
    if (self.restPrimaryKey) {
        NSError *error;
        [realm beginWriteTransaction];
        [realm deleteObject:[DiscoverRealm objectForPrimaryKey:self.restPrimaryKey]];
        [realm commitWriteTransaction:&error];
        if (error) {
            DLog(@"Failed to delete bookmark to Realm DB: %@", error);
        }else{
            //[self unfavoriteNode];
            [FoodheadAnalytics logEvent:USER_UNFAVORITED_RESTAURANT];
        }
    }else{
        DiscoverRealm *discoverRlm = [[DiscoverRealm alloc]init];
        discoverRlm.name = self.restaurantInfo.name;
        discoverRlm.foursq_rating = self.restaurantInfo.foursq_rating;
        discoverRlm.foursqId = self.restaurantInfo.foursqId;
        discoverRlm.hasVideo = self.restaurantInfo.hasVideo;
        if (self.restaurantInfo.categories.count > 0) {
            discoverRlm.primaryCategory = [self.restaurantInfo.categories firstObject];
        }
        discoverRlm.lat = self.restaurantInfo.latitude;
        discoverRlm.lng = self.restaurantInfo.longitude;
        discoverRlm.website = self.restaurantInfo.website;
        
        if (self.restaurantInfo.address) {
            discoverRlm.address = self.restaurantInfo.address;
            discoverRlm.zipCode = self.restaurantInfo.zipCode;
            discoverRlm.city = self.restaurantInfo.city;
            discoverRlm.state = self.restaurantInfo.state;
        }
        
        if (self.restaurantInfo.hasVideo.boolValue) {
            discoverRlm.thumbnailVideoLink = self.restaurantInfo.blogVideoLink;
            discoverRlm.thumbnailVideoWidth = self.restaurantInfo.blogVideoWidth;
            discoverRlm.thumbnailVideoHeight = self.restaurantInfo.blogVideoHeight;
        }else{
            if(self.restaurantInfo.blogPhotoLink){
                discoverRlm.thumbnailPhotoLink = self.restaurantInfo.blogPhotoLink;
                discoverRlm.thumbnailPhotoWidth = self.restaurantInfo.blogPhotoWidth;
                discoverRlm.thumbnailPhotoHeight = self.restaurantInfo.blogPhotoHeight;
            }else{
                discoverRlm.thumbnailPhotoLink = self.restaurantInfo.thumbnail;
                discoverRlm.thumbnailPhotoWidth = self.restaurantInfo.thumbnailWidth;
                discoverRlm.thumbnailPhotoHeight = self.restaurantInfo.thumbnailHeight;
            }
        }

        discoverRlm.sourceBlogName = self.restaurantInfo.blogTitle;
        discoverRlm.sourceBlogProfilePhoto = self.restaurantInfo.blogPhotoLink;
        discoverRlm.creationDate = [NSDate date];
        
        NSError *error;
        [realm beginWriteTransaction];
        [realm addObject:discoverRlm];
        [realm commitWriteTransaction:&error];
        if (error) {
            DLog(@"Failed to save bookmark to Realm DB: %@", error);
        }else{
            //Not needed since our discover VC for when Realm adds an objects (method takes care of UI update)
            //[self favoriteNodeWithInfo:discoverRlm];
            [FoodheadAnalytics logEvent:USER_FAVORITED_RESTAURANT];
        }
    }
}

#pragma mark - Helper methods

- (void)unfavoriteNode {
    [_bookmarkNode setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
    self.restPrimaryKey = nil;
    self.savedRestaurantInfo = nil;
}

- (void)favoriteNodeWithInfo:(DiscoverRealm *)fav {
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _bookmarkNode.view.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [_bookmarkNode setImage:[UIImage imageNamed:@"bookmark_filled"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.1 animations:^{
            _bookmarkNode.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    }];
    self.savedRestaurantInfo = fav;
    self.restPrimaryKey = _savedRestaurantInfo.foursqId;
}

#pragma VideoNodePlayer Delegate methods

- (void)didTapVideoNode:(ASVideoNode *)videoNode{
    [videoNode pause];
    if ([self.delegate respondsToSelector:@selector(discoverNode:didClickVideoWithRestaurant:)]) {
        [self.delegate discoverNode:self didClickVideoWithRestaurant:self.restaurantInfo];
    }
}

@end
