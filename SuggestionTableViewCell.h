//
//  SuggestionTableViewCell.h
//  Foodhead
//
//  Created by Brian Wong on 3/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPLRestaurant.h"

@interface SuggestionTableViewCell : UITableViewCell

- (void)populateRestaurantInfo:(TPLRestaurant *)restaurant;

@end
