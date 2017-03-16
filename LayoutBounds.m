//
//  LayoutBounds.m
//  Joyspace
//
//  Created by Amir Hizkiya on 4/23/15.
//  Copyright (c) 2015 Taplet. All rights reserved.
//

#import "LayoutBounds.h"
#import "FoodWiseDefines.h"

@implementation LayoutBounds

#define COLOR_ARRAY @[@"0x19cadb",@"0x0ed770",@"0xffcb0a",@"0xff4444",@"0xe92fe5",\
@"0xee3092",@"0x4a28e5",@"0x40b0ff",@"0xa1df62",@"0x2a73e2",\
@"0x04dfbd",@"0xff6f31",@"0xe63367",@"0x9c2cc7",@"0x6a338c",\
@"0x44c52b",@"0xea2c9a",@"0x00d4ff",@"0xff9d1e",@"0xe65533",]


+(void)drawBoundsForAllLayers:(UIView*)view
{
    #ifdef DEBUG
    NSString* colorString = [COLOR_ARRAY objectAtIndex:arc4random()%COLOR_ARRAY.count];
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:colorString];
    [scanner scanHexInt:&result];

    view.layer.borderWidth = 1;
    view.layer.borderColor = UIColorFromRGB(result).CGColor;
    for (UIView* subView in view.subviews) {
        [LayoutBounds drawBoundsForAllLayers:subView];
    }
    #endif
}


@end
