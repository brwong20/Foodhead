//
//  FilterView.h
//  FoodWise
//
//  Created by Brian Wong on 2/7/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    FilterViewTypeTaste,
    FilterViewTypePrice,
    FilterViewTypeHealth,
} FilterViewType;

@interface FilterView : UIView

@property (nonatomic, strong)UILabel *filterTitle;

+ (id)createFilterWithFrame:(CGRect)frame ofType:(FilterViewType)filterType;

@end
