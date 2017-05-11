//
//  TPLExpandedChartController.m
//  FoodWise
//
//  Created by Brian Wong on 2/14/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLExpandedChartController.h"
#import "TPLRestaurant.h"
#import "FoodWiseDefines.h"
#import "TabledCollectionCell.h"
#import "ExpandedChartCollectionViewCell.h"
#import "FoodheadAnalytics.h"
#import "TPLChartsViewModel.h"
#import "LocationManager.h"
#import "UIFont+Extension.h"
#import "TPLRestaurantPageViewController.h"
#import "LayoutBounds.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface TPLExpandedChartController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LocationManagerDelegate, UIGestureRecognizerDelegate>

//UI
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGSize loadMoreCellSize;
@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UILabel *loadMoreLabel;
@property (nonatomic, strong) UITapGestureRecognizer *loadMoreGest;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreSpinner;

//Data
@property (nonatomic, strong) TPLChartsViewModel *viewModel;

//Location
@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@end

@implementation TPLExpandedChartController

static NSString *cellId = @"categoryRowCell";
static NSString *loadCellId = @"loadingCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[TPLChartsViewModel alloc]init];
    self.locationManager = [LocationManager sharedLocationInstance];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNavBar];
    self.locationManager.locationDelegate = self;
    [[LocationManager sharedLocationInstance]retrieveCurrentLocation];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.locationManager.locationDelegate = nil;
}

- (void)setupNavBar{
    self.navigationItem.title = self.selectedChart.name;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont nun_mediumFontWithSize:APPLICATION_FRAME.size.width * 0.06], NSForegroundColorAttributeName : [UIColor blackColor]};
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"arrow_back"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;//Preserves swipe back gesture
}

- (void)exit{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupUI{
    self.view.backgroundColor = UIColorFromRGB(0xDBDBDB);
    self.flowLayout = [[UICollectionViewFlowLayout alloc]init];
    self.flowLayout.minimumInteritemSpacing = APPLICATION_FRAME.size.width * CHART_SPACING;
    self.flowLayout.minimumLineSpacing = APPLICATION_FRAME.size.width * CHART_SPACING;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UIEdgeInsets adjustForBarInsets = UIEdgeInsetsMake(APPLICATION_FRAME.size.width * CHART_SPACING, (APPLICATION_FRAME.size.width * CHART_SPACING * 0.7), CGRectGetHeight(self.tabBarController.tabBar.frame) + (APPLICATION_FRAME.size.width * CHART_SPACING), (APPLICATION_FRAME.size.width * CHART_SPACING * 0.7));//Adjust for tab bar height covering views
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:self.flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = adjustForBarInsets;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[ExpandedChartCollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:loadCellId];
    [self.view addSubview:self.collectionView];
    
    self.loadMoreCellSize = CGSizeMake(APPLICATION_FRAME.size.width * 0.9, 60.0);

    self.loadMoreView = [[UIView alloc]initWithFrame:CGRectMake((self.loadMoreCellSize.width/2 - self.loadMoreCellSize.width * 0.45), self.loadMoreCellSize.height/2 - self.loadMoreCellSize.height * 0.35, self.loadMoreCellSize.width * 0.9, self.loadMoreCellSize.height * 0.7)];
    self.loadMoreView.backgroundColor = [UIColor whiteColor];
    self.loadMoreView.layer.cornerRadius = 8.0;
    self.loadMoreView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.loadMoreView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    self.loadMoreView.layer.shadowOpacity = 0.35;
    self.loadMoreView.layer.shadowRadius = 4.0;
    
    self.loadMoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.loadMoreView.bounds.size.width/2 - self.loadMoreView.bounds.size.width * 0.3, self.loadMoreView.bounds.size.height/2 - self.loadMoreView.bounds.size.height * 0.22, self.loadMoreView.bounds.size.width * 0.6, self.loadMoreView.bounds.size.height * 0.44)];
    self.loadMoreLabel.backgroundColor = [UIColor clearColor];
    self.loadMoreLabel.textAlignment = NSTextAlignmentCenter;
    self.loadMoreLabel.font = [UIFont nun_fontWithSize:REST_PAGE_HEADER_FONT_SIZE];
    self.loadMoreLabel.text = @"Tap for more";
    [self.loadMoreView addSubview:self.loadMoreLabel];
    
    self.loadMoreGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getMoreRestaurants)];
    self.loadMoreGest.numberOfTapsRequired = 1;
    [self.loadMoreView addGestureRecognizer:self.loadMoreGest];
    
    self.loadMoreSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadMoreSpinner.center = self.loadMoreLabel.center;
    [self.loadMoreView addSubview:self.loadMoreSpinner];
}

#pragma mark UICollectionViewDatasource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *collectionCell;
    if (indexPath.row == self.selectedChart.places.count && self.selectedChart.next_page) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:loadCellId forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        self.loadMoreLabel.hidden = NO;
        [cell.contentView addSubview:self.loadMoreView];
        collectionCell = cell;
        
        //Ignore collection view's flow layout, but remember to add offset b/c of padding
        cell.center = CGPointMake(self.collectionView.bounds.size.width/2 - (APPLICATION_FRAME.size.width * CHART_SPACING * 0.7), cell.center.y + ((APPLICATION_FRAME.size.width * CHART_SPACING)/2));
    }else{
        ExpandedChartCollectionViewCell *expandedCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        NSDictionary *restaurantInfo = self.selectedChart.places[indexPath.row];
        TPLRestaurant *restaurant = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:restaurantInfo error:nil];
        [expandedCell populateRestaurantInfo:restaurant];
        collectionCell = expandedCell;
    }
    return collectionCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger numCells;
    if (self.selectedChart.next_page) {
        numCells = self.selectedChart.places.count + 1;
    }else{
        numCells = self.selectedChart.places.count;
    }
    return numCells;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TPLRestaurantPageViewController *restPage = [[TPLRestaurantPageViewController alloc]init];
    NSDictionary *restaurantInfo = self.selectedChart.places[indexPath.row];
    TPLRestaurant *restaurant = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:restaurantInfo error:nil];
    restPage.selectedRestaurant = restaurant;
    //restPage.currentLocation = self.currentLocation;
    [self.navigationController pushViewController:restPage animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size;
    if (indexPath.row == self.selectedChart.places.count && self.selectedChart.next_page) {
        size = self.loadMoreCellSize;
    }else{
        size = CGSizeMake(CHART_ITEM_SIZE * 0.9 - (self.flowLayout.minimumInteritemSpacing * 0.5), CHART_ITEM_SIZE * 1.06 - (self.flowLayout.minimumLineSpacing * 0.5));
    }
    return size;
}

#pragma mark View Model Helper methods

//- (void)getMoreRestaurants{
//    if (!self.loadMoreSpinner.isAnimating && self.selectedChart.next_page) {
//        [self.loadMoreLabel setHidden:YES];
//        [self.loadMoreSpinner startAnimating];
//        
//        @weakify(self);
//        [[self.viewModel getMoreRestaurantsForChartSignal:self.selectedChart atLocation:self.currentLocation] subscribeError:^(NSError * _Nullable error) {
//            NSLog(@"Couldn't load more restaurants: %@", error);
//        } completed:^{
//            @strongify(self);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.loadMoreSpinner stopAnimating];
//                [self.collectionView reloadData];
//            });
//        }];
//    }
//}

#pragma mark - LocationManagerDelegate methods

- (void)didGetCurrentLocation:(CLLocationCoordinate2D)coordinate{
    self.currentLocation = coordinate;
}

@end
