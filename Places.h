//
//  Places.h
//  Foodhead
//
//  Created by Brian Wong on 3/17/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Places : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *places;
@property (nonatomic, copy) NSNumber *next_page; //For pagination to retrieve more places

@end
