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

@property (nonatomic, strong) UIView *seeAllView;
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
    if (self.seeAllView.superview) {
        [self.seeAllView removeFromSuperview];
    }
    [super prepareForReuse];
}

- (void)showSeeAllButton{
    self.seeAllView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 25.0, self.frame.size.width - 1.0, 25.0)];
    [self.seeAllView setBackgroundColor:[[UIColor clearColor]colorWithAlphaComponent:0.45]];//Setting background color this way doesn't affect subviews
    [self.contentView addSubview:self.seeAllView];
    
    self.allLabel = [[UILabel alloc]initWithFrame:CGRectMake(5.0, 0, self.seeAllView.frame.size.width * 0.4, self.seeAllView.frame.size.height)];
    self.allLabel.text = @"See all";
    self.allLabel.textColor = [UIColor whiteColor];
    self.allLabel.backgroundColor = [UIColor clearColor];
    self.allLabel.font = [UIFont nun_fontWithSize:REST_PAGE_DETAIL_FONT_SIZE];
    [self.seeAllView addSubview:self.allLabel];
    
    self.arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.seeAllView.frame.size.width - self.seeAllView.frame.size.width * 0.16, self.seeAllView.frame.size.height/2 - self.seeAllView.frame.size.height * 0.2, self.seeAllView.frame.size.width * 0.12, self.seeAllView.frame.size.height * 0.4)];
    self.arrowImg.backgroundColor = [UIColor clearColor];
    self.arrowImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.arrowImg setImage:[UIImage imageNamed:@"arrow_right_white"]];
    [self.seeAllView addSubview:self.arrowImg];
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedSeeAll)];
    tapGest.numberOfTapsRequired = 1;
    [self.seeAllView addGestureRecognizer:tapGest];
}

- (void)tappedSeeAll{
    if ([self.delegate respondsToSelector:@selector(didTapSeeAllButton)]) {
        [self.delegate didTapSeeAllButton];
    }
}


@end
