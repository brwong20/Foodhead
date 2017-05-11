//
//  UIImage+Utilities.h
//  Foodhead
//
//  Created by Brian Wong on 5/8/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utilities)

//Corner radius is an expensive UIKit property that runs on the main trhead so we will use this round corners on a background thread instead (with Texture)
+ (UIImage *)drawRoundedCornersForImage:(UIImage *)image withCornerRadius:(CGFloat)rad;

@end
