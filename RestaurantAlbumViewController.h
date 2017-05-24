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

-(instancetype)initWithMedia:(NSMutableArray *)media nextPage:(NSString *)nextPg forRestuarant:(TPLRestaurant *)restaurant;

@end
