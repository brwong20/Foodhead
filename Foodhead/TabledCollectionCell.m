//
//  PhotoCollectionCell.m
//  TrueBite
//
//  Created by Brian Wong on 9/6/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "TabledCollectionCell.h"
#import "ImageCollectionCell.h"
#import "TPLChartCollectionCell.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

#import <QuartzCore/QuartzCore.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@implementation IndexedPhotoCollectionView

@end

@interface TabledCollectionCell ()

@property (nonatomic, strong) TTTAttributedLabel *chartTitle;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *seeAllView;
@property (nonatomic, strong) UILabel *seeAllLabel;
@property (nonatomic, strong) UIImageView *seeAllImg;
@property (nonatomic, strong) UITapGestureRecognizer *seeAllGesture;

@end

#define NUM_COLUMNS 2

@implementation TabledCollectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;

    self.backgroundColor = [UIColor clearColor];
    
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width/2 - APPLICATION_FRAME.size.width * 0.48, CHART_ROW_HEIGHT * 0.02, APPLICATION_FRAME.size.width * 0.96, CHART_ROW_HEIGHT * 0.97)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 8.0;
    self.containerView.layer.shadowOffset = CGSizeMake(-2.0, 4.0);
    self.containerView.layer.shadowOpacity = 0.35;
    self.containerView.layer.shadowRadius = 4.0;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.containerView.layer.shouldRasterize = YES;
    [self.contentView addSubview:self.containerView];
    
    self.chartTitle = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(self.containerView.bounds.size.width/2 - self.containerView.bounds.size.width * 0.45, self.containerView.bounds.size.height * 0.005, self.containerView.bounds.size.width * 0.9, self.containerView.bounds.size.height * 0.07)];
    self.chartTitle.backgroundColor = [UIColor clearColor];
    self.chartTitle.font = [UIFont nun_semiboldFontWithSize:APPLICATION_FRAME.size.width * 0.053];
    self.chartTitle.textColor = [UIColor blackColor];
    self.chartTitle.numberOfLines = 1;
    self.chartTitle.kern = 1.5;//Character spacing
    self.chartTitle.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:self.chartTitle];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc]init];
    self.flowLayout.minimumInteritemSpacing = APPLICATION_FRAME.size.width * CHART_SPACING;
    self.flowLayout.minimumLineSpacing = (APPLICATION_FRAME.size.width * CHART_SPACING)/2;
    self.flowLayout.itemSize = CGSizeMake(CHART_ITEM_SIZE * 0.8 - (self.flowLayout.minimumInteritemSpacing * 0.5), CHART_ITEM_SIZE - (self.flowLayout.minimumLineSpacing * 0.5));
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[IndexedPhotoCollectionView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.chartTitle.frame), CGRectGetMaxY(self.chartTitle.frame), self.chartTitle.frame.size.width, CHART_ITEM_SIZE * 2) collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    self.collectionView.scrollEnabled = NO;
    [self.collectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:CollectionCellIdentifier];//Default cell class
    [self.containerView addSubview:self.collectionView];
    
    self.seeAllView = [[UIButton alloc]initWithFrame:CGRectMake(self.containerView.frame.size.width * 0.77, CGRectGetMaxY(self.collectionView.frame) + self.containerView.bounds.size.height * 0.005, self.containerView.frame.size.width * 0.22, (self.containerView.bounds.size.height - CGRectGetMaxY(self.collectionView.frame)) * 0.86)];
    self.seeAllView.backgroundColor = [UIColor clearColor];
    
    self.seeAllLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, self.seeAllView.bounds.size.width * 0.6, self.seeAllView.bounds.size.height)];
    self.seeAllLabel.text = @"more";
    self.seeAllLabel.textAlignment = NSTextAlignmentRight;
    self.seeAllLabel.backgroundColor = [UIColor clearColor];
    self.seeAllLabel.font = [UIFont nun_lightFontWithSize:REST_PAGE_HEADER_FONT_SIZE * 1.1];
    self.seeAllLabel.textColor = UIColorFromRGB(0x4D4F51);
    [self.seeAllView addSubview:self.seeAllLabel];
    
    self.seeAllImg = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.seeAllLabel.frame) + self.seeAllView.bounds.size.width * 0.02, 0.0, self.seeAllView.bounds.size.width * 0.38, self.seeAllView.bounds.size.height)];
    self.seeAllImg.backgroundColor = [UIColor clearColor];
    self.seeAllImg.image = [UIImage imageNamed:@"see_all"];
    self.seeAllImg.contentMode = UIViewContentModeLeft;
    [self.seeAllView addSubview:self.seeAllImg];
    
    self.seeAllGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapSeeAll)];
    self.seeAllGesture.numberOfTapsRequired = 1;
    [self.seeAllView addGestureRecognizer:self.seeAllGesture];

    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    
    self.chartTitle.text = @"";
    [self.seeAllView removeFromSuperview];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //Replaces sizeForItemAtIndexPath
    self.collectionView.frame = CGRectMake(CGRectGetMinX(self.chartTitle.frame), CGRectGetMaxY(self.chartTitle.frame), self.chartTitle.frame.size.width, CHART_ITEM_SIZE * 2);
}

//We pass in an instance (self) of our overarching view controller in order to conform to its delegate & datasource INSTEAD of the table view's
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath withCustomCell:(nullable Class)class{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;
    if (class) [self.collectionView registerClass:class forCellWithReuseIdentifier:CollectionCellIdentifier];
    [self.collectionView setContentOffset:self.collectionView.contentOffset animated:NO];
    [self.collectionView reloadData];
}

#pragma mark - Helper Methods

- (void)populateCellWithChart:(Chart *)chart{
    self.chart = chart;
    self.chartTitle.text = chart.name;

    //Don't let go into expanded view if chart hasn't loaded yet or not enough results
    if (self.chart.places.count > 4) {
        [self.containerView addSubview:self.seeAllView];
    }
}

- (void)didTapSeeAll{
    if ([self.delegate respondsToSelector:@selector(didTapSeeAllAtIndexPath:)]) {
        [self.delegate didTapSeeAllAtIndexPath:self.collectionView.indexPath];
    }
}

@end
