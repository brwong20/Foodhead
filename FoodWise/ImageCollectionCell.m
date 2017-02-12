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
        
        //self.layer.cornerRadius = frame.size.height * 0.07;
        
        self.coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.475, frame.size.height/2 - frame.size.height * 0.475, frame.size.width * 0.95, frame.size.height * 0.95)];
        self.coverImageView.backgroundColor = [UIColor clearColor];
        //self.imageView.layer.cornerRadius = frame.size.height * 0.07;
        self.coverImageView.clipsToBounds = YES;
        self.coverImageView.layer.rasterizationScale = [[UIScreen mainScreen]scale];
        self.coverImageView.layer.shouldRasterize = YES;
        self.coverImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.coverImageView];
        
        self.venueNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.475, frame.size.height * 0.9 - frame.size.height * 0.1, frame.size.width * 0.95, frame.size.height * 0.2)];
        self.venueNameLabel.backgroundColor = [UIColor clearColor];
        self.venueNameLabel.textAlignment = NSTextAlignmentCenter;
        self.venueNameLabel.textColor = [UIColor blueColor];
        self.venueNameLabel.font = [UIFont boldSystemFontOfSize:14.0];
        //[self.venueNameLabel sizeToFit];
        [self addSubview:self.venueNameLabel];
    }
    
    return self;
}

- (void)prepareForReuse{
    self.coverImageView.image = nil;
}

@end
