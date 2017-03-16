//
//  ImageCollectionCell.m
//  TrueBite
//
//  Created by Brian Wong on 9/6/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "ImageCollectionCell.h"

@implementation ImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.coverImageView.backgroundColor = [UIColor clearColor];
        self.coverImageView.clipsToBounds = YES;
        self.coverImageView.layer.rasterizationScale = [[UIScreen mainScreen]scale];
        self.coverImageView.layer.shouldRasterize = YES;
        self.coverImageView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:self.coverImageView];
    }
    
    return self;
}

- (void)prepareForReuse{
    self.coverImageView.image = nil;
}

@end
