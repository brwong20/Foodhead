//
//  DiscoverViewController.m
//  Foodhead
//
//  Created by Brian Wong on 4/29/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "DiscoverViewController.h"
#import "FoodWiseDefines.h"
#import "TPLChartsViewModel.h"
#import "LocationManager.h"
#import "VideoPlayerNode.h"
#import "TPLRestaurantPageViewController.h"
#import "UserProfileViewController.h"
#import "SearchViewController.h"
#import "FoodheadAnalytics.h"
#import "DiscoverNode.h"
#import "AnimationPreviewViewController.h"
#import "AssetPreviewViewController.h"
#import "PreviewAnimation.h"

#import "Chart.h"
#import "Places.h"

#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>

@interface DiscoverViewController ()<UITabBarControllerDelegate,ASCollectionDelegate, ASCollectionDataSource, LocationManagerDelegate>

//UI
@property (nonatomic, assign) BOOL canScrollToTop;

@property (nonatomic, strong) CHTCollectionViewWaterfallLayout *waterfallLayout;
@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, strong) ASCollectionNode *collectionNode;

@property (nonatomic, strong) NSMutableDictionary *videoAssets;//Cache video assets to prevent reload each time in order to optimize scrolling

//Since our autoplaying logic is dependent on user scroll, we need a way to check if user hasn't scrolled yet to play any visible videos. This quick flag solves this for now
@property (nonatomic, assign) BOOL isInitialLoad;

//Datasource
@property (nonatomic, strong) NSMutableArray *collectionData;
@property (nonatomic, strong) NSMutableArray *blogData;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) NSInteger blogIndex;//Keeps track of which blog post we should use next

//View Model
@property (nonatomic, strong) TPLChartsViewModel *viewModel;

//Refresh Control
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

#define NUM_COLUMNS 2
#define DETAILS_HEIGHT 35
#define ASSET_KEY @"asset"
#define ASSET_LINK_KEY @"assetLink"

@implementation DiscoverViewController

- (instancetype)init{
    if (!(self = [super init])) { return nil; }
    
    self.waterfallLayout = [[CHTCollectionViewWaterfallLayout alloc]init];
    self.waterfallLayout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
    self.waterfallLayout.columnCount = NUM_COLUMNS;
    self.waterfallLayout.minimumColumnSpacing = 10.0;
    self.waterfallLayout.minimumInteritemSpacing = 5.0;
    self.waterfallLayout.sectionInset = UIEdgeInsetsMake(15.0, 10.0, 0.0, 10.0);
    
    _collectionNode = [[ASCollectionNode alloc] initWithCollectionViewLayout:self.waterfallLayout];
    _collectionNode.delegate = self;
    _collectionNode.dataSource = self;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Necessary to play background media along with videos
    //TODO: Mute or turn down background in browse
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    self.tabBarController.delegate = self;
    self.isInitialLoad = YES;
    
    self.viewModel = [[TPLChartsViewModel alloc]init];
    self.collectionData = [NSMutableArray array];
    self.videoAssets = [NSMutableDictionary dictionary];
    self.blogData = [NSMutableArray array];
    self.blogIndex = 0;
    
    self.locationManager = [LocationManager sharedLocationInstance];
    self.locationManager.locationDelegate = self;
    [self.locationManager retrieveCurrentLocation];
    
    _collectionNode.backgroundColor = [UIColor whiteColor];
    _collectionNode.view.frame = self.view.bounds;
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views
    self.collectionNode.view.contentInset = adjustForTabbarInsets;
    self.collectionNode.view.scrollIndicatorInsets = adjustForTabbarInsets;
    self.collectionNode.view.showsVerticalScrollIndicator = NO;
    [self.view addSubnode:_collectionNode];
    
    //Will make our status bar opaque
    UIView *statusBarBg = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    statusBarBg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:statusBarBg];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.locationManager.locationDelegate = self;
    [self.navigationController.navigationBar setHidden:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.canScrollToTop = YES;
    [[[self navigationController] interactivePopGestureRecognizer] setEnabled:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.canScrollToTop = NO;
    self.navigationController.navigationBar.hidden = NO;
    [[[self navigationController] interactivePopGestureRecognizer] setEnabled:YES];

}

#pragma mark - LocationManager delegate methods

//TODO: REFACTOR randomization logic into VM
//This method is binded to our view model through a signal that's fired each time a new chart is retrieved.
- (void)didGetCurrentLocation:(CLLocationCoordinate2D)coordinate{
    @weakify(self);

    __block NSMutableArray *tempArr = [NSMutableArray array];//Temp array used to string in blog content with chart data.
    __block int blogIndex = 0;
    
    //Get all blog posts first, then keep appending them to newly collected chart data
    [[[self.viewModel getRecentBlogPostsAtLocation:coordinate forPage:nil withLimit:@"50"]deliverOnMainThread]subscribeNext:^(Places *blogPosts) {
        @strongify(self);
        [self.blogData addObjectsFromArray:blogPosts.places];
    }error:^(NSError * _Nullable error) {
        DLog(@"Error retrieving blog posts: %@", error);
    }completed:^{
        [[[self.viewModel getChartsAtLocation:coordinate]deliverOnMainThread]subscribeNext:^(Places *restaurants) {
            @strongify(self);
            //Reset tempArr each time since we're adding in items as they come. If we reuse tempArr with our insertItemInCollection method, the data we've already added will be shown again for each new chart.
            [tempArr removeAllObjects];
            [tempArr addObjectsFromArray:restaurants.places];
        
            //For each new set of data that comes in, append the latest blog content in "random spots".
            for (int i = blogIndex; i < tempArr.count; ++i) {
                if (i % 3 == 0 && blogIndex < self.blogData.count) {//Insert blog post for every 4th cell
                    [tempArr insertObject:self.blogData[blogIndex] atIndex:i];
                    ++blogIndex;
                }
            }
            
            [self insertItemsInCollection:tempArr];
        }error:^(NSError * _Nullable error) {
            DLog(@"Error retrieving charts: %@", error);
        } completed:^{
            DLog(@"Successfully retrieved all charts!");
        }];
    }];
}

#pragma mark - ASCollectionDelegate methods
- (void)collectionNode:(ASCollectionNode *)collectionNode didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ASCellNode *node = [self.collectionNode nodeForItemAtIndexPath:indexPath];
    if ([node isKindOfClass:[DiscoverNode class]]) {
        DiscoverNode *restNode = (DiscoverNode *)node;
        TPLRestaurantPageViewController *restPageVC = [[TPLRestaurantPageViewController alloc]init];
        restPageVC.selectedRestaurant = restNode.restaurantInfo;
        [self.navigationController pushViewController:restPageVC animated:YES];
    }
    
}

#pragma mark - ASCollectionNodeDatasource methods

- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section{
    return self.collectionData.count;
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath{
    TPLRestaurant *restaurant = self.collectionData[indexPath.row];
    if (restaurant.hasVideo.boolValue) {
        return ^{
            VideoPlayerNode *vidNode = [[VideoPlayerNode alloc]initWithRestaurant:restaurant];
            return vidNode;
        };
    }else{
        return ^{
            DiscoverNode *imgNode = [[DiscoverNode alloc]initWithRestauarnt:restaurant];
            return imgNode;
        };
    }
}

- (void)collectionNode:(ASCollectionNode *)collectionNode willDisplayItemWithNode:(ASCellNode *)node{
    NSIndexPath *indexPath = [self.collectionNode indexPathForNode:node];
    TPLRestaurant *restaurant = self.collectionData[indexPath.row];
    if ([node isKindOfClass:[VideoPlayerNode class]] && restaurant.hasVideo.boolValue) {
        VideoPlayerNode *vidNode = (VideoPlayerNode *)node;
        //Foursquare id is used to retrieve asset link for faster lookup
        NSDictionary *assetDict = [self.videoAssets objectForKey:restaurant.foursqId];
        AVAsset *cachedAsset = [assetDict objectForKey:ASSET_KEY];
        if (cachedAsset) {
            //If we have already loaded an asset, use it.
            NSArray *keys = @[@"playable", @"tracks", @"duration"];
            [cachedAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                NSError *error;
                for (NSString *key in keys) {
                    AVKeyValueStatus keyStatus = [cachedAsset statusOfValueForKey:key error:&error];
                    if (keyStatus == AVKeyValueStatusFailed) {
                        DLog(@"Failed to load key : %@ with error: %@", key, error);
                    }
                }
                
                if (!error) {
                    //Only play when absolutely possible and necessary
                    dispatch_async(dispatch_get_main_queue(), ^{
                        vidNode.playerNode.asset = cachedAsset;
                        if (self.isInitialLoad) {
                            [self scrollViewDidEndScrollingAnimation:self.collectionNode.view];
                            self.isInitialLoad = NO;
                        }
                    });
                }
            }];
        }else{
            //Only set the asset for the video node until absolutley necessary, otherwise Texture will perform uneccssary AVPlayer work and slow down the UI.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSURL *vidURL = [NSURL URLWithString:assetDict[ASSET_LINK_KEY]];
                AVAsset *asset = [AVAsset assetWithURL:vidURL];
                NSArray *keys = @[@"playable", @"tracks", @"duration"];
                [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                    NSError *error;
                    for (NSString *key in keys) {
                        AVKeyValueStatus keyStatus = [cachedAsset statusOfValueForKey:key error:&error];
                        if (keyStatus == AVKeyValueStatusFailed) {
                            DLog(@"Failed to load key : %@ with error: %@", key, error);
                        }
                    }
                    
                    if (!error) {
                        //Only play when absolutely possible and necessary
                        dispatch_async(dispatch_get_main_queue(), ^{
                            vidNode.playerNode.asset = asset;
                            if (self.isInitialLoad) {
                                [self scrollViewDidEndScrollingAnimation:self.collectionNode.view];
                                self.isInitialLoad = NO;
                            }
                        });
                    }
                }];
            });
        }
        //vidNode.playerNode.URL = [NSURL URLWithString:restaurant.blogPhotoLink];
    }
}

- (ASSizeRange)collectionNode:(ASCollectionNode *)collectionNode constrainedSizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat availableWidth = CGRectGetWidth(self.collectionNode.bounds) - self.waterfallLayout.minimumColumnSpacing - (self.waterfallLayout.sectionInset.right + self.waterfallLayout.sectionInset.left);
    CGFloat widthPerItem = availableWidth/NUM_COLUMNS;
    
    TPLRestaurant *resturant = self.collectionData[indexPath.row];
    
    //Width is always constant, but height depends on size of asset.

    CGSize size = CGSizeMake(widthPerItem, 0);
    
    CGSize originalSize;
    if (resturant.blogName) {
        originalSize = CGSizeMake(resturant.blogPhotoWidth.floatValue, resturant.blogPhotoHeight.floatValue);
    }else if (resturant.hasVideo.boolValue){
        originalSize = CGSizeMake(resturant.blogVideoWidth.floatValue, resturant.blogVideoHeight.floatValue);
    }else if(resturant.thumbnail){
        originalSize = CGSizeMake(resturant.thumbnailWidth.floatValue, resturant.thumbnailHeight.floatValue);
    }
    
    if (originalSize.height > 0 && originalSize.width > 0) {
        size.height = originalSize.height / originalSize.width * size.width;
    }
    
    //We calculated the size of the image, but let Texture calculate the rest of the cell (size for cell captions)
    return ASSizeRangeMake(size, CGSizeMake(size.width, INFINITY));
}


- (void)insertItemsInCollection:(NSArray *)items{
    NSInteger section = 0;
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger newTotalNumberOfPhotos = self.collectionData.count + items.count;
    for (NSUInteger row = self.collectionData.count; row < newTotalNumberOfPhotos; row++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        [indexPaths addObject:path];
        
    }
    
    [self.collectionData addObjectsFromArray:items];
    
//    while(self.collectionData.count % 2 != 0 && self.blogIndex < self.blogData.count) {
//        [self.collectionData addObject:self.blogData[self.blogIndex]];
//        self.blogIndex += 1;
//    }
    
    [self.collectionNode insertItemsAtIndexPaths:indexPaths];
}

#pragma mark - ScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSArray *visibleNodes = [self.collectionNode indexPathsForVisibleItems];
    for (NSIndexPath *index in visibleNodes) {
        ASCellNode *node = [self.collectionNode nodeForItemAtIndexPath:index];
        if ([node isKindOfClass:[VideoPlayerNode class]]) {
            VideoPlayerNode *vidNode = (VideoPlayerNode *)node;
            if (vidNode.playerNode.isPlaying) {
                [vidNode.playerNode pause];
            }
        }
    }
}

//These two methods ensure that user has stopped scrolling
-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    //ensure that the end of scroll is fired.
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSArray *visibleNodes = [self.collectionNode indexPathsForVisibleItems];
    
    for (NSIndexPath *index in visibleNodes) {
        ASCellNode *node = [self.collectionNode nodeForItemAtIndexPath:index];
        if ([node isKindOfClass:[VideoPlayerNode class]]) {
            UICollectionViewLayoutAttributes *vidCellAttribute = [self.collectionNode.view layoutAttributesForItemAtIndexPath:index];
            BOOL completelyVisible = CGRectContainsRect(self.collectionNode.view.bounds, vidCellAttribute.frame);
            VideoPlayerNode *vidNode = (VideoPlayerNode *)node;
            if (completelyVisible) {
                [vidNode.playerNode play];
            }
        }
    }
}

#pragma mark - UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    //Disable scroll to top if coming from a different page
    if (self.canScrollToTop) {
        [self.collectionNode.view setContentOffset:CGPointMake(0, -self.collectionNode.view.contentInset.top) animated:YES];//Scroll to top only if tableview is visible
    }
    
    UINavigationController *nav = (UINavigationController *)viewController;
    UIViewController *root = [[nav viewControllers]firstObject];
    if ([root isKindOfClass:[UserProfileViewController class]]) {
        [FoodheadAnalytics logEvent:PROFILE_TAB_CLICK];
    }else if ([root isKindOfClass:[SearchViewController class]]){
        [FoodheadAnalytics logEvent:SEARCH_TAB_CLICK];
    }
}

@end
