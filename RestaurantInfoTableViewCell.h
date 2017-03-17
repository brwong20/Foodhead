//
//  RestaurantInfoTableViewCell.h
//  FoodWise
//
//  Created by Brian Wong on 2/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLRestaurant.h"

@protocol RestaurantInfoCellDelegate <NSObject>

- (void)didTapShareButton;
- (void)didTapLocation;

@end

@interface RestaurantInfoTableViewCell : UITableViewCell

@property (nonatomic, weak) id<RestaurantInfoCellDelegate> delegate;

- (void)populateInfo:(TPLRestaurant *)restaurant;

@end
