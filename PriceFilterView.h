//
//  PriceFilterView.h
//  Foodhead
//
//  Created by Brian Wong on 3/8/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "FilterView.h"

@protocol  PriceFilterDelegate <NSObject>

- (void)keypadWillShow:(NSNotification *)notif;
- (void)keypadWillHide:(NSNotification *)notif;
- (void)priceWasUpdated:(NSNumber *)price;


@end

@interface PriceFilterView : FilterView

@property (nonatomic, weak) id <PriceFilterDelegate> delegate;

- (void)showKeypad;
- (void)dismissKeypad;

//If we have a given price, use this to populate price digit labels. 
- (void)setPrice:(NSNumber *)price;

@end
