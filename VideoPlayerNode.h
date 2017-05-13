//
//  VideoPlayerNode.h
//  Foodhead
//
//  Created by Brian Wong on 4/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "TPLRestaurant.h"

@interface VideoPlayerNode : ASCellNode

- (instancetype)initWithRestaurant:(TPLRestaurant *)restaurant;

@property (nonatomic, strong) ASVideoNode *playerNode;
@property (nonatomic, strong) TPLRestaurant *restaurantInfo;

@end
