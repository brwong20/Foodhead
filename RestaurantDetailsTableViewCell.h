//
//  RestaurantDetailsTableViewCell.h
//  Foodhead
//
//  Created by Brian Wong on 3/14/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLRestaurant.h"

@interface RestaurantDetailsTableViewCell : UITableViewCell

//If details not fetched, just set title. This is done solely for UI purposes since we already retrieve half this info when searching.
- (void)setInfoForRestaurant:(TPLRestaurant *)restaurant detailsFetched:(BOOL)fetched;

@end
