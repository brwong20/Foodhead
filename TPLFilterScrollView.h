//
//  TPLFilterScrollView.h
//  FoodWise
//
//  Created by Brian Wong on 2/5/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RestaurantReview.h"

@protocol FilterScrollDelegate <NSObject>

//Scroll View
- (void)filterViewDidScroll:(UIScrollView *)scrollView;

//Overall filter
- (void)didUpdateOverall:(NSNumber *)overall;

//Price filter
- (void)didUpdatePrice:(NSNumber *)price;
- (void)pricePadWillShow:(NSNotification *)notif;
- (void)pricePadWillHide:(NSNotification *)notif;

//Health filter
- (void)didUpdateHealthiness:(NSNumber *)healthiness;

@end

@import CoreLocation;

@interface TPLFilterScrollView : UIScrollView

@property (nonatomic, weak) id<FilterScrollDelegate> scrollDelegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)loadFilters;

//Helps us dismiss the price keypad directly. One case where we need this is when user clicks next (can't save price this way) and we need to update the price
- (void)dismissPriceKeypad;

@end
