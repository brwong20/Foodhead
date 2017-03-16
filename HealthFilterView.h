//
//  HealthFilterView.h
//  Foodhead
//
//  Created by Brian Wong on 3/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "FilterView.h"

@protocol HealthFilterDelegate <NSObject>

@required
- (void)didRateHealth:(NSNumber *)healthiness;

@end

@interface HealthFilterView : FilterView

@property (nonatomic, weak) id<HealthFilterDelegate> delegate;

@end
