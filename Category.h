//
//  Category.h
//  Foodhead
//
//  Created by Brian Wong on 4/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Category : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *categoryId;
@property (nonatomic, copy) NSString *categoryFullName;
@property (nonatomic, copy) NSString *categoryShortName;
@property (nonatomic, copy) NSString *categoryFoursqId;

@end
