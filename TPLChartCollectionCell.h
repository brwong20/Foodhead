//
//  TPLChartCollectionCell.h
//  FoodWise
//
//  Created by Brian Wong on 2/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPLRestaurant.h"

@interface TPLChartCollectionCell : UICollectionViewCell

- (void)populateRestauarantInfo:(TPLRestaurant *)restaurant;

@end
