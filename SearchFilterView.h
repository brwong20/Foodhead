//
//  SearchFilterView.h
//  Foodhead
//
//  Created by Brian Wong on 4/10/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchFilterViewDelegate <NSObject>

- (void)didSelectFilters:(NSDictionary *)filters;

@end

@interface SearchFilterView : UIView

@property (nonatomic, weak) id<SearchFilterViewDelegate> delegate;

- (void)clearAllFilters;

@end
