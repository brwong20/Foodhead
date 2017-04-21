//
//  ExpandedChartCollectionViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 4/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "ExpandedChartCollectionViewCell.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"
#import "NSString+IsEmpty.h"

#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ExpandedChartCollectionViewCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *coverImage;
@property (nonatomic, strong) TTTAttributedLabel *nameLabel;

@end

@implementation ExpandedChartCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCell:frame];
        
    }
    return self;
}

- (void)setupCell:(CGRect)frame{
    self.backgroundColor = [UIColor clearColor];
    
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 8.0;
    self.containerView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    self.containerView.layer.shadowOpacity = 0.4;
    self.containerView.layer.shadowRadius = 4.0;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.containerView.layer.shouldRasterize = YES;
    [self.contentView addSubview:self.containerView];
    
    self.coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.containerView.bounds.size.width/2 - self.containerView.bounds.size.width * 0.445, self.containerView.bounds.size.width * 0.05, self.containerView.bounds.size.width  * 0.89, self.containerView.bounds.size.width * 0.89)];
    self.coverImage.backgroundColor = [UIColor clearColor];
    self.coverImage.clipsToBounds = YES;
    self.coverImage.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.coverImage.layer.shouldRasterize = YES;
    self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImage.layer.cornerRadius = 5.0;
    [self.containerView addSubview:self.coverImage];
    
    //Conver to text view
    self.nameLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.coverImage.frame), CGRectGetMaxY(self.coverImage.frame) + self.containerView.bounds.size.height * 0.01, self.coverImage.bounds.size.width, self.containerView.bounds.size.height * 0.17)];
    self.nameLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.numberOfLines = 2;
    self.nameLabel.lineSpacing = -REST_PAGE_HEADER_FONT_SIZE * 0.25;
    self.nameLabel.font = [UIFont nun_lightFontWithSize:REST_PAGE_HEADER_FONT_SIZE];
    self.nameLabel.textColor = [UIColor blackColor];
    [self.containerView addSubview:self.nameLabel];    
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.coverImage.image = nil;
    self.nameLabel.text = nil;
}

- (void)populateRestaurantInfo:(TPLRestaurant *)restaurant{
//    self.nameLabel.alpha = 0.0;
//    [UIView animateWithDuration:0.25 animations:^{
        self.nameLabel.text = restaurant.name;
//        self.nameLabel.alpha = 1.0;
//    }];
    
    if ([NSString isEmpty:restaurant.thumbnail]) {
        [self.coverImage setImage:[UIImage imageNamed:@"image_unavailable"]];
    }else{
        self.coverImage.alpha = 0.0;
        [self.coverImage sd_setImageWithURL:[NSURL URLWithString:restaurant.thumbnail]placeholderImage:[UIImage new] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                
                BOOL animated = NO;
                
                if (cacheType == SDImageCacheTypeDisk || cacheType == SDImageCacheTypeNone) {
                    animated = YES;
                }
                
                [self.coverImage setImage:image];
                
                if (animated) {
                    [UIView animateWithDuration:0.25 animations:^{
                        self.coverImage.alpha = 1;
                    }];
                } else {
                    self.coverImage.alpha = 1;
                }
            }
        }];
    }
}

@end
