//
//  RatingContainerView.h
//  Foodhead
//
//  Created by Brian Wong on 3/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingContainerView : UIView

- (void)setHealth:(NSNumber *)healthiness;
- (void)setPrice:(NSNumber *)price;
- (void)setOverall:(NSNumber *)overall;

@end
