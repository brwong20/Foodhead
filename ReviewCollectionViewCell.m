//
//  ReviewCollectionViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 3/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "ReviewCollectionViewCell.h"
#import "UIFont+Extension.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ReviewCollectionViewCell()

@property (nonatomic, strong) UIImageView *reviewImage;
@property (nonatomic, strong) UIView *captionView;
@property (nonatomic, strong) UILabel *captionLabel;

@end

@implementation ReviewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.reviewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.reviewImage.backgroundColor = [UIColor clearColor];
        self.reviewImage.clipsToBounds = YES;
        self.reviewImage.layer.rasterizationScale = [[UIScreen mainScreen]scale];
        self.reviewImage.layer.shouldRasterize = YES;
        self.reviewImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.reviewImage];
        
        self.captionView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - self.frame.size.height * 0.15, self.frame.size.width, self.frame.size.height * 0.15)];
        self.captionView.backgroundColor = [[UIColor clearColor]colorWithAlphaComponent:0.5];
        [self.contentView addSubview:self.captionView];
        
        self.captionLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.captionView.frame.size.width * 0.02, self.captionView.frame.size.height/2 - self.captionView.frame.size.height * 0.45, self.captionView.frame.size.width * 0.93, self.captionView.frame.size.height * 0.9)];
        self.captionLabel.backgroundColor = [UIColor clearColor];
        self.captionLabel.numberOfLines = 1;
        self.captionLabel.textColor = [UIColor whiteColor];
        self.captionLabel.font = [UIFont nun_fontWithSize:self.captionLabel.frame.size.height * 0.65];
        [self.captionView addSubview:self.captionLabel];
    }
    return self;
}

- (void)prepareForReuse{
    self.reviewImage.image = nil;
    self.captionLabel.text = nil;
    [super prepareForReuse];
}

- (void)populateUserReview:(UserReview *)review{
//    self.captionView.alpha = 0.0;
    self.captionLabel.text = review.name;
    //    [UIView animateWithDuration:0.2 animations:^{
    //        self.nameLabel.alpha = 1.0;
    //    }];

    [self.reviewImage sd_setImageWithURL:[NSURL URLWithString:review.thumbnailURL]placeholderImage:[UIImage new] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.reviewImage.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.reviewImage.alpha = 1;
        }];
    }];
    
}



@end
