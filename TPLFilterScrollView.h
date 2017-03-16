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

- (void)didUpdateOverall:(NSNumber *)overall;

//Price filter
- (void)didUpdatePrice:(NSNumber *)price;
- (void)pricePadWillShow:(NSNotification *)notif;
- (void)pricePadWillHide:(NSNotification *)notif;

- (void)didUpdateHealthiness:(NSNumber *)healthiness;

@end

@import CoreLocation;

@interface TPLFilterScrollView : UIScrollView

@property (nonatomic, weak) id<FilterScrollDelegate> scrollDelegate;

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;
- (void)loadFilters;

@end
