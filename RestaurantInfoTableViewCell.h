//
//  RestaurantInfoTableViewCell.h
//  FoodWise
//
//  Created by Brian Wong on 2/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RestaurantInfoCellDelegate <NSObject>

- (void)didTapShareButton;

@end

@interface RestaurantInfoTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UITextView *restaurantLink;

@end
