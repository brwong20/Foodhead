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

@property (nonatomic, strong) UIImageView *coverImage;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *priceLabel;

- (void)populateRestauarantInfo:(TPLRestaurant *)restaurant;

@end
