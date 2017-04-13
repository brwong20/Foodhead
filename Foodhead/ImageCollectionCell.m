//
//  ImageCollectionCell.m
//  TrueBite
//
//  Created by Brian Wong on 9/6/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "ImageCollectionCell.h"
#import "UIFont+Extension.h"
#import "FoodWiseDefines.h"

@interface ImageCollectionCell ()

@property (nonatomic, strong) UIView *allButton;
@property (nonatomic, strong) UILabel *allLabel;
@property (nonatomic, strong) UIImageView *arrowImg;

@end

@implementation ImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.coverImageView.backgroundColor = [UIColor whiteColor];
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        [self.contentView addSubview:self.coverImageView];
    }
    return self;
}

- (void)prepareForReuse{
    self.coverImageView.image = nil;
    if (self.allButton.superview) {
        [self.allButton removeFromSuperview];
    }
    [super prepareForReuse];
}

- (void)showSeeAllButton{
    self.allButton = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 25.0, self.frame.size.width - 1.0, 25.0)];
    [self.allButton setBackgroundColor:[[UIColor clearColor]colorWithAlphaComponent:0.45]];//Setting background color this way doesn't affect subviews
    [self.contentView addSubview:self.allButton];
    
    self.allLabel = [[UILabel alloc]initWithFrame:CGRectMake(5.0, 0, self.allButton.frame.size.width * 0.4, self.allButton.frame.size.height)];
    self.allLabel.text = @"See all";
    self.allLabel.textColor = [UIColor whiteColor];
    self.allLabel.backgroundColor = [UIColor clearColor];
    self.allLabel.font = [UIFont nun_fontWithSize:REST_PAGE_DETAIL_FONT_SIZE];
    [self.allButton addSubview:self.allLabel];
    
    self.arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.allButton.frame.size.width - self.allButton.frame.size.width * 0.16, self.allButton.frame.size.height/2 - self.allButton.frame.size.height * 0.2, self.allButton.frame.size.width * 0.12, self.allButton.frame.size.height * 0.4)];
    self.arrowImg.backgroundColor = [UIColor clearColor];
    self.arrowImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.arrowImg setImage:[UIImage imageNamed:@"arrow_right_white"]];
    [self.allButton addSubview:self.arrowImg];
}

- (void)tappedSeeAll{
    if ([self.delegate respondsToSelector:@selector(didTapSeeAllButton)]) {
        [self.delegate didTapSeeAllButton];
    }
}


@end
