//
//  ResultTableViewCell.h
//  Foodhead
//
//  Created by Brian Wong on 4/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLRestaurant.h"

@interface ResultTableViewCell : UITableViewCell

- (void)populateRestaurant:(TPLRestaurant *)restaurant;

@end
