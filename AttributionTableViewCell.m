//
//  AttributionTableViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 4/4/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "AttributionTableViewCell.h"
#import "FoodWiseDefines.h"
#import "LayoutBounds.h"

@interface AttributionTableViewCell ()

@property (nonatomic, strong) UIImageView *foursquareLogo;

@end

@implementation AttributionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = APPLICATION_BACKGROUND_COLOR;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *sepLine = [[UIView alloc]initWithFrame:SEP_LINE_RECT];
        sepLine.center = CGPointMake(sepLine.center.x, 2.0);
        sepLine.backgroundColor = UIColorFromRGB(0x47606A);
        sepLine.alpha = 0.15;
        [self.contentView addSubview:sepLine];
        
        self.foursquareLogo = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(SEP_LINE_RECT) + 1.5, (ATTRIBUTION_CELL_HEIGHT/2 - ATTRIBUTION_CELL_HEIGHT * 0.17) + 2.0, APPLICATION_FRAME.size.width * 0.5, ATTRIBUTION_CELL_HEIGHT * 0.34)];
        self.foursquareLogo.backgroundColor = [UIColor clearColor];
        self.foursquareLogo.contentMode = UIViewContentModeScaleAspectFit;
        [self.foursquareLogo setImage:[UIImage imageNamed:@"foursquare_logo"]];
        [self.contentView addSubview:self.foursquareLogo];        
    }
    return self;
}

@end
