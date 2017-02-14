//
//  TasteFilterView.m
//  FoodWise
//
//  Created by Brian Wong on 2/7/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TasteFilterView.h"

@implementation TasteFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.filterTitle = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2 - 150.0, 100.0, 300.0, 50.0)];
        self.filterTitle.backgroundColor = [UIColor clearColor];
        self.filterTitle.textColor = [UIColor whiteColor];
        self.filterTitle.font = [UIFont boldSystemFontOfSize:40.0];
        self.filterTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.filterTitle];
        
        self.filterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height)];
        self.filterImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.filterImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.filterImageView];
    }
    
    return self;
}

@end
