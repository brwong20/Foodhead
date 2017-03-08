//
//  BRWSearchView.h
//  FoodWise
//
//  Created by Brian Wong on 2/15/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRWSearchViewDelegate <NSObject>

- (void)didSelectResult:(id)result;

@end

@interface BRWSearchView : UIView

@property (nonatomic) CGFloat resultCellHeight;

@property (nonatomic, weak) id<BRWSearchViewDelegate> delegate;

//How can i generalize this? Just tell users to pass in/update their datasource in from their view controller?

@end
