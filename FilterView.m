//
//  FilterView.m
//  FoodWise
//
//  Created by Brian Wong on 2/7/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "FilterView.h"
#import "TasteFilterView.h"
#import "PriceFilterView.h"
#import "HealthFilterView.h"

@implementation FilterView

+ (id)createFilterWithFrame:(CGRect)frame ofType:(FilterViewType)filterType
{
    switch (filterType) {
        case FilterViewTypePrice:
            return [[PriceFilterView alloc]initWithFrame:frame];
            break;
        case FilterViewTypeTaste:
            return [[TasteFilterView alloc] initWithFrame:frame];
            break;
        case FilterViewTypeHealth:
            return [[HealthFilterView alloc]initWithFrame:frame];
            break;
        default:
            break;
    }
    
    return nil;
}

@end
