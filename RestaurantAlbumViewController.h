//
//  RestaurantAlbumViewController.h
//  FoodWise
//
//  Created by Brian Wong on 2/17/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLRestaurant.h"

@interface RestaurantAlbumViewController : UIViewController

@property (nonatomic, strong) TPLRestaurant *restaurant;
@property (nonatomic, strong) NSString *nextPg;
@property (nonatomic, strong) NSMutableArray *media;

@end
