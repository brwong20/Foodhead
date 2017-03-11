//
//  UIFont+Extension.h
//  Joyspace
//
//  Created by Amir Hizkiya on 4/22/16.
//  Copyright © 2016 Joyspace Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Extension)

+(UIFont*)lightFontWithSize:(CGFloat)fontSize;
+(UIFont*)fontWithSize:(CGFloat)fontSize;
+(UIFont*)mediumFontWithSize:(CGFloat)fontSize;
+(UIFont*)semiboldFontWithSize:(CGFloat)fontSize;
//+(UIFont*)italicFontWithSize:(CGFloat)fontSize;
//+(UIFont*)semiboldItalicFontWithSize:(CGFloat)fontSize;
+(UIFont*)boldFontWithSize:(CGFloat)fontSize;
@end
