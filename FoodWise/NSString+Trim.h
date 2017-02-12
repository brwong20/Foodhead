//
//  NSString+Trim.h
//  FoodWise
//
//  Created by Brian Wong on 2/2/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Trim)

+ (NSString *)stringByTrimmingSpecialCharacters:(NSString *)string;

@end
