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
#import "FoodheadAnalytics.h"
#import "ServiceErrorView.h"
#import "UIFont+Extension.h"

#import "UIImageView+AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface TabledCollectionManager () <ChartSectionViewDelegate, ServiceErrorViewDelegate>

//Reference to parent table view that uses this delegate/datasource
@property (nonatomic, strong) UITableView *tableView;

//Datasource
@property (nonatomic, strong) NSMutableArray *collectionData;
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

//Helper properties
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

//View Model
@property (nonatomic, strong) TPLChartsViewModel *viewModel;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

//Error View
@property (nonatomic, strong) ServiceErrorView *errorView;

@end

@implementation TabledCollectionManager

- (instancetype)initWithTableView:(UITableView *)tableview cellIdentifier:(NSString *)cellId
{
    self = [super init];
    if (self){
        self.cellIdentifier = cellId;
        self.tableView = tableview;
        [tableview registerClass:[TabledCollectionCell class] forCellReuseIdentifier:cellId];
        [self setupRefreshControl];
        self.contentOffsetDictionary = [NSMutableDictionary dictionary];
        self.viewModel = [[TPLChartsViewModel alloc]initWithStore:[[TPLChartsDataSource alloc]init]];
        [self showChartLoader];
        [self bindViewModel];
    }
    return self;
}

- (void)setupRefreshControl{
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    [self.refreshControl addTarget:self action:@selector(refreshCharts) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
}

//Should only show on app launch (when screen is blank)
- (void)showChartLoader{
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = self.tableView.window.center;
    CGAffineTransform scaleUp = CGAffineTransformMakeScale(1.4, 1.4);
    self.indicatorView.transform = scaleUp;
    [self.tableView.window addSubview:self.indicatorView]; //Show above everything
    [self.indicatorView startAnimating];
}

- (void)hideChartLoader{
    if ([self.indicatorView isAnimating]) {
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
    }
}

#pragma mark - Refresh

- (void)refreshCharts{
    if (self.viewModel.finishedLoading) {
        [self.refreshControl beginRefreshing];
        [[LocationManager sharedLocationInstance] retrieveCurrentLocation];
    }else{
        [self.refreshControl endRefreshing];
    }
}


#pragma mark - UICollectionViewDataSource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TPLChartCollectionCell *collectionCell = (TPLChartCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellIdentifier forIndexPath:indexPath];
    TPLRestaurant *restaurant = [self getRestaurantAtIndexPath:indexPath inCollectionView:collectionView];
    [collectionCell populateRestauarantInfo:restaurant];
    return collectionCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger itemCount = 0;
    if(self.collectionData.count > 0){
        NSIndexPath *tableCellIndex = [self indexPathForCollectionView:collectionView];
        Chart *chart = self.collectionData[tableCellIndex.section];
        if (chart.places) {
            //Only show 'all' button for section if we have a chart
            //TPLChartSectionView *sectionView = [self.tableView viewWithTag:[chart.name hash]];
            //[sectionView showSeeAllButton];
            itemCount = chart.places.count;
        }
    }
    return itemCount;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *tableCellIndex = [self indexPathForCollectionView:collectionView];
    Chart *chart = self.collectionData[tableCellIndex.section];
    if (indexPath.row == chart.places.count - 1) {
        [FoodheadAnalytics logEvent:END_OF_CHART withParameters:@{@"chartName" : chart.name}];
    }
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
    UIView *sectionView = nil;
    if(self.collectionData.count > 0){
        Chart *chart = [self.collectionData objectAtIndex:section];
        
        TPLChartSectionView *chartSection = [[TPLChartSectionView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, CHART_SECTION_HEIGHT)];
        //sectionView.tag = [chart.name hash];//Makes it easier to retrieve this view in other methods
        chartSection.delegate = self;
        chartSection.section = section;
        chartSection.titleLabel.text = chart.name;
        
        sectionView = chartSection;
    }
    return sectionView;
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isKindOfClass:[UITableView class]]){
        if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height)) {
            [FoodheadAnalytics logEvent:END_OF_CHART_PAGE];
        }
    }
}

#pragma mark - ChartsSectionView delegate methods

- (void)didSelectSection:(NSUInteger)section{
    Chart *chart = [self.collectionData objectAtIndex:section];
    if (chart) {
        if ([self.delegate respondsToSelector:@selector(tableView:didSelectSectionWithChart:)]) {
            [self.delegate tableView:self.tableView didSelectSectionWithChart:chart];
        }
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
    //Should ONLY show the very first time user enters the app and there's a blank screen. The rest of the loading will be handled by pull to refresh for now.
    if (!self.refreshControl.refreshing && ![self.errorView superview]) {
        [self showChartLoader];
    }
    [self.viewModel getChartsAtLocation:coordinate];
}

//Reloading the tableView will reload each of its embedded collection views as well
- (void)collectionViewReloadData{
    [self.tableView reloadData];
}

- (void)bindViewModel{
    [self bindChartData];
    [self bindRefreshControl];
    [self bindChartSpinner];
}

- (void)bindChartData{
    @weakify(self);
    [[RACObserve(self.viewModel, completeChartData) deliverOnMainThread]
     subscribeNext:^(id _) {
         @strongify(self){
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self hideChartLoader];
                 self.collectionData = self.viewModel.completeChartData;
                 [self collectionViewReloadData];
             });
         }
     }];
}

- (void)bindRefreshControl{
    @weakify(self);
    [[RACObserve(self.viewModel, finishedLoading) deliverOnMainThread]
     subscribeNext:^(id  _Nullable x) {
         @strongify(self){
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (self.refreshControl.isRefreshing) {
                     [self.refreshControl endRefreshing];
                 }
             });
         }
     }];
}

- (void)bindChartSpinner{
    @weakify(self);
    [[RACObserve(self.viewModel, chartsLoadFailed) deliverOnMainThread]
     subscribeNext:^(id  _Nullable x) {
         @strongify(self){
             if(self.viewModel.chartsLoadFailed){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (![self.errorView superview]) {
                         [self hideChartLoader];//Should never show chart loader along with error view
                         self.errorView = [[ServiceErrorView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width , self.tableView.frame.size.height) andErrorType:ServiceErrorTypeData];
                         self.errorView.delegate = self;
                         [self.tableView.superview addSubview:self.errorView];
                     }else{
                         //Couldn't refresh after retry
                         [self.errorView stopRefreshing];
                     }
                 });
             }else{
                 if ([self.errorView superview]) {
                     [self.errorView removeFromSuperview];
                 }
             }
         }
     }];
}

#pragma mark - ServiceErrorViewDelegate methods

//Will call ChartsViewController's delegate method which then re-routes back here.
- (void)serviceErrorViewToggledRefresh{
    [self getChartsAtLocation:[[LocationManager sharedLocationInstance]currentLocation]];
}

@end
