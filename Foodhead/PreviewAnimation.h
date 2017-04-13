//
//  PreviewAnimation.h
//  Joyspace
//
//  Created by Amir Hizkiya on 6/5/15.
//  Copyright (c) 2015 Taplet Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreviewAnimation : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initWithSmallImageView:(UIImageView*)smallImageView ToBigImageView:(UIImageView*)bigImageView;

@end
