//
//  UIFont+Extension.h
//  Joyspace
//
//  Created by Amir Hizkiya on 4/22/16.
//  Copyright © 2016 Joyspace Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Extension)

//Monsterrat
+(UIFont*)lightFontWithSize:(CGFloat)fontSize;
+(UIFont*)fontWithSize:(CGFloat)fontSize;
+(UIFont*)mediumFontWithSize:(CGFloat)fontSize;
+(UIFont*)semiboldFontWithSize:(CGFloat)fontSize;
+(UIFont*)boldFontWithSize:(CGFloat)fontSize;

//Nunito
+(UIFont*)nun_lightFontWithSize:(CGFloat)fontSize;
+(UIFont*)nun_fontWithSize:(CGFloat)fontSize;
+(UIFont*)nun_mediumFontWithSize:(CGFloat)fontSize;
+(UIFont*)nun_semiboldFontWithSize:(CGFloat)fontSize;
+(UIFont*)nun_boldFontWithSize:(CGFloat)fontSize;

@end
