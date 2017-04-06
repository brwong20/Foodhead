//
//  BRWSearchView.h
//  FoodWise
//
//  Created by Brian Wong on 2/15/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLRestaurant.h"
#import "RestaurantReview.h"

@import CoreLocation;

@protocol BRWSearchViewDelegate <NSObject>

@required

- (void)didSelectResult:(TPLRestaurant *)result;

@end

@interface BRWSearchView : UIView

@property (nonatomic, assign) RestaurantReview *currentReview;

@property (nonatomic, weak) id<BRWSearchViewDelegate> delegate;

- (void)showKeyboard;
- (void)dismissKeyboard;

@end
