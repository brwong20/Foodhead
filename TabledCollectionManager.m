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
#import "FoodWiseDefines.h"
#import "LocationManager.h"
#import "LayoutBounds.h"
#import "FoodheadAnalytics.h"
#import "ServiceErrorView.h"
#import "UIFont+Extension.h"

#import "UIImageView+AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface TabledCollectionManager () <ServiceErrorViewDelegate, TabledCollectionCellDelegate>

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

//Location
@property (nonatomic, strong) LocationManager *locationManager;

@end

#define NUM_THUMBNAILS 4

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
        self.viewModel = [[TPLChartsViewModel alloc]init];
        [self bindViewModel];
        [self showChartLoader];
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
    if (![self.indicatorView superview]) {
        self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.center = CGPointMake(APPLICATION_FRAME.size.width/2, APPLICATION_FRAME.size.height/2.4);
        CGAffineTransform scaleUp = CGAffineTransformMakeScale(1.3, 1.3);
        self.indicatorView.transform = scaleUp;
        [self.tableView addSubview:self.indicatorView];//Show above everything
        [self.indicatorView startAnimating];
    }
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
        
        //Fires delegate method in ChartsViewController and comes back to here 
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
        IndexedPhotoCollectionView *indexedCollection = (IndexedPhotoCollectionView *)collectionView;
        Chart *chart = self.collectionData[indexedCollection.indexPath.row];
        
        //Only load as many restaurant thumbnails as needed
        if (chart.places && chart.places.count > NUM_THUMBNAILS) {
            itemCount = NUM_THUMBNAILS;
        }else{
            itemCount = chart.places.count;
        }
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
    rowCell.delegate = self;
    Chart *chart = [self.collectionData objectAtIndex:indexPath.row];
    [rowCell populateCellWithChart:chart];
    
    return rowCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark - UITableViewDelegate methods

//Keeps track of each offset for each distinct row of embedded collection views
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    TabledCollectionCell *photoCell = (TabledCollectionCell*)cell;
    [photoCell setCollectionViewDataSourceDelegate:self indexPath:indexPath withCustomCell:[TPLChartCollectionCell class]];
    
//    NSIndexPath *index = [self indexPathForCollectionView:photoCell.collectionView];
//    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index.section) stringValue]]floatValue];
//    [photoCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CHART_ROW_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.collectionData.count;
}

#pragma mark - TabledCollectionCellDelegate methods

- (void)didTapSeeAllAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectChart:AtIndexPath:)]) {
        [self.delegate tableView:self.tableView didSelectChart:self.collectionData[indexPath.row] AtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate methods
//Track the offset of each collection view and store in a map to return to originally scrolled position if loaded again.
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if ([scrollView isKindOfClass:[UICollectionView class]]){
//        CGFloat horizontalOffset = scrollView.contentOffset.x;
//        IndexedPhotoCollectionView *collectionView = (IndexedPhotoCollectionView *)scrollView;
//        NSIndexPath *indexPath = [self indexPathForCollectionView:collectionView];
//        self.contentOffsetDictionary[[@(indexPath.section) stringValue]] = @(horizontalOffset);
//    }
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isKindOfClass:[UITableView class]]){
        if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height)) {
            [FoodheadAnalytics logEvent:END_OF_CHART_PAGE];
        }
    }
}

#pragma mark - Helper Methods

//Method helps us figure out which row (tableview cell) we're populating the embedded collection view cells for.
- (TPLRestaurant *)getRestaurantAtIndexPath:(NSIndexPath *)indexPath
                           inCollectionView:(UICollectionView*)collectionView{
    IndexedPhotoCollectionView *indexedCollection = (IndexedPhotoCollectionView *)collectionView;
    Chart *chart = self.collectionData[indexedCollection.indexPath.row];
    NSArray *restaurantArr = chart.places;
    NSDictionary *restaurantDict = restaurantArr[indexPath.row];//Using embedded collection cell index path
    TPLRestaurant *restaurant = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:restaurantDict error:nil];
    return restaurant;
}

- (void)getChartsAtLocation:(CLLocationCoordinate2D)coordinate{
    //Should ONLY show the very first time user enters the app and there's a blank screen. The rest of the loading will be handled by pull to refresh for now.
//    if (!self.refreshControl.refreshing && ![self.errorView superview]) {
//        [self showChartLoader];
//    }
    [self.viewModel getChartsAtLocation:coordinate];
}

//Reloading the tableView will reload each of its embedded collection views as well
- (void)collectionViewReloadData{
    [self.tableView reloadData];
}

#pragma mark - View Model Helper Methods

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
    [[LocationManager sharedLocationInstance]retrieveCurrentLocation];
}

@end
