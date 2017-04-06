//
//  RestaurantReview.h
//  Foodhead
//
//  Created by Brian Wong on 3/9/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@import CoreLocation;

//Convenience class to manage data in review flow
@interface RestaurantReview : NSObject

@property (nonatomic, strong) NSString *restaurant_id;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *overall;
@property (nonatomic, strong) NSNumber *healthiness;
@property (nonatomic, assign) CLLocationCoordinate2D reviewLocation;

@end
