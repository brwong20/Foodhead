//
//  UIFont+Extension.m
//  Joyspace
//
//  Created by Amir Hizkiya on 4/22/16.
//  Copyright © 2016 Joyspace Inc. All rights reserved.
//

#import "UIFont+Extension.h"

@implementation UIFont (Extension)

#define FONT_NAME @"Montserrat"

+(UIFont*)lightFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:[FONT_NAME stringByAppendingString:@"-Light"] size:fontSize];
}

+(UIFont*)fontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:[FONT_NAME stringByAppendingString:@"-Regular"] size:fontSize];
}

+(UIFont*)mediumFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:[FONT_NAME stringByAppendingString:@"-Medium"] size:fontSize];
}

+(UIFont*)semiboldFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:[FONT_NAME stringByAppendingString:@"-Semibold"] size:fontSize];
}

//+(UIFont*)italicFontWithSize:(CGFloat)fontSize
//{
//    return [UIFont fontWithName:[ALT_FONT_NAME stringByAppendingString:@"-Italic"] size:fontSize];
//}
//
//+(UIFont*)semiboldItalicFontWithSize:(CGFloat)fontSize
//{
//    return [UIFont fontWithName:[ALT_FONT_NAME stringByAppendingString:@"-SemiboldItalic"] size:fontSize];
//}

+(UIFont*)boldFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:[FONT_NAME stringByAppendingString:@"-Bold"] size:fontSize];
}

@end
