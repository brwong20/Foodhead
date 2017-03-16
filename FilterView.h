//
//  FilterView.h
//  FoodWise
//
//  Created by Brian Wong on 2/7/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>


#warning Should eventually give us back a dynamically updated Review object with all sub filters reviews so we don't have to delegate to scroll view

typedef enum{
    FilterViewTypeTaste,
    FilterViewTypePrice,
    FilterViewTypeHealth,
} FilterViewType;

@interface FilterView : UIView

@property (nonatomic, strong) UILabel *filterTitle;
@property (nonatomic, strong) UIImageView *filterImageView;

+ (id)createFilterWithFrame:(CGRect)frame ofType:(FilterViewType)filterType;

@end
