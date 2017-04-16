//
//  CategoryCollectionViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 4/8/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "CategoryCollectionViewCell.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

@interface CategoryCollectionViewCell ()

@end

@implementation CategoryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        self.layer.borderWidth = 1.0;
//        self.layer.borderColor = [UIColor grayColor].CGColor;
        
        self.categoryImgView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.2, frame.size.height/2.5 - frame.size.width * 0.2, frame.size.width * 0.4, frame.size.width * 0.4)];
        self.categoryImgView.contentMode = UIViewContentModeScaleAspectFit;
        self.categoryImgView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.categoryImgView];
        
        self.categoryName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.categoryImgView.frame) - frame.size.width * 0.43, CGRectGetMaxY(self.categoryImgView.frame) + frame.size.height * 0.05, frame.size.width * 0.86, frame.size.height * 0.15)];
        self.categoryName.backgroundColor = [UIColor clearColor];
        self.categoryName.textAlignment = NSTextAlignmentCenter;
        self.categoryName.textColor = UIColorFromRGB(0x4D4E51);
        self.categoryName.font = [UIFont nun_fontWithSize:16.0];
        [self.contentView addSubview:self.categoryName];        
    }
    return self;
}

@end
