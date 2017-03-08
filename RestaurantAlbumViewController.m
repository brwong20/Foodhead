//
//  RestaurantAlbumViewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/17/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RestaurantAlbumViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ImageCollectionCell.h"

@interface RestaurantAlbumViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, strong) CHTCollectionViewWaterfallLayout *waterfallLayout;

@end

static NSString *cellId = @"albumCell";

@implementation RestaurantAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Ho ass bish";
    
    [self setupWaterfallAlbum];
}

- (void)setupWaterfallAlbum{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.waterfallLayout = [[CHTCollectionViewWaterfallLayout alloc]init];
    self.waterfallLayout.columnCount = 3;
    self.waterfallLayout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
    
    self.photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:self.waterfallLayout];
    self.photoCollectionView.backgroundColor = [UIColor whiteColor];
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    [self.photoCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.photoCollectionView];
}

#pragma mark - UICollectionViewDatasource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.layer.cornerRadius = 4.0;
    cell.layer.borderWidth = 2.0;
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 100;
}

#pragma mark - UICollectionViewDelegate methods

#pragma mark - CHTCollectionViewDelegateWaterfallLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row % 3 == 0) {
        return CGSizeMake(50.0, 130);
    }else if (indexPath.row % 2 == 0){
        return CGSizeMake(50.0, 60.0);
    }else{
        return CGSizeMake(50, 50);
    }
}

@end
