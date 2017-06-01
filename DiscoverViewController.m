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
#import "TPLRestaurantPageViewController.h"
#import "UserProfileViewController.h"
#import "SearchViewController.h"
#import "FoodheadAnalytics.h"
#import "DiscoverNode.h"
#import "AnimationPreviewViewController.h"
#import "AssetPreviewViewController.h"
#import "PreviewAnimation.h"
#import "DiscoverRealm.h"
#import "BrowseViewController.h"
#import "UserAuthManager.h"
#import "UIFont+Extension.h"
#import "OnboardingView.h"
#import "LoginViewController.h"
#import "Timer.h"


#import "Chart.h"
#import "Places.h"

#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>

@interface DiscoverViewController ()<UITabBarControllerDelegate, ASCollectionDelegate, ASCollectionDataSource, LocationManagerDelegate, DiscoverNodeDelegate, CHTCollectionViewDelegateWaterfallLayout>

//UI
@property (nonatomic, assign) BOOL canScrollToTop;
@property (nonatomic, strong) CHTCollectionViewWaterfallLayout *waterfallLayout;
@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, strong) ASCollectionNode *collectionNode;
@property (nonatomic, strong) UIView *contextView;
@property (nonatomic, strong) UILabel *contextLabel;

//Flag to autoplay videos on intial load since user probably hasn't scrolled yet.
@property (nonatomic, assign) BOOL isInitialLoad;

//Datasource
@property (nonatomic, strong) NSMutableArray *collectionData;
@property (nonatomic, strong) NSMutableSet *restIdSet;//Create a reference table of restaurant ids to avoid duplicates for now...

@property (nonatomic, strong) NSMutableDictionary *videoAssets;//Cache video assets to prevent reload each time in order to optimize scrolling

@property (nonatomic, strong) NSMutableArray *blogData;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) NSInteger blogIndex;//Keeps track of which blog post we should use next
@property (nonatomic, strong) RLMResults *favoritedRestaurants;

//Every time we add or delete, store the primary key (foursqId) with index in here locally and save the index since our RLMResults indexing doesn't match with ours (neccessary for updating the cells as favorites or not).
@property (nonatomic, strong) NSMutableDictionary *favoritedIndexes;
@property (nonatomic, strong) RLMNotificationToken *favNotif;

//View Model
@property (nonatomic, strong) TPLChartsViewModel *viewModel;

//Refresh Control
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL wasFullyRefreshed;//Need to make sure all charts were loaded before refreshing again so that we don't get any weird results.

//User
@property (nonatomic, strong) UserAuthManager *authManager;

//Onboarding
@property (nonatomic, strong) OnboardingView *browseOnboardView;
@property (nonatomic, strong) OnboardingView *favoriteOnboardView;
@property (nonatomic, strong) UITapGestureRecognizer *tooltipTap;

//Timing for analytics
@property (nonatomic, assign) CFTimeInterval startTime;

@end

#define NUM_COLUMNS 2

@implementation DiscoverViewController

- (instancetype)init{
    if (!(self = [super init])) { return nil; }
    
    self.waterfallLayout = [[CHTCollectionViewWaterfallLayout alloc]init];
    self.waterfallLayout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
    self.waterfallLayout.columnCount = NUM_COLUMNS;
    self.waterfallLayout.minimumColumnSpacing = 10.0;
    //self.waterfallLayout.minimumInteritemSpacing = 5.0;
    self.waterfallLayout.sectionInset = UIEdgeInsetsMake([[UIApplication sharedApplication]statusBarFrame].size.height + 5.0, 10.0, 0.0, 10.0);
    
    _collectionNode = [[ASCollectionNode alloc] initWithCollectionViewLayout:self.waterfallLayout];
    _collectionNode.delegate = self;
    _collectionNode.dataSource = self;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;
    self.isInitialLoad = YES;
    
    [self verifyCurrentUser];
    
    self.viewModel = [[TPLChartsViewModel alloc]init];
    self.collectionData = [NSMutableArray array];
    self.favoritedIndexes = [NSMutableDictionary dictionary];
    self.videoAssets = [NSMutableDictionary dictionary];
    self.restIdSet = [NSMutableSet set];
    self.blogData = [NSMutableArray array];
    self.blogIndex = 0;
    
    [self setupNavBar];
    [self setupUI];
    
    self.locationManager = [LocationManager sharedLocationInstance];
    self.locationManager.locationDelegate = self;
    [self.locationManager retrieveCurrentLocation];
    
    self.favoritedRestaurants = [DiscoverRealm allObjects];
    
    __weak typeof(self) weakSelf = self;
    self.favNotif = [self.favoritedRestaurants addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        if (error) {
            DLog(@"Couldn't create discover realm token");
        }
        
        //Change is nil for the intial run of realm query, so just load whatever we have
        if (!change) {
            return;
        }
        
        //Change is not nil so something changed during the app lifetime
        [weakSelf.collectionNode beginUpdates];
        if ([change deletionsInSection:0].count > 0) [weakSelf deleteFavorites:[change deletionsInSection:0]];
        if ([change insertionsInSection:0].count > 0) [weakSelf insertFavorites:[change insertionsInSection:0]];
        [weakSelf.collectionNode endUpdatesAnimated:NO];
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationBecameActive) name:UIApplicationDidBecomeActiveNotification object:nil];
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
    [[Timer sharedInstance]startTrackingHomeTime];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.canScrollToTop = NO;
    self.locationManager.locationDelegate = nil;
    [[[self navigationController] interactivePopGestureRecognizer] setEnabled:YES];
    [[Timer sharedInstance]stopTrackingHomeTime];
}

- (void)applicationBecameActive{
    if (self.tabBarController.selectedIndex == 0) {
        [[Timer sharedInstance]startTrackingHomeTime];
    }
}

- (void)setupNavBar{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont nun_fontWithSize:APPLICATION_FRAME.size.width * 0.05]};
}

- (void)dealloc{
    [self.favNotif stop];
    self.favNotif = nil;
}

#pragma mark - LocationManager delegate methods

//TODO: REFACTOR randomization logic into VM
//This method is binded to our view model through a signal that's fired each time a new chart is retrieved.
- (void)didGetCurrentLocation:(CLLocationCoordinate2D)coordinate{
    @weakify(self);
    
    self.wasFullyRefreshed = NO;
    //Get all blog posts first, then keep appending them to newly collected chart data
    [[[self.viewModel getRecentBlogPostsAtLocation:coordinate forPage:nil withLimit:@"300"]deliverOnMainThread]subscribeNext:^(Places *blogPosts) {
        @strongify(self);
        for (TPLRestaurant *restaurant in blogPosts.places) {
            [self.blogData addObject:restaurant];
            [self.restIdSet addObject:restaurant.foursqId];//Blog posts should always be shown instead of the Foursqaure result so make sure they're all added in our set first.
        }
    }error:^(NSError * _Nullable error) {
        //Even if blog posts fail, charts may still work so at least try to retrieve them. If anything, the error block in the charts request will just get called
        [self getChartsAtCoordinate:coordinate];
        DLog(@"Error retrieving blog posts: %@", error);
    }completed:^{
        [self getChartsAtCoordinate:coordinate];
    }];
}

- (void)getChartsAtCoordinate:(CLLocationCoordinate2D)coordinate{
    @weakify(self);
    
    __block NSMutableArray *tempArr = [NSMutableArray array];//Temp array used to string in blog content with chart data.
    __block int blogIndex = 0;
    
    [[[self.viewModel getChartsAtLocation:coordinate]deliverOnMainThread]subscribeNext:^(Places *restaurants) {
        @strongify(self);
        //Reset tempArr each time since we're adding in items as they come. If we reuse tempArr with our insertItemInCollection method, the data we've already added will be shown again for each new chart.
        [tempArr removeAllObjects];
        for (NSUInteger i = 0; i < restaurants.places.count; ++i) {
            //For every fourth result, make it a blog post.
            if (i % 4 == 0 && blogIndex < self.blogData.count) {
                [tempArr addObject:self.blogData[blogIndex]];
                ++blogIndex;
            }else{
                TPLRestaurant *restaurant = restaurants.places[i];
                //If restaurant has already been added based on our stored rest ids, skip it.
                BOOL restaurantAdded = [self.restIdSet containsObject:restaurant.foursqId];
                if (!restaurantAdded) {
                    [tempArr addObject:restaurant];
                    [self.restIdSet addObject:restaurant.foursqId];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopRefreshControl];
            [self insertItemsInCollection:tempArr];
        });
    }error:^(NSError * _Nullable error) {
        [self stopRefreshControl];
        self.wasFullyRefreshed = YES;
        DLog(@"Error loading all chart info: %@", error);
    } completed:^{
        self.wasFullyRefreshed = YES;
        DLog(@"Successfully retrieved all charts!");
    }];
}

- (void)didGetCurrentCity:(NSString *)locationString{
    [self.contextLabel setText:locationString];
}

#pragma mark - User Session

//Redirect and logout if credential aren't the same as last logged in user or expired auth
- (void)verifyCurrentUser{
    self.authManager = [UserAuthManager sharedInstance];
    [self.authManager retrieveCurrentUser:^(id user) {
        
        //TODO:: Refactor this check into AuthManager and just return an error (or nil) if user ids dont match
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_USER_DEFAULT];
        User *lastUser;
        if (data) {
            lastUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        User *currentUser = (User *)user;
        if ([currentUser.userId isEqual: lastUser.userId]) {
            DLog(@"Same user, do nothing.");
        }
    }failureHandler:^(id error) {
        //Anon login handle
    }];
}

#pragma mark - ASCollectionDelegate methods
- (void)collectionNode:(ASCollectionNode *)collectionNode didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DiscoverNode *node = [self.collectionNode nodeForItemAtIndexPath:indexPath];
    TPLRestaurant *restInfo = node.restaurantInfo;
    
    TPLRestaurantPageViewController *restPageVC = [[TPLRestaurantPageViewController alloc]init];
    restPageVC.selectedRestaurant = restInfo;
    restPageVC.indexPath = indexPath;
    [self.navigationController pushViewController:restPageVC animated:YES];
}

#pragma mark - ASCollectionNodeDatasource methods

- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section{
    return self.collectionData.count;
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath{
    TPLRestaurant *restaurant = self.collectionData[indexPath.row];
    
    //Check if restaurant is a favorite through its primary key
    RLMResults *favResult = [self.favoritedRestaurants objectsWithPredicate:[NSPredicate predicateWithFormat:@"foursqId == %@", restaurant.foursqId]];
    DiscoverRealm *favRest = [favResult firstObject];
    NSString *primaryKey;
    if (favRest) {
        primaryKey = favRest.foursqId;
    }
    
    return ^{
        DiscoverNode *imgNode = [[DiscoverNode alloc]initWithRestauarnt:restaurant andPrimaryKey:primaryKey];
        imgNode.delegate = self;
        return imgNode;
    };
}

- (void)collectionNode:(ASCollectionNode *)collectionNode willDisplayItemWithNode:(ASCellNode *)node{
    NSIndexPath *indexPath = [self.collectionNode indexPathForNode:node];
    TPLRestaurant *restaurant = self.collectionData[indexPath.row];
    
    if (indexPath.row == self.collectionData.count - 1) {
        [FoodheadAnalytics logEvent:END_OF_DISCOVER];
    }
    
    if (restaurant.hasVideo.boolValue) {
        DiscoverNode *vidNode = (DiscoverNode *)node;
        
        //Foursquare id is used to retrieve asset for faster lookup
        NSDictionary *assetDict = [self.videoAssets objectForKey:restaurant.foursqId];
        if (assetDict) {
            AVAsset *cachedAsset = [assetDict objectForKey:ASSET_KEY];
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
                NSURL *vidURL = [NSURL URLWithString:restaurant.blogVideoLink];
                AVAsset *asset = [AVAsset assetWithURL:vidURL];
                NSArray *keys = @[@"playable", @"tracks", @"duration"];
                [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                    NSError *error;
                    for (NSString *key in keys) {
                        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                        if (keyStatus == AVKeyValueStatusFailed) {
                            DLog(@"Failed to load key : %@ with error: %@", key, error);
                        }
                    }
                    
                    if (!error) {
                        //Only play when absolutely possible and necessary
                        dispatch_async(dispatch_get_main_queue(), ^{
                            vidNode.playerNode.asset = asset;
                            //Cache asset with its link here
                            NSDictionary *assetDict = @{ASSET_KEY : asset, ASSET_LINK_KEY : restaurant.blogVideoLink};
                            [self.videoAssets setObject:assetDict forKey:restaurant.foursqId];
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
    
    //TPLRestaurant *resturant = self.collectionData[indexPath.row];
    
    //Width is always constant, but height depends on aspect ratio of asset. If no asset, the size will just give an even square.
    CGSize size = CGSizeMake(widthPerItem, widthPerItem);
    
//    CGSize originalSize;
//    if (resturant.blogName) {
//        originalSize = CGSizeMake(resturant.blogPhotoWidth.floatValue, resturant.blogPhotoHeight.floatValue);
//    }else if (resturant.hasVideo.boolValue){
//        originalSize = CGSizeMake(resturant.blogVideoWidth.floatValue, resturant.blogVideoHeight.floatValue);
//    }else if(resturant.thumbnail){
//        originalSize = CGSizeMake(resturant.thumbnailWidth.floatValue, resturant.thumbnailHeight.floatValue);
//    }
    
    //if (originalSize.height > 0 && originalSize.width > 0) {
    //    size.height = originalSize.height / originalSize.width * size.width;
    //}
    
    //Simply constrain the width of each cell and let Texture calculate the rest of the cell accordingly based on aspect ratio of image (handled in DiscoverNode)
    return ASSizeRangeMake(size, CGSizeMake(size.width, INFINITY));
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    DiscoverNode *node = [self.collectionNode nodeForItemAtIndexPath:indexPath];
//    return node.bounds.size;
//}


- (void)insertItemsInCollection:(NSArray *)items{
    NSInteger section = 0;
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger newTotalNumberOfPhotos = self.collectionData.count + items.count;
    for (NSUInteger row = self.collectionData.count; row < newTotalNumberOfPhotos; row++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        [indexPaths addObject:path];
        
    }
    
    //Cache the favorited restaurant index so we can easily delete them later.
    for (TPLRestaurant *restaurant in items) {
        [self.collectionData addObject:restaurant];
        RLMResults *favResult = [self.favoritedRestaurants objectsWithPredicate:[NSPredicate predicateWithFormat:@"foursqId == %@", restaurant.foursqId]];
        DiscoverRealm *favRest = [favResult firstObject];
        if (favRest) {
            NSUInteger collectionIndex = [self.collectionData indexOfObject:restaurant];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:collectionIndex inSection:0];
            [self.favoritedIndexes setObject:indexPath forKey:restaurant.foursqId];
        }
    }
    
    [self.collectionNode insertItemsAtIndexPaths:indexPaths];
}

//TODO: These are both very dumb insertion/deletion algs - MUST find a better solution. Only works now since insertion/deletion only 1 or 2 items max

- (void)deleteFavorites:(NSArray<NSIndexPath*> *)deleted{
    //Find the deleted restaurant(s) based on our cached collection
    NSArray *favIds = [self.favoritedIndexes allKeys];
    for (NSString *restId in favIds) {
        //If the restaurant was deleted we shouldn't be able to find it in our updated RLMResults. Guaranteed to only return one object since the foursqId is a primary key
        RLMResults *results = [self.favoritedRestaurants objectsWithPredicate:[NSPredicate predicateWithFormat:@"foursqId == %@", restId]];
        DiscoverRealm *isFav = [results firstObject];
        if (!isFav) {
            //If not a favorite anymore, get the node at previously stored index path and update it
            DiscoverNode *node = [self.collectionNode nodeForItemAtIndexPath:[self.favoritedIndexes objectForKey:restId]];
            [node unfavoriteNode];
            //Finally, update our local favorite dictionary.
            [self.favoritedIndexes removeObjectForKey:restId];
        }
    }
}

- (void)insertFavorites:(NSArray<NSIndexPath *> *)inserted{
    for (NSIndexPath *indexPath in inserted) {
        DiscoverRealm *newFav = self.favoritedRestaurants[indexPath.row];
        NSIndexPath *newFavIndex = [self.favoritedIndexes objectForKey:newFav.foursqId];
        if (!newFavIndex) {
            for (TPLRestaurant *rest in self.collectionData) {
                if([rest.foursqId isEqualToString:newFav.foursqId]){//Compare primary keys to ensure same restaurant
                    NSUInteger nodeIndex = [self.collectionData indexOfObject:rest];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:nodeIndex inSection:0];
                    DiscoverNode *node = [self.collectionNode nodeForItemAtIndexPath:indexPath];
                    [node favoriteNodeWithInfo:newFav];
                    [self.favoritedIndexes setObject:indexPath forKey:newFav.foursqId];
                    break;
                }
            }
        }
    }
}

//Restaurant was favorited, store it's position in our dictionary
- (void)discoverNode:(DiscoverNode *)node didFavoriteRestaurant:(DiscoverRealm *)favorite{
    NSIndexPath *nodeIndex = [self.collectionNode indexPathForNode:node];
    [self.favoritedIndexes setObject:nodeIndex forKey:favorite.foursqId];
}


#pragma mark - ScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.isInitialLoad = NO;//Shouldn't autoplay if user scrolled because methods below will handle this.
    NSArray *visibleNodes = [self.collectionNode indexPathsForVisibleItems];
    for (NSIndexPath *index in visibleNodes) {
        DiscoverNode *node = [self.collectionNode nodeForItemAtIndexPath:index];
        if (node.playerNode.isPlaying) {
            [node.playerNode pause];
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
        DiscoverNode *node = [self.collectionNode nodeForItemAtIndexPath:index];
        UICollectionViewLayoutAttributes *vidCellAttribute = [self.collectionNode.view layoutAttributesForItemAtIndexPath:index];
        BOOL completelyVisible = CGRectContainsRect(self.collectionNode.view.bounds, vidCellAttribute.frame);
        if (completelyVisible) {
            [node.playerNode play];
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
    }else if ([root isKindOfClass:[BrowseViewController class]]){
        [FoodheadAnalytics logEvent:BROWSE_TAB_CLICK];
    }else if (([root isKindOfClass:[DiscoverViewController class]])){
        [FoodheadAnalytics logEvent:DISCOVER_TAB_CLICK];
    }
}

#pragma mark - DiscoverNode delegate methods

- (void)discoverNode:(DiscoverNode *)node didClickVideoWithRestaurant:(TPLRestaurant *)restInfo{
    NSIndexPath *indexPath = [self.collectionNode indexPathForNode:node];
    
    TPLRestaurantPageViewController *restPage = [[TPLRestaurantPageViewController alloc]init];
    restPage.selectedRestaurant = restInfo;
    restPage.indexPath = indexPath;
    [self.navigationController pushViewController:restPage animated:YES];
}


- (void)promptUserSignup{
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    loginVC.isOnboarding = NO;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:loginVC];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - UI

- (void)setupUI{
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
    
    self.contextView = [[UIView alloc]initWithFrame:CGRectMake(0.0, CGRectGetMaxY(statusBarBg.frame), statusBarBg.frame.size.width, statusBarBg.frame.size.height)];
    self.contextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.contextView];
    
    self.contextLabel = [[UILabel alloc]initWithFrame:CGRectMake(_contextView.frame.size.width/2 - _contextView.frame.size.width * 0.45, 0.0, _contextView.frame.size.width * 0.9, _contextView.frame.size.height * 0.95)];
    self.contextLabel.backgroundColor = [UIColor clearColor];
    self.contextLabel.textAlignment = NSTextAlignmentCenter;
    self.contextLabel.font = [UIFont nun_mediumFontWithSize:REST_PAGE_DETAIL_FONT_SIZE - 1];
    [self.contextView addSubview:_contextLabel];
    
//    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.indicatorView.backgroundColor = [UIColor clearColor];
//    self.indicatorView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
//    CGAffineTransform transform = CGAffineTransformMakeScale(1.3f, 1.3f);
//    self.indicatorView.transform = transform;
//    [self.view addSubview:self.indicatorView];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    self.refreshControl.bounds = CGRectMake(_refreshControl.bounds.origin.x,
                                            _refreshControl.bounds.origin.y + self.contextView.frame.size.height * 0.6,
                                            _refreshControl.bounds.size.width,
                                            _refreshControl.bounds.size.height);
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.collectionNode.view.refreshControl = self.refreshControl;
    
    //Onboarding tooltip
    if ([[NSUserDefaults standardUserDefaults]boolForKey:MAIN_PAGE_TOOLTIP]) {
        self.browseOnboardView = [[OnboardingView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height) onPage:OnboardingPageHome];
        [[UIApplication sharedApplication].keyWindow addSubview:self.browseOnboardView];
        
        //Must set frame here or the tab bar will get calculated into bounds
        self.favoriteOnboardView = [[OnboardingView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height) onPage:OnboardingPageFavorite];
        
        self.tooltipTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showNextTooltip)];
        self.tooltipTap.numberOfTapsRequired = 1;
        [self.browseOnboardView addGestureRecognizer:self.tooltipTap];
    }
}

- (void)showNextTooltip{
    if ([self.browseOnboardView superview]) {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:MAIN_PAGE_TOOLTIP];
        
        [self.browseOnboardView removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:self.favoriteOnboardView];
        [self.browseOnboardView removeGestureRecognizer:self.tooltipTap];
        [self.favoriteOnboardView addGestureRecognizer:self.tooltipTap];
    }else if ([self.favoriteOnboardView superview]){
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:FAVORITE_TOOLTIP];

        [self.favoriteOnboardView removeFromSuperview];
        [self.favoriteOnboardView removeGestureRecognizer:self.tooltipTap];
    }
}

- (void)stopRefreshControl{
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (void)refreshData{
    //Don't refresh again if chart's haven't all fully loaded
    if (self.wasFullyRefreshed) {
        [self.collectionData removeAllObjects];
        [self.restIdSet removeAllObjects];
        [self.blogData removeAllObjects];
        [self.favoritedIndexes removeAllObjects];
        [self.videoAssets removeAllObjects];
        self.blogIndex = 0;
        self.contextLabel.text = @"";
        
        [self.collectionNode reloadDataWithCompletion:^{
            [[LocationManager sharedLocationInstance] retrieveCurrentLocation];
        }];
    }else{
        //[self.refreshControl endRefreshing];
    }
}

@end
