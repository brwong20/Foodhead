//
//  NSString+Trim.m
//  FoodWise
//
//  Created by Brian Wong on 2/2/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "NSString+Trim.h"

@implementation NSString (Trim)

+ (NSString *)stringByTrimmingSpecialCharacters:(NSString *)string{
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *strippedReplacement = [[string componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    return strippedReplacement;
}

@end
