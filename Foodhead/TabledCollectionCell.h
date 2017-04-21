//
//  PhotoCollectionCell.h
//  TrueBite
//
//  Created by Brian Wong on 9/6/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"
#import "TPLRestaurant.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TabledCollectionCellDelegate <NSObject>

- (void)didTapSeeAllAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface IndexedPhotoCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

//Static bc these ids should be the same everywhere when using this class.
static NSString *CollectionCellIdentifier = @"photoCollectionCell";
//static NSString *AddPhotoCellIdentifier = @"addPhotoCell";

@interface TabledCollectionCell : UITableViewCell

@property (nonatomic, strong) Chart *chart;

@property (nonatomic, strong) IndexedPhotoCollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) id <TabledCollectionCellDelegate> delegate;


//Defaults to ImageCollectionCell is not custom cell is passed
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath withCustomCell:(nullable Class)class;

- (void)populateCellWithChart:(Chart *)chart;

@end

NS_ASSUME_NONNULL_END

