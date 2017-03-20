//
//  FilterView.h
//  FoodWise
//
//  Created by Brian Wong on 2/7/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    FilterViewBlank,
    FilterViewTypeTaste,
    FilterViewTypePrice,
    FilterViewTypeHealth,
} FilterViewType;

@interface FilterView : UIView

@property (nonatomic, assign) FilterViewType filterType;

+ (id)createFilterWithFrame:(CGRect)frame ofType:(FilterViewType)filterType;

@end
