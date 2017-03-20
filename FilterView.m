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
    FilterView *filter;
    switch (filterType) {
        case FilterViewTypePrice:{
            PriceFilterView *priceFilter = [[PriceFilterView alloc]initWithFrame:frame];
            filter = (PriceFilterView *)priceFilter;
            filter.filterType = filterType;
            break;
        }
        case FilterViewTypeTaste:{
            TasteFilterView *tasteFilter = [[TasteFilterView alloc] initWithFrame:frame];
            filter = (TasteFilterView *)tasteFilter;
            filter.filterType = filterType;
            break;
        }
        case FilterViewTypeHealth:{
            HealthFilterView *healthFilter = [[HealthFilterView alloc]initWithFrame:frame];
            filter = (HealthFilterView *)healthFilter;
            filter.filterType = filterType;
            break;
        }
        case FilterViewBlank:{
            filter = [[FilterView alloc]initWithFrame:frame];
            filter.filterType = filterType;
            break;
        }
        default:
            break;
    }
    return filter;
}

@end
