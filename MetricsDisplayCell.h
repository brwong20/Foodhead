//
//  MetricsDisplayCell.h
//  FoodWise
//
//  Created by Brian Wong on 2/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPLRestaurant.h"

@interface MetricsDisplayCell : UITableViewCell

@property (nonatomic, strong) NSNumber *numReviews;
@property (nonatomic, strong) NSNumber *avgPrice;
@property (nonatomic, strong) NSString *healthLevel;
@property (nonatomic, strong) NSString *portionSize;

- (void)populateMetrics:(TPLRestaurant *)restaurant withUserReviews:(NSMutableArray *)reviews;

@end
