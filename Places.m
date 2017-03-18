//
//  Places.m
//  Foodhead
//
//  Created by Brian Wong on 3/17/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "Places.h"

//When this is merged with Charts object, a "completed" Chart is created (Title + restaurants)
@implementation Places

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
   return@{@"places" : @"result",
           @"next_page" : @"next_page"};
}

@end
