//
//  ExpandedChartCollectionViewCell.h
//  Foodhead
//
//  Created by Brian Wong on 4/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPLRestaurant.h"

@interface ExpandedChartCollectionViewCell : UICollectionViewCell

- (void)populateRestaurantInfo:(TPLRestaurant *)restaurant;

@end
