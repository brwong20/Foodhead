//
//  TPLChartCollectionCell.m
//  FoodWise
//
//  Created by Brian Wong on 2/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartCollectionCell.h"


@implementation TPLChartCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCell:frame];
    }
    return self;
}

- (void)setupCell:(CGRect)frame{
    self.backgroundColor = [UIColor clearColor];
    
    self.coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.45, frame.size.height * 0.05, frame.size.width * 0.9, frame.size.width * 0.9)];
    self.coverImage.backgroundColor = [UIColor clearColor];
    self.coverImage.clipsToBounds = YES;
    self.coverImage.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.coverImage.layer.shouldRasterize = YES;
    self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImage.layer.cornerRadius = 3.0;
    [self addSubview:self.coverImage];
    
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.coverImage.frame), CGRectGetMaxY(self.coverImage.frame), frame.size.width * 0.7, frame.size.height * 0.1)];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.font = [UIFont systemFontOfSize:15.0];
    self.nameLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.nameLabel];
    
    self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.coverImage.frame), CGRectGetMaxY(self.nameLabel.frame), frame.size.width * 0.5, frame.size.height * 0.1)];
    self.categoryLabel.backgroundColor = [UIColor clearColor];
    self.categoryLabel.text = @"Category";
    self.categoryLabel.font = [UIFont systemFontOfSize:13.0];
    self.categoryLabel.textColor = [UIColor grayColor];
    [self addSubview:self.categoryLabel];
}

- (void)prepareForReuse{
    self.coverImage.image = nil;
}


@end
