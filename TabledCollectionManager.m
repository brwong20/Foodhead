//
//  ChartsTableDataSource.m
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TabledCollectionManager.h"
#import "TabledCollectionCell.h"
#import "TPLChartCollectionCell.h"
#import "TPLRestaurant.h"
#import "TPLChartsViewModel.h"
#import "TPLChartSectionView.h"
#import "FoodWiseDefines.h"
#import "LocationManager.h"
#import "LayoutBounds.h"

#import "UIImageView+AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface TabledCollectionManager () <ChartSectionViewDelegate>

//Reference to parent table view that uses this delegate/datasource
@property (nonatomic, strong) UITableView *tableView;

//Datasource
@property (nonatomic, strong) NSMutableArray *collectionData;
@property (nonatomic, strong) NSString *cellIdentifier;

//Helper properties
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

//View Model
@property (nonatomic, strong) TPLChartsViewModel *viewModel;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TabledCollectionManager

- (instancetype)initWithTableView:(UITableView *)tableview cellIdentifier:(NSString *)cellId
{
    self = [super init];
    if (self){
        self.cellIdentifier = cellId;
        self.tableView = tableview;
        [tableview registerClass:[TabledCollectionCell class] forCellReuseIdentifier:cellId];
        //[self setupRefreshControl];
        self.contentOffsetDictionary = [NSMutableDictionary dictionary];
        self.viewModel = [[TPLChartsViewModel alloc]initWithStore:[[TPLChartsDataSource alloc]init]];
        [self bindViewModel];
        
        //[LayoutBounds drawBoundsForAllLayers:self.tableView];
    }
    return self;
}

//- (void)setupRefreshControl{
//    self.refreshControl = [[UIRefreshControl alloc]init];
//    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
//    self.refreshControl.tintColor = [UIColor redColor];
//    [self.refreshControl addTarget:self action:@selector(refreshCharts:) forControlEvents:UIControlEventValueChanged];
//    self.tableView.refreshControl = self.refreshControl;
//}

#pragma mark - Refresh

//- (void)refreshCharts:(id)sender{
//    [self.refreshControl beginRefreshing];
//
//    //Charts headers always the same right now. Only need to refresh restaurants!
//    for (NSMutableDictionary *chartDict in self.collectionData) {
//        //Replace all removed objects with index.
//        NSString *chartKey = [[chartDict allKeys]firstObject];
//        [chartDict removeObjectForKey:chartKey];
//        [chartDict setObject:@([self.collectionData indexOfObject:chartDict]) forKey:chartKey];
//
//    }
//
//    [[LocationManager sharedLocationInstance]updateCurrentLocation];
//}


#pragma mark - UICollectionViewDataSource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TPLChartCollectionCell *collectionCell = (TPLChartCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellIdentifier forIndexPath:indexPath];
    //Get section instead and check if a dict exists
    TPLRestaurant *restaurant = [self getRestaurantAtIndexPath:indexPath inCollectionView:collectionView];
    [collectionCell populateRestauarantInfo:restaurant];
    return collectionCell;
}

//Keeps track of each offset for each distinct row of embedded collection views
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    TabledCollectionCell *photoCell = (TabledCollectionCell*)cell;
    photoCell.collectionView.backgroundColor = [UIColor clearColor];
    photoCell.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;//Slows down the scroll speed
    [photoCell setCollectionViewDataSourceDelegate:self indexPath:indexPath withCustomCell:[TPLChartCollectionCell class]];
    
    NSIndexPath *index = [self indexPathForCollectionView:photoCell.collectionView];
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index.section) stringValue]]floatValue];
    [photoCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger itemCount = 0;
    NSIndexPath *tableCellIndex = [self indexPathForCollectionView:collectionView];
    Chart *chart = self.collectionData[tableCellIndex.section];
    if (chart.places) {
        itemCount = chart.places.count;
    }
    return itemCount;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.collectionData.count;
}

#pragma mark - UITableViewDelegate methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    Chart *chart = [self.collectionData objectAtIndex:section];

    TPLChartSectionView *sectionView = [[TPLChartSectionView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, CHART_SECTION_HEIGHT)];
    sectionView.delegate = self;
    sectionView.section = section;
    sectionView.titleLabel.text = chart.name;
    
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CHART_ROW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CHART_SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
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

#pragma mark - ChartsSectionView delegate methods

- (void)didSelectSection:(NSUInteger)section{
    Chart *chart = [self.collectionData objectAtIndex:section];
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectSectionWithChart:)]) {
        [self.delegate tableView:self.tableView didSelectSectionWithChart:chart];
    }
}

#pragma mark - Helper Methods

//Method helps us figure out which row (tableview cell) we're populating the embedded collection view cells for.
- (TPLRestaurant *)getRestaurantAtIndexPath:(NSIndexPath *)indexPath
                           inCollectionView:(UICollectionView*)collectionView{
    NSIndexPath *tableCellIndex = [self indexPathForCollectionView:collectionView];
    Chart *chart = self.collectionData[tableCellIndex.section];
    NSArray *restaurantArr = chart.places;
    NSDictionary *restaurantDict = restaurantArr[indexPath.row];//Using embedded collection cell index path
    TPLRestaurant *restaurant = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:restaurantDict error:nil];
    return restaurant;
}

- (NSIndexPath *)indexPathForCollectionView:(UICollectionView *)collectionView{
    UIView *cellContentView = collectionView.superview;
    TabledCollectionCell *tableCell = (TabledCollectionCell*)cellContentView.superview;
    NSIndexPath *tableCellIndex = [self.tableView indexPathForRowAtPoint:tableCell.center];//Used row b/c cellForRowAtIndexPath returns nil if cell isn't visible yet!
    return tableCellIndex;
}

- (void)getChartsAtLocation:(CLLocationCoordinate2D)coordinate{
    [self.viewModel getChartsAtLocation:coordinate];
}

//Reloading the tableView will reload each of its embedded collection views as well
- (void)collectionViewReloadData{
    [self.tableView reloadData];
}

- (void)bindViewModel{
    @weakify(self);
    [[RACObserve(self.viewModel, completeChartData) deliverOnMainThread]
     subscribeNext:^(id _) {
         @strongify(self){
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ([self.refreshControl isRefreshing]) {
                     [self.refreshControl endRefreshing];
                 }
                 self.collectionData = self.viewModel.completeChartData;
                 [self collectionViewReloadData];
             });
         }
     }];
}

@end
