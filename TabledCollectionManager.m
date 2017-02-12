//
//  ChartsTableDataSource.m
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TabledCollectionManager.h"
#import "TabledCollectionCell.h"
#import "ImageCollectionCell.h"
#import "TPLRestaurant.h"
#import "TPLChartsViewModel.h"

#import "UIImageView+AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface TabledCollectionManager ()

//Reference to parent table view that uses this delegate/datasource
@property (nonatomic, strong) UITableView *tableView;

//Datasource
@property (nonatomic, strong) NSMutableArray *collectionData;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, assign) NSInteger currentSection;

//Helper properties
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

//View Model
@property (nonatomic, strong) TPLChartsViewModel *viewModel;

@end

@implementation TabledCollectionManager

- (instancetype)initWithTableView:(UITableView *)tableview cellIdentifier:(NSString *)cellId
{
    self = [super init];
    if (self){
        self.cellIdentifier = cellId;
        self.tableView = tableview;
        self.contentOffsetDictionary = [NSMutableDictionary dictionary];
        [tableview registerClass:[TabledCollectionCell class] forCellReuseIdentifier:cellId];
        self.viewModel = [[TPLChartsViewModel alloc]initWithStore:[[TPLChartsDataSource alloc]init]];
        [self bindViewModel];
    }
    return self;
}


#pragma mark - UICollectionViewDataSource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //Make sure to register the cell type you want to use in the TabledCollectionCell subclass!
    ImageCollectionCell *collectionCell = (ImageCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellIdentifier forIndexPath:indexPath];

    //Get section instead and check if a dict exists
    if (self.collectionData.count > 0) {
        TPLRestaurant *restaurant = [self getRestaurantAtIndexPath:indexPath inCollectionView:collectionView];
        collectionCell.venueNameLabel.text = restaurant.name;
        
        if(restaurant.foursq_featured_photos.count > 0){
            NSDictionary *photoInfo = restaurant.foursq_featured_photos.firstObject;//Each restaurant object only has one featured photo so this works
            [collectionCell.coverImageView sd_setImageWithURL:[self photoURLFromDictionary:photoInfo]];
        }else{
            //Placeholder or something else (fb cover photo?)
        }
    }
    return collectionCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    TabledCollectionCell *photoCell = (TabledCollectionCell*)cell;
    [photoCell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    
    NSIndexPath *index = [self indexPathForCollectionView:photoCell.collectionView];
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index.section) stringValue]]floatValue];
    [photoCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //Pass data (whatevers in cell) along with this as well
    TPLRestaurant *restaurant = [self getRestaurantAtIndexPath:indexPath inCollectionView:collectionView];
    if([self.delegate respondsToSelector:@selector(collectionView:didSelectTabledCollectionCellAtIndexPath:withItem:)]) {
        [self.delegate collectionView:collectionView didSelectTabledCollectionCellAtIndexPath:indexPath withItem:restaurant];
    }
}


#pragma mark - UITableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TabledCollectionCell *rowCell = (TabledCollectionCell *)[tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    rowCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return rowCell;
}

//Since we've embedded a collection view in our table view cell, we need to implement these
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //Same objects in different sections - either dictionary key problem or firstObject....
    NSInteger itemCount = 0;
    if(self.collectionData.count > 0){
        //Each key will only have one value which is an array of restaurants
        NSDictionary *categoryDict = [self.collectionData objectAtIndex:section];
        NSArray *restaurants = [[categoryDict allValues]firstObject];
        itemCount = restaurants.count;
    }
    return itemCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.collectionData.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *categoryDict = [self.collectionData objectAtIndex:section];
    NSString *categoryName = [[categoryDict allKeys]firstObject];
    return categoryName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 191.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

#pragma mark - UIScrollViewDelegate methods

//Track the offset of each collection view and store in a map to return to originally scrolled position if loaded again.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isKindOfClass:[UICollectionView class]]){
        CGFloat horizontalOffset = scrollView.contentOffset.x;
        IndexedPhotoCollectionView *collectionView = (IndexedPhotoCollectionView *)scrollView;
        NSIndexPath *indexPath = [self indexPathForCollectionView:collectionView];
        self.contentOffsetDictionary[[@(indexPath.section) stringValue]] = @(horizontalOffset);
    }
}


#pragma mark - Helper Methods

- (TPLRestaurant *)getRestaurantAtIndexPath:(NSIndexPath *)indexPath
                           inCollectionView:(UICollectionView*)collectionView {
    UIView *cellContentView = collectionView.superview;
    TabledCollectionCell *tableCell = (TabledCollectionCell*)cellContentView.superview;
    NSIndexPath *tableCellIndex = [self.tableView indexPathForRowAtPoint:tableCell.center];//Used row b/c cellForRowAtIndexPath returns nil if cell isn't visible yet!
    NSDictionary *categoryDict = self.collectionData[tableCellIndex.section];
    NSArray *values = [categoryDict allValues];
    NSArray *restaurantArr = [values firstObject];//Each key will only have one value which is an array of restaurants... FIND MORE CONCISE WAY TO DO THIS!!!
    return restaurantArr[indexPath.row];
}

- (NSIndexPath *)indexPathForCollectionView:(UICollectionView *)collectionView{
    UIView *cellContentView = collectionView.superview;
    TabledCollectionCell *tableCell = (TabledCollectionCell*)cellContentView.superview;
    NSIndexPath *tableCellIndex = [self.tableView indexPathForRowAtPoint:tableCell.center];//Used row b/c cellForRowAtIndexPath returns nil if cell isn't visible yet!
    return tableCellIndex;
}

- (void)getRestaurants{
    [self.viewModel getRestaurantsWithCoordinate:self.currentLocation];
}

- (void)bindViewModel{
    @weakify(self);
    [[[RACObserve(self.viewModel, restaurantData) deliverOnMainThread]
      filter:^BOOL(id  _Nullable value) {
        return (self.viewModel.restaurantData.count == 6);
    }]
     subscribeNext:^(id _) {
        @strongify(self){
            NSLog(@"CALLED");
            self.collectionData = self.viewModel.restaurantData;
            [self collectionViewReloadDataWith:nil];
        }
    }];

}

- (void)collectionViewReloadDataWith:(NSMutableArray *)data{
    [self.tableView reloadData];
}

- (NSURL*)photoURLFromDictionary:(NSDictionary *)photoDict{
    NSString *prefix = photoDict[@"prefix"];
    NSString *suffix = photoDict[@"suffix"];
    NSString *height = @"300";
    NSString *width = @"300";
    NSString *photoURL = [NSString stringWithFormat:@"%@%@x%@%@", prefix, height, width, suffix];
    return [NSURL URLWithString:photoURL];
}

@end
