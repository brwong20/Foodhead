//
//  PhotoCollectionCell.h
//  TrueBite
//
//  Created by Brian Wong on 9/6/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IndexedPhotoCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

//Static bc these ids should be the same everywhere when using this class.
static NSString *CollectionCellIdentifier = @"photoCollectionCell";
static NSString *AddPhotoCellIdentifier = @"addPhotoCell";

@interface TabledCollectionCell : UITableViewCell

@property (nonatomic, strong) IndexedPhotoCollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

//Defaults to ImageCollectionCell is not custom cell is passed
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath withCustomCell:(nullable Class)class;

@end
