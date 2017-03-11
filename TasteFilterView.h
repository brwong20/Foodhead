//
//  TasteFilterView.h
//  FoodWise
//
//  Created by Brian Wong on 2/7/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "FilterView.h"

@protocol TasteFilterDelegate <NSObject>

@required
- (void)didRateOverall:(NSNumber *)overall;

@end

@interface TasteFilterView : FilterView

@property (nonatomic, weak) id<TasteFilterDelegate> delegate;

@end
