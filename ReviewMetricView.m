//
//  ReviewMetricView.m
//  Foodhead
//
//  Created by Brian Wong on 3/20/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "ReviewMetricView.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ReviewMetricView ()

@property (nonatomic, strong) UserReview *review;

@property (nonatomic, strong) RatingContainerView *ratingView;
@property (nonatomic, strong) UIImageView *locationPin;
@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UIImageView *userAvatar;
@property (nonatomic, strong) UILabel *username;
@property (nonatomic, strong) UITapGestureRecognizer *dismissGesture;
@property (nonatomic, assign) BOOL metricsShowing;

@end

@implementation ReviewMetricView

- (void)setupCaption{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;//IMPORTANT: This is necessary in order to let the subview's gesture recognizer receive touch
    
    self.metricsShowing = YES;
    
    self.ratingView = [[RatingContainerView alloc]initWithFrame:CGRectMake(0, 0, APPLICATION_FRAME.size.width, APPLICATION_FRAME.size.height * 0.08)];
    self.ratingView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.ratingView];
    
    self.userAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.04, APPLICATION_FRAME.size.height * 0.85, APPLICATION_FRAME.size.width * 0.15, APPLICATION_FRAME.size.width * 0.15)];
    self.userAvatar.layer.cornerRadius = self.userAvatar.frame.size.height/2;
    self.userAvatar.backgroundColor = [UIColor clearColor];
    self.userAvatar.contentMode = UIViewContentModeScaleAspectFit;
    self.userAvatar.clipsToBounds = YES;
    [self addSubview:self.userAvatar];
    
    self.username = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.userAvatar.frame) + APPLICATION_FRAME.size.width * 0.03, CGRectGetMidY(self.userAvatar.frame) - APPLICATION_FRAME.size.height* 0.02, APPLICATION_FRAME.size.width * 0.5, APPLICATION_FRAME.size.height * 0.04)];
    self.username.font = [UIFont nun_semiboldFontWithSize:APPLICATION_FRAME.size.height * 0.03];
    self.username.backgroundColor = [UIColor clearColor];
    self.username.textColor = [UIColor whiteColor];
    [self addSubview:self.username];
    
//    self.dismissGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissMetrics)];
//    self.dismissGesture.numberOfTapsRequired = 1;
//    self.dismissGesture.cancelsTouchesInView = NO;
//    [self addGestureRecognizer:self.dismissGesture];
}

- (void)loadReview:(UserReview *)review{
    self.review = review;
    
    //Don't show gradient if there are no metrics
    if (review.price || review.overall || review.healthiness) {
        [self.ratingView showGradient:YES];
    }else{
        [self.ratingView showGradient:NO];
    }
    [self.ratingView setPrice:self.review.price];
    [self.ratingView setHealth:self.review.healthiness];
    [self.ratingView setOverall:self.review.overall];
    [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:self.review.avatarURL] placeholderImage:[UIImage new] options:SDWebImageHighPriority|SDWebImageRetryFailed];
    [self.username setText:self.review.username];
}

- (void)dismissMetrics{
    if (_metricsShowing) {
        self.metricsShowing = NO;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect ratingFrame = self.ratingView.frame;
            CGRect avatarFrame = self.userAvatar.frame;
            CGRect usernameFrame = self.username.frame;
            
            ratingFrame.origin.y -= self.ratingView.frame.size.height;
            avatarFrame.origin.y = APPLICATION_FRAME.size.height;
            usernameFrame.origin.y = APPLICATION_FRAME.size.height;
            
            self.ratingView.frame = ratingFrame;
            self.userAvatar.frame = avatarFrame;
            self.username.frame = usernameFrame;
        }];
    }else{
        self.metricsShowing = YES;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect ratingFrame = self.ratingView.frame;
            CGRect avatarFrame = self.userAvatar.frame;
            CGRect usernameFrame = self.username.frame;
            
            ratingFrame.origin.y += self.ratingView.frame.size.height;
            avatarFrame.origin.y = APPLICATION_FRAME.size.height * 0.85;
            usernameFrame.origin.y = CGRectGetMidY(avatarFrame) - APPLICATION_FRAME.size.height* 0.02;
            
            self.ratingView.frame = ratingFrame;
            self.userAvatar.frame = avatarFrame;
            self.username.frame = usernameFrame;
        }];
    }
}

- (CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(APPLICATION_FRAME.size.width, APPLICATION_FRAME.size.height);
}

@end
