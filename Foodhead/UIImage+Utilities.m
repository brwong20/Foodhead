//
//  UIImage+Utilities.m
//  Foodhead
//
//  Created by Brian Wong on 5/8/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UIImage+Utilities.h"

@implementation UIImage (Utilities)

+ (UIImage *)drawRoundedCornersForImage:(UIImage *)image withCornerRadius:(CGFloat)rad{
    if (!image) {
        return image;
    }
    
    UIImage *modifiedImg;
    
    CGRect rect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(image.size, false, [UIScreen mainScreen].scale);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(rad, rad)];
    maskPath.lineWidth = 2.0;
    [UIColor.lightGrayColor setStroke];
    [maskPath addClip];
    [maskPath stroke];
    [image drawInRect:rect];
    modifiedImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return modifiedImg;
}

@end
