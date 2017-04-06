//
//  ReviewMetricView.h
//  Foodhead
//
//  Created by Brian Wong on 3/20/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

#import "UserReview.h"
#import "RatingContainerView.h"

@interface ReviewMetricView : IDMCaptionView

- (void)loadReview:(UserReview *)review;

@end
