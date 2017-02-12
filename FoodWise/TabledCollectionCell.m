//
//  PhotoCollectionCell.m
//  TrueBite
//
//  Created by Brian Wong on 9/6/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "TabledCollectionCell.h"
#import "ImageCollectionCell.h"


@implementation IndexedPhotoCollectionView


@end

@implementation TabledCollectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 3.0;
    CGRect screenSize = [[UIScreen mainScreen]bounds];
    flowLayout.itemSize = CGSizeMake(160.0, 160.0);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[IndexedPhotoCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:CollectionCellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    //self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 3.0, 0.0, 3.0);
    //[self.collectionView setPagingEnabled:YES];
    [self.contentView addSubview:self.collectionView];
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
}

//We pass in an instance (self) of our overarching view controller in order to conform to its delegate & datasource INSTEAD of the table view's
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;
    [self.collectionView setContentOffset:self.collectionView.contentOffset animated:NO];
    [self.collectionView reloadData];
}

@end
