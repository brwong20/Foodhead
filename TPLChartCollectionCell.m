//
//  TPLChartCollectionCell.m
//  FoodWise
//
//  Created by Brian Wong on 2/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartCollectionCell.h"
#import "LayoutBounds.h"

#import "UIFont+Extension.h"
#import "NSString+IsEmpty.h"
#import "FoodWiseDefines.h"

#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <SDWebImage/UIImageView+WebCache.h>


@implementation TPLChartCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCell:frame];
    }
    return self;
}

- (void)setupCell:(CGRect)frame{
    self.backgroundColor = [UIColor whiteColor];
    
    self.coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height * 0.8)];
    self.coverImage.backgroundColor = [UIColor clearColor];
    self.coverImage.clipsToBounds = YES;
    self.coverImage.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.coverImage.layer.shouldRasterize = YES;
    self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImage.layer.cornerRadius = 6.0;
    [self.contentView addSubview:self.coverImage];
    
    //Conver to text view
    self.nameLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.coverImage.frame), CGRectGetMaxY(self.coverImage.frame) + frame.size.height * 0.01, frame.size.width, frame.size.height * 0.19)];
    self.nameLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.numberOfLines = 2;
    self.nameLabel.lineSpacing = -REST_PAGE_HEADER_FONT_SIZE * 0.2;
    self.nameLabel.font = [UIFont nun_lightFontWithSize:REST_PAGE_HEADER_FONT_SIZE];
    self.nameLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.nameLabel];
}

- (void)populateRestauarantInfo:(TPLRestaurant *)restaurant{
    self.nameLabel.alpha = 0.0;    
    [UIView animateWithDuration:0.25 animations:^{
        self.nameLabel.text = restaurant.name;
        self.nameLabel.alpha = 1.0;
    }];
    
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

- (void)prepareForReuse{
    self.coverImage.image = nil;
}

@end
