//
//  ReviewTableViewCell.h
//  Foodhead
//
//  Created by Brian Wong on 3/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UserReview.h"

@interface ReviewTableViewCell : UITableViewCell

- (void)populateUserReview:(UserReview *)review;

@end
