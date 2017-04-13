//
//  SearchTableViewCell.h
//  Foodhead
//
//  Created by Brian Wong on 4/7/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLRestaurant.h"
#import "Category.h"

@interface SearchTableViewCell : UITableViewCell

- (void)populateRestaurant:(TPLRestaurant *)restaurant;
- (void)populateCategory:(Category *)category;


@end
