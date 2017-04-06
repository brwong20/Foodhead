//
//  AttributionCollectionViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 4/4/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "AttributionCollectionViewCell.h"
#import "FoodWiseDefines.h"

@interface AttributionCollectionViewCell ()

@property (nonatomic, strong) UIImageView *foursquareLogo;

@end

@implementation AttributionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.foursquareLogo = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(SEP_LINE_RECT), ATTRIBUTION_CELL_HEIGHT/2 - ATTRIBUTION_CELL_HEIGHT * 0.4, APPLICATION_FRAME.size.width * 0.7, ATTRIBUTION_CELL_HEIGHT * 0.8)];
        self.foursquareLogo.backgroundColor = [UIColor clearColor];
        self.foursquareLogo.contentMode = UIViewContentModeScaleAspectFit;
        [self.foursquareLogo setImage:[UIImage imageNamed:@"foursquare_logo"]];
        [self.contentView addSubview:self.foursquareLogo];
    }
    return self;
}

@end
