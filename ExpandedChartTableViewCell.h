//
//  ExpandedChartTableViewCell.h
//  FoodWise
//
//  Created by Brian Wong on 2/14/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandedChartTableViewCell : UITableViewCell

//Important: when loading or requesting charts info from server, make sure on top of caching image, we get actual image and save in TPLRestaurant so we don't have to load/request in this VC
@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) UIImage *restaurantThumb;
@property (nonatomic, strong) UILabel *restaurantName;

@end
