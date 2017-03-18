//
//  Chart.h
//  Foodhead
//
//  Created by Brian Wong on 3/17/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Chart : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *chart_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *order_index;

//Merged properties from Places object
@property (nonatomic, copy) NSArray *places;
@property (nonatomic, copy) NSNumber *next_page;

@end
