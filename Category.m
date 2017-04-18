//
//  Category.m
//  Foodhead
//
//  Created by Brian Wong on 4/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "Category.h"

@implementation Category

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"categoryId" : @"id",
             @"categoryFullName" : @"name",
             @"categoryShortName" : @"name_short",
             @"categoryFoursqId" : @"four_square_id"};
}

@end
