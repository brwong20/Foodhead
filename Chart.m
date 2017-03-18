//
//  Chart.m
//  Foodhead
//
//  Created by Brian Wong on 3/17/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "Chart.h"

@implementation Chart

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"chart_id" : @"id",
             @"name" : @"title",
             @"order_index" : @"order_index"};
             
}

- (void)mergeValuesForKeysFromModel:(id<MTLModel>)model{
    [super mergeValuesForKeysFromModel:model];
}

@end
