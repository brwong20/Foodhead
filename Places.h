//
//  Places.h
//  Foodhead
//
//  Created by Brian Wong on 3/17/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Places : MTLModel<MTLJSONSerializing>

//General model class to hold our place results from either foursquare or instagram
@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic, copy) NSNumber *next_page; //For pagination to retrieve more places

//For blog posts
@property (nonatomic, copy) NSNumber *total_pages;
@property (nonatomic, copy) NSNumber *current_page;

@end
