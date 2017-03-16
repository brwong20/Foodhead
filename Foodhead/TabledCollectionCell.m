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


@implementation IndexedPhotoCollectionView


@end

@implementation TabledCollectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;

    self.flowLayout = [[UICollectionViewFlowLayout alloc]init];
    self.flowLayout.minimumInteritemSpacing = self.contentView.bounds.size.width * CHART_PADDING_PERCENTAGE;
    self.flowLayout.itemSize = CGSizeMake(CHART_ITEM_SIZE * 0.9, CHART_ITEM_SIZE);
    
#warning Figure out why this doesn't align with section padding
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0.0, self.contentView.bounds.size.width * 0.055, 0.0, 1.5);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[IndexedPhotoCollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CHART_ITEM_SIZE) collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    [self.collectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:CollectionCellIdentifier];//Default cell class
    [self.contentView addSubview:self.collectionView];
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;//Replaces sizeForItemAtIndexPath
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

@end
