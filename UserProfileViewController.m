//
//  UserProfileViewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UserProfileViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "UserAuthManager.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"
#import "UserReview.h"
#import "TPLRestaurant.h"
#import "ReviewCollectionViewCell.h"
#import "ReviewMetricView.h"
#import "LoginViewController.h"
#import "NSString+IsEmpty.h"
#import "FoodheadAnalytics.h"
#import "BrowsePlayerNode.h"
#import "DiscoverNode.h"
#import "BrowseVideo.h"
#import "TPLRestaurant.h"
#import "DiscoverRealm.h"
#import "BrowseVideoRealm.h"
#import "FoodWiseDefines.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface UserProfileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, IDMPhotoBrowserDelegate, CHTCollectionViewDelegateWaterfallLayout, ASCollectionDelegate, ASCollectionDataSource, ASTableDelegate, ASTableDataSource, BrowsePlayerNodeDelegate>

@property (nonatomic, strong) UserAuthManager *userManager;
@property (nonatomic, strong) User *currentUser;

//@property (nonatomic, strong) UIButton *logoutButton;

//UI
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, assign) BOOL scrollViewFullscreen;
@property (nonatomic, assign) CGFloat lastTableOffset;
@property (nonatomic, assign) CGFloat lastCollectionOffset;

//Overlaid on the photo collection if user has no meals
@property (nonatomic, strong) UIView *noPhotoView;
@property (nonatomic, strong) UILabel *noPhotoLabel;
@property (nonatomic, strong) UIImageView *noPhotoArrowImg;

//For when user has poor/no connection and needs to reload photos
@property (nonatomic, strong) UIView *noConnectionView;
@property (nonatomic, strong) UILabel *noConnectionLabel;
@property (nonatomic, strong) UITapGestureRecognizer *reloadPhotosGesture;
@property (nonatomic, strong) UIActivityIndicatorView *reloadView;

//Filter between restaurants and videos
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) CHTCollectionViewWaterfallLayout *waterfallLayout;
@property (nonatomic, strong) ASCollectionNode *restaurantCollectionNode;
@property (nonatomic, strong) ASTableNode *videoTableNode;

//Datasource
@property (nonatomic, strong) RLMResults *savedRestaurants;
@property (nonatomic, strong) RLMThreadSafeReference *restRef;

@property (nonatomic, strong) RLMResults *savedVideos;
@property (nonatomic, strong) RLMNotificationToken *restaurantsNotif;
@property (nonatomic, strong) RLMNotificationToken *videosNotif;

@property (nonatomic, strong) NSMutableDictionary *videoAssets;
@property (nonatomic, strong) NSMutableArray *assetArr;
@property (nonatomic, strong) NSIndexPath *currentPlayingIndex;

//Auto play properties
@property (nonatomic, assign) BOOL scrollingDown;
@property (nonatomic, assign) BOOL initialTableLoad;
@property (nonatomic, assign) BOOL initialCollectionLoad;


//Tracks how fast user scrolls
@property (nonatomic, assign) CGPoint lastOffset;
@property (nonatomic, assign) NSTimeInterval lastOffsetCapture;
@property (nonatomic, assign) BOOL isScrollingFast;

@end

static NSString *cellId = @"userPhoto";

#define NUM_COLUMNS 2

@implementation UserProfileViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.waterfallLayout = [[CHTCollectionViewWaterfallLayout alloc]init];
        self.waterfallLayout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
        self.waterfallLayout.columnCount = NUM_COLUMNS;
        self.waterfallLayout.minimumColumnSpacing = 10.0;
        self.waterfallLayout.minimumInteritemSpacing = 5.0;
        self.waterfallLayout.sectionInset = UIEdgeInsetsMake(15.0, 10.0, 0.0, 10.0);
        
        _restaurantCollectionNode = [[ASCollectionNode alloc]initWithCollectionViewLayout:_waterfallLayout];
        _restaurantCollectionNode.delegate = self;
        _restaurantCollectionNode.dataSource = self;
        
        _videoTableNode = [[ASTableNode alloc]initWithStyle:UITableViewStylePlain];
        _videoTableNode.delegate = self;
        _videoTableNode.dataSource = self;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];

    self.userManager = [UserAuthManager sharedInstance];

    [self setupUI];
    [self retrieveFavorites];
    [self populateUserData];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)dealloc{
    [self removeObservers];
}

- (void)setupNavBar{
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont nun_mediumFontWithSize:APPLICATION_FRAME.size.width * 0.05], NSForegroundColorAttributeName : [UIColor blackColor]};
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"settings"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    
    self.profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.75 - self.view.frame.size.width * 0.125, self.view.frame.size.height * 0.15, self.view.frame.size.width * 0.25, self.view.frame.size.width * 0.25)];
    //self.profileImageView.contentMode ;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2;
    self.profileImageView.backgroundColor = [UIColor clearColor];
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.userInteractionEnabled = YES;
    self.profileImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.profileImageView.layer.borderWidth = 1.0;
    [self.view addSubview:self.profileImageView];
    
    UITapGestureRecognizer *avatarGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewAvatar)];
    avatarGesture.numberOfTapsRequired = 1;
    [self.profileImageView addGestureRecognizer:avatarGesture];
    
    self.usernameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.4, CGRectGetMinX(self.profileImageView.frame) - self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.06)];
    self.usernameLabel.textAlignment = NSTextAlignmentCenter;
    self.usernameLabel.textAlignment = NSTextAlignmentCenter;
    self.usernameLabel.backgroundColor = [UIColor clearColor];
    self.usernameLabel.textColor = [UIColor blackColor];
    [self.usernameLabel setFont:[UIFont nun_fontWithSize:self.view.frame.size.height * 0.05]];
    [self.view addSubview:self.usernameLabel];
     
    self.locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.2, CGRectGetMaxY(self.usernameLabel.frame) + 4.0, self.view.frame.size.width * 0.4, self.view.frame.size.height * 0.03)];
    self.locationLabel.backgroundColor = [UIColor clearColor];
    self.locationLabel.textColor = [UIColor grayColor];
    self.locationLabel.textAlignment = NSTextAlignmentCenter;
    self.locationLabel.font = [UIFont nun_fontWithSize:self.view.frame.size.height * 0.02];
    [self.view addSubview:self.locationLabel];
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont nun_boldFontWithSize:16.0], NSForegroundColorAttributeName : [UIColor blackColor]};
    
    self.segmentedControl = [[UISegmentedControl alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2 - self.view.bounds.size.width * 0.475, CGRectGetMaxY(self.locationLabel.frame) + self.view.bounds.size.height * 0.01, self.view.bounds.size.width * 0.95, self.view.bounds.size.height * 0.07)];
    self.segmentedControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.segmentedControl.tintColor = [UIColor clearColor];
    self.segmentedControl.layer.cornerRadius = 7.0;
    self.segmentedControl.clipsToBounds = YES;
    
//    [self.segmentedControl setBackgroundImage:[UIImage imageNamed:@"segment-button-selected"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [self.segmentedControl setBackgroundImage:[UIImage imageNamed:@"segment-button"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    [self.segmentedControl insertSegmentWithTitle:@"Restaurants" atIndex:0 animated:YES];
    [self.segmentedControl insertSegmentWithTitle:@"Videos" atIndex:1 animated:YES];
    [self.segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    //Default start on restaurant list
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.view addSubview:self.segmentedControl];
    
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views

    _restaurantCollectionNode.frame = CGRectMake(self.segmentedControl.frame.origin.x, CGRectGetMaxY(self.segmentedControl.frame), self.segmentedControl.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.segmentedControl.frame));
    _restaurantCollectionNode.view.contentInset = adjustForTabbarInsets;
    _restaurantCollectionNode.view.scrollIndicatorInsets = adjustForTabbarInsets;
    _restaurantCollectionNode.hidden = NO;
    _restaurantCollectionNode.view.bounces = NO;
    _restaurantCollectionNode.view.showsVerticalScrollIndicator = NO;
    
    _videoTableNode.frame = CGRectMake(self.segmentedControl.frame.origin.x, CGRectGetMaxY(self.segmentedControl.frame), self.segmentedControl.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.segmentedControl.frame));
    _videoTableNode.view.contentInset = adjustForTabbarInsets;
    _videoTableNode.view.scrollIndicatorInsets = adjustForTabbarInsets;
    _videoTableNode.hidden = YES;
    _videoTableNode.view.bounces = NO;
    _videoTableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    _videoTableNode.view.showsVerticalScrollIndicator = NO;
    
    self.scrollViewFullscreen = NO;
    
    [self.view addSubnode:_restaurantCollectionNode];
    [self.view addSubnode:_videoTableNode];
}

- (void)retrieveFavorites{
    self.assetArr = [NSMutableArray array];
    self.videoAssets = [NSMutableDictionary dictionary];
    self.initialCollectionLoad = YES;
    
    //Sort favorites by most recent
    self.savedRestaurants = [DiscoverRealm allObjects];
    self.savedRestaurants = [self.savedRestaurants sortedResultsUsingKeyPath:@"creationDate" ascending:NO];
    [self insertItemsInCollection:self.savedRestaurants];
    
    self.savedVideos = [BrowseVideoRealm allObjects];
    self.savedVideos = [self.savedVideos sortedResultsUsingKeyPath:@"creationDate" ascending:NO];
    [self insertItemsInTable:self.savedVideos];
    
    //Setup notification blocks for videos and restaurants so changes will always be reflected from  anywhere in the app
    __weak typeof(self) weakSelf = self;
    self.restaurantsNotif = [self.savedRestaurants addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Couldn't create restaurants realm token");
        }
        
        //Change is nil for the intial run of realm query, so just load whatever we have
        if (!change) {
            return;
        }
        
        //Change is not nil so something changed during the app lifetime
        [weakSelf.restaurantCollectionNode beginUpdates];
        [weakSelf.restaurantCollectionNode insertItemsAtIndexPaths:[change insertionsInSection:0]];
        [weakSelf.restaurantCollectionNode deleteItemsAtIndexPaths:[change deletionsInSection:0]];
        [weakSelf.restaurantCollectionNode reloadItemsAtIndexPaths:[change modificationsInSection:0]];
        [weakSelf.restaurantCollectionNode endUpdatesAnimated:YES];
    }];
    
    
    self.videosNotif = [self.savedVideos addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Couldn't create videos realm token");
        }
        
        //Change is nil for the intial run of realm query, so just load whatever we have
        if(!change){
            return;
        }
        
        //Change is not nil so something changed during the app lifetime
        [weakSelf.videoTableNode.view beginUpdates];
        [weakSelf.videoTableNode insertRowsAtIndexPaths:[change insertionsInSection:0] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.videoTableNode deleteRowsAtIndexPaths:[change deletionsInSection:0] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.videoTableNode reloadRowsAtIndexPaths:[change modificationsInSection:0] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.videoTableNode.view endUpdates];
        
        //Delete the cached asset if deleted from bookmarks
        for (NSIndexPath *index in [change deletionsInSection:0]) {
            [weakSelf.assetArr removeObjectAtIndex:index.row];
        }
        
        //For any new video saved, add a placeholder to asset cache
        for (NSIndexPath *index in [change insertionsInSection:0]){
            [weakSelf.assetArr insertObject:[NSNull null] atIndex:index.row];
        }
    }];
}

#pragma mark - User methods

- (void)populateUserData{
    self.currentUser = [self.userManager getCurrentUser];
    if (self.currentUser && (self.currentUser.avatarURL || self.currentUser.avatarImg)) {
        self.navigationController.navigationBar.topItem.title = self.currentUser.username;
        
#warning If you open this tab quick enough (before charts verifies user), the avatar img might not be present (from the cache) so load the url if anything. Need to re-think this user verification logic and/or loading this page eventually
        if (self.currentUser.avatarImg) {
            [self.profileImageView setImage:self.currentUser.avatarImg];
        }else{
            [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.currentUser.avatarURL] placeholderImage:[UIImage new] options:SDWebImageRetryFailed];
        }
        self.usernameLabel.text = [NSString stringWithFormat:@"%@ %@", self.currentUser.firstName, self.currentUser.lastName];
        if (self.currentUser.location) {
            self.locationLabel.text = self.currentUser.location;
        }
    }else{
        [self.profileImageView setImage:[UIImage imageNamed:@"empty_profile"]];
    }
}


//- (void)updateUserPhotos{
//    if ([self.noConnectionView superview]) {
//        [self.noConnectionLabel setHidden:YES];
//        self.reloadView = [[UIActivityIndicatorView alloc]init];
//        self.reloadView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//        self.reloadView.center = CGPointMake(self.noConnectionView.center.x, self.noConnectionView.center.y - self.noConnectionView.frame.size.height * 0.12);
//        [self.noConnectionView addSubview:self.reloadView];
//        [self.reloadView startAnimating];
//    }
//}

#pragma mark - Helper Methods

//- (void)showNoPhotoPrompt{
//    if (![self.noPhotoView superview]) {
//        self.noPhotoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.userPhotoCollection.frame.size.width, self.userPhotoCollection.frame.size.height)];
//        self.noPhotoView.backgroundColor = APPLICATION_BLUE_COLOR;
//        [self.userPhotoCollection addSubview:self.noPhotoView];
//        
//        self.noPhotoLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.noPhotoView.frame.size.width/2 - self.noPhotoView.frame.size.width * 0.4, self.noPhotoView.frame.size.height * 0.1, self.noPhotoView.frame.size.width * 0.8, self.noPhotoView.frame.size.height * 0.2)];
//        self.noPhotoLabel.backgroundColor = [UIColor clearColor];
//        self.noPhotoLabel.textAlignment = NSTextAlignmentCenter;
//        self.noPhotoLabel.textColor = [UIColor whiteColor];
//        self.noPhotoLabel.numberOfLines = 2;
//        self.noPhotoLabel.font = [UIFont nun_mediumFontWithSize:REST_PAGE_HEADER_FONT_SIZE * 1.12];
//        self.noPhotoLabel.text = @"You haven't shared any meals yet.\nClick on the camera to start!";
//        [self.noPhotoView addSubview:self.noPhotoLabel];
//        
//        self.noPhotoArrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.tabBarController.tabBar.bounds.size.width * 0.555, self.noPhotoView.bounds.size.height * 0.9, self.view.frame.size.width * 0.17, self.view.frame.size.width * 0.17)];
//        self.noPhotoArrowImg.layer.rasterizationScale = [[UIScreen mainScreen]scale];
//        self.noPhotoArrowImg.layer.shouldRasterize = YES;
//        self.noPhotoArrowImg.backgroundColor = [UIColor clearColor];
//        [self.noPhotoArrowImg setImage:[UIImage imageNamed:@"owl_full"]];
//        [self.noPhotoView addSubview:self.noPhotoArrowImg];
//    }
//}
//
//- (void)showNoConnectionView{
//    self.noConnectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.userPhotoCollection.frame.size.width, self.userPhotoCollection.frame.size.height)];
//    self.noConnectionView.backgroundColor = [UIColor whiteColor];
//    [self.userPhotoCollection addSubview:self.noConnectionView];
//    
//    self.noConnectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.noConnectionView.frame.size.width/2 - self.noConnectionView.frame.size.width * 0.4, self.noConnectionView.frame.size.height * 0.05, self.noConnectionView.frame.size.width * 0.8, self.noConnectionView.frame.size.height * 0.2)];
//    self.noConnectionLabel.backgroundColor = [UIColor clearColor];
//    self.noConnectionLabel.textAlignment = NSTextAlignmentCenter;
//    self.noConnectionLabel.numberOfLines = 1;
//    self.noConnectionLabel.font = [UIFont nun_fontWithSize:self.noConnectionView.frame.size.height * 0.05];
//    self.noConnectionLabel.text = @"Couldn't load photos. Tap to retry!";
//    [self.noConnectionView addSubview:self.noConnectionLabel];
//    
//    self.reloadPhotosGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(updateUserPhotos)];
//    self.reloadPhotosGesture.numberOfTapsRequired = 1;
//    [self.noConnectionView addGestureRecognizer:self.reloadPhotosGesture];
//}

//- (void)removeErrorView{
//    if ([self.noPhotoView superview]) {
//        [self.noPhotoView removeFromSuperview];
//    }else if ([self.noConnectionView superview]){
//        [self.noConnectionView removeFromSuperview];
//    }
//}

- (void)viewAvatar{
    if (self.currentUser && (self.currentUser.avatarURL || self.currentUser.avatarImg)) {
        IDMPhoto *avatarPhoto = [[IDMPhoto alloc]initWithURL:[NSURL URLWithString:self.currentUser.avatarURL]];
        NSArray *avatarPhotos = @[avatarPhoto];
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc]initWithPhotos:avatarPhotos];
        browser.displayDoneButton = NO;
        browser.displayToolbar = NO;
        browser.dismissOnTouch = YES;
        browser.forceHideStatusBar = YES;
        [FoodheadAnalytics logEvent:PROFILE_PHOTO_OPEN];
        [self presentViewController:browser animated:YES completion:nil];
    }else{
        //No account so let them create one
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        loginVC.isOnboarding = NO;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)openSettings{
    SettingsViewController *settingsVC = [[SettingsViewController alloc]init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

//- (void)logout{
//    UserAuthManager *authManager = [UserAuthManager sharedInstance];
//    [authManager logoutUser:^(id completed) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"Logout successful");
//            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//            [appDelegate changeRootViewControllerFor:RootViewTypeLogin withAnimation:NO];
//        });
//    } failureHandler:^(id error) {
//        NSLog(@"Logout failed: %@", error);
//    }];
//}

- (void)addObservers{
    //Update user info and photos if they login from profile
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(populateUserData) name:SIGNUP_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUserPhotos) name:SIGNUP_NOTIFICATION object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SIGNUP_NOTIFICATION object:nil];
    self.restaurantsNotif = nil;
    self.videosNotif = nil;
}

- (void)changeView:(UISegmentedControl *)segmentControl{
    switch (segmentControl.selectedSegmentIndex) {
        case 0:{
            [_videoTableNode.view setContentOffset:CGPointZero animated:NO];
            _videoTableNode.hidden = YES;
            _restaurantCollectionNode.hidden = NO;
            break;
        }
        case 1:{
            [_restaurantCollectionNode.view setContentOffset:CGPointZero animated:NO];
            _restaurantCollectionNode.hidden = YES;
            _videoTableNode.hidden = NO;
            break;
        }
        default:
            break;
    }
}

#pragma mark ASCollectionNodeDataSourceMethods

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    DiscoverRealm *rlmRestaurant = self.savedRestaurants[indexPath.row];
    RLMThreadSafeReference *restRef = [RLMThreadSafeReference referenceWithThreadConfined:rlmRestaurant];
    return ^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        DiscoverRealm *threadRef = [realm resolveThreadSafeReference:restRef];
        DiscoverNode *imgNode = [[DiscoverNode alloc]initWithSavedRestaurant:threadRef];
        return imgNode;
    };
}

- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section{
    return self.savedRestaurants.count;
}

- (NSInteger)numberOfSectionsInCollectionNode:(ASCollectionNode *)collectionNode{
    return 1;
}

- (void)collectionNode:(ASCollectionNode *)collectionNode willDisplayItemWithNode:(ASCellNode *)node{
    NSIndexPath *indexPath = [collectionNode indexPathForNode:node];
    DiscoverRealm *restaurant = self.savedRestaurants[indexPath.row];
    if (restaurant.hasVideo.boolValue) {
        DiscoverNode *vidNode = (DiscoverNode *)node;
        //Foursquare id is used to retrieve asset link for faster lookup
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
                    });
                }
            }];
        }else{
            //Only set the asset for the video node until absolutley necessary, otherwise Texture will perform uneccssary AVPlayer work and slow down the UI.
            
            RLMThreadSafeReference *ref = [RLMThreadSafeReference referenceWithThreadConfined:restaurant];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                RLMRealm *realm = [RLMRealm defaultRealm];
                DiscoverRealm *restRef = [realm resolveThreadSafeReference:ref];
                NSURL *vidURL = [NSURL URLWithString:restRef.thumbnailVideoLink];
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
                            if (self.initialTableLoad) {
                                [self scrollViewDidEndScrollingAnimation:self.restaurantCollectionNode.view];
                                self.initialTableLoad = NO;
                            }
                        });
                    }
                }];
            });
        }
    }
}


- (ASSizeRange)collectionNode:(ASCollectionNode *)collectionNode constrainedSizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat availableWidth = CGRectGetWidth(self.restaurantCollectionNode.bounds) - self.waterfallLayout.minimumColumnSpacing - (self.waterfallLayout.sectionInset.right + self.waterfallLayout.sectionInset.left);
    CGFloat widthPerItem = availableWidth/NUM_COLUMNS;
    
    DiscoverRealm *resturant = self.savedRestaurants[indexPath.row];
    
    //Width is always constant, but height depends on size of asset.
    
    CGSize size = CGSizeMake(widthPerItem, 0);
    
    CGSize originalSize;
    if (resturant.thumbnailPhotoLink) {
        originalSize = CGSizeMake(resturant.thumbnailPhotoWidth.floatValue, resturant.thumbnailPhotoHeight.floatValue);
    }else if (resturant.hasVideo.boolValue){
        originalSize = CGSizeMake(resturant.thumbnailVideoWidth.floatValue, resturant.thumbnailPhotoHeight.floatValue);
    }
    
    if (originalSize.height > 0 && originalSize.width > 0) {
        size.height = originalSize.height / originalSize.width * size.width;
    }
    
    //We calculated the size of the image, but let Texture calculate the rest of the cell (size for cell captions)
    return ASSizeRangeMake(size, CGSizeMake(size.width, INFINITY));
}

#pragma mark - ASTableNodeDataSource methods

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath{
    BrowseVideoRealm *rlmVid = self.savedVideos[indexPath.row];
    RLMThreadSafeReference *vidRef = [RLMThreadSafeReference referenceWithThreadConfined:rlmVid];
    return ^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        BrowseVideoRealm *threadRef = [realm resolveThreadSafeReference:vidRef];
        BrowsePlayerNode *vidNode = [[BrowsePlayerNode alloc]initWithSavedVideo:threadRef];
        vidNode.delegate = self;
        return vidNode;
    };
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section{
    return self.savedVideos.count;
}

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode{
    return 1;
}

- (void)tableNode:(ASTableNode *)tableNode willDisplayRowWithNode:(ASCellNode *)node{
    NSIndexPath *indexPath = [tableNode indexPathForNode:node];
    BrowsePlayerNode *vidNode = (BrowsePlayerNode *)node;
    BrowseVideoRealm *video = self.savedVideos[indexPath.row];
    NSString *vidLink = video.videoLink;
    
    if (vidNode.videoNode.asset == nil) {
        NSDictionary *cachedAsset = self.assetArr[indexPath.row];
        if (![cachedAsset isEqual:[NSNull null]]) {
            //If we have already loaded an asset, use it.
            AVAsset *asset = cachedAsset[@"asset"];
            NSNumber *lastPlayTime = cachedAsset[@"lastPlayTime"];
            vidNode.videoNode.asset = asset;
            
            //If video has been played, resume the last time the user stopped at.
            NSArray *keys = @[@"playable", @"duration", @"tracks"];
            [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                NSError *error;
                for (NSString *key in keys) {
                    AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                    if (keyStatus == AVKeyValueStatusFailed) {
                        DLog(@"Failed to load key : %@ with error: %@", key, error);
                    }
                }
                
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        vidNode.videoNode.asset = asset;
                        int32_t timeScale = asset.duration.timescale;
                        CMTime time = CMTimeMakeWithSeconds(lastPlayTime.floatValue, timeScale);
                        [vidNode.videoNode.videoNode.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                    });
                }
            }];
        }else{
            if ([video.isYoutubeVideo boolValue]) {
                [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:video.videoLink completionHandler:^(XCDYouTubeVideo * _Nullable video, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"%@", error);
                    }else{
                        NSURL *vidURL = [video.streamURLs objectForKey:@(XCDYouTubeVideoQualityMedium360)];
                        AVAsset *asset = [AVAsset assetWithURL:vidURL];
                        
                        NSArray *keys = @[@"playable", @"duration", @"tracks"];//This is an extra optimization to not load the asset into the video player unless it's completely ready to be played.
                        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                            NSError *error;
                            for (NSString *key in keys) {
                                AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                                if (keyStatus == AVKeyValueStatusFailed) {
                                    DLog(@"Failed to load key : %@ with error: %@", key, error);
                                }
                            }
                            
                            if (!error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    vidNode.videoNode.asset = asset;
                                });
                            }
                        }];
                    }
                }];
            }else{
                //Only set the asset for the video node until absolutley necessary, otherwise Texture will perform uneccssary AVPlayer work and slow down the UI.
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSURL *vidURL;
                    vidURL = [NSURL URLWithString:vidLink];
                    AVAsset *asset = [AVAsset assetWithURL:vidURL];
                    NSArray *keys = @[@"playable"];
                    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                        NSError *error;
                        for (NSString *key in keys) {
                            AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                            if (keyStatus == AVKeyValueStatusFailed) {
                                DLog(@"Failed to load key : %@ with error: %@", key, error);
                            }
                        }
                        
                        if (!error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                vidNode.videoNode.asset = asset;
                            });
                        }
                    }];
                });
            }
            
            //Always start playing the first video on initial screen load (i.e. When user first opens the app)
            if (self.initialTableLoad && indexPath.row == 0) {
                [vidNode.videoNode play];
                self.currentPlayingIndex = indexPath;
                self.initialTableLoad = NO;
            }
        }
    }
}

- (void)tableNode:(ASTableNode *)tableNode didEndDisplayingRowWithNode:(ASCellNode *)node{
    BrowsePlayerNode *vidNode = (BrowsePlayerNode *)node;
    NSIndexPath *index = [self.videoTableNode indexPathForNode:node];
    //Asset might not have loaded yet so don't try saving
    if (vidNode.videoNode.asset) {
        self.assetArr[index.row] = [self saveAssetWithTime:vidNode];
    }
}

#pragma mark - Helper Methods

- (void)insertItemsInCollection:(RLMResults *)items{
    NSInteger section = 0;
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger newTotalNumberOfPhotos = items.count;
    for (NSUInteger row = 0; row < newTotalNumberOfPhotos; row++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        [indexPaths addObject:path];
    }
    
    [self.restaurantCollectionNode insertItemsAtIndexPaths:indexPaths];
}

- (void)insertItemsInTable:(RLMResults *)items{
    NSInteger section = 0;
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger newTotalNumberOfPhotos = items.count;
    for (NSUInteger row = 0; row < newTotalNumberOfPhotos; row++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        [indexPaths addObject:path];
        [self.assetArr addObject:[NSNull null]];
    }
    
    [self.videoTableNode insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (NSMutableDictionary *)saveAssetWithTime:(BrowsePlayerNode *)playerNode{
    NSMutableDictionary *assetDict = [NSMutableDictionary dictionary];
    [assetDict setObject:playerNode.videoNode.asset forKey:@"asset"];
    CGFloat seconds = CMTimeGetSeconds(playerNode.videoNode.videoNode.player.currentTime);
    [assetDict setObject:@(seconds) forKey:@"lastPlayTime"];
    
    return assetDict;
}

#pragma mark - ScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[ASCollectionNode class]]) {
        self.initialCollectionLoad = NO;//Shouldn't autoplay if user scrolled because methods below will handle this.
        NSArray *visibleNodes = [self.restaurantCollectionNode indexPathsForVisibleItems];
        for (NSIndexPath *index in visibleNodes) {
            DiscoverNode *node = [self.restaurantCollectionNode nodeForItemAtIndexPath:index];
            if (node.playerNode.isPlaying) {
                [node.playerNode pause];
            }
        }
    }
}

//These two methods ensure that user has stopped scrolling
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    CGFloat maxCollectionOffset = scrollView.contentSize.height - CGRectGetHeight(scrollView.frame);
    CGFloat currentCollectionOffset = scrollView.contentOffset.y;
    CGFloat percentageCollectionOffset = currentCollectionOffset / maxCollectionOffset;

//    CGFloat maxCollectionOffset = _restaurantCollectionNode.view.contentSize.height - CGRectGetHeight(_restaurantCollectionNode.view.frame);
//    CGFloat currentCollectionOffset = _restaurantCollectionNode.view.contentOffset.y;
//    CGFloat percentageCollectionOffset = currentCollectionOffset / maxCollectionOffset;
//    
//    CGFloat maximumTableOffset = _videoTableNode.view.contentSize.height - CGRectGetHeight(_videoTableNode.view.frame);
//    CGFloat currentTableOffset = _videoTableNode.view.contentOffset.y;
//    CGFloat percentageTableOffset = currentTableOffset / maximumTableOffset;

    //If scrolling down: Take the max of the two offsets since we want the animation to be reflected in the scroll view with a shorter offset
    //If scrolling up: Take the min
    
//    CGFloat overallOffset;
    
    //Check which container is being scrolled
//    if ([scrollView isKindOfClass:[self.restaurantCollectionNode.view class]]) {
//        if (percentageCollectionOffset < self.lastCollectionOffset) {
//            overallOffset = MIN(percentageTableOffset, percentageCollectionOffset);
//        }else{
//            overallOffset = MAX(percentageTableOffset, percentageCollectionOffset);
//        }
//        self.lastCollectionOffset = percentageCollectionOffset;
//    }else if ([scrollView isKindOfClass:[self.videoTableNode.view class]]){
//        if (percentageTableOffset < self.lastTableOffset) {
//            overallOffset = MIN(percentageTableOffset, percentageCollectionOffset);
//        }else{
//            overallOffset = MAX(percentageTableOffset, percentageCollectionOffset);
//        }
//        self.lastTableOffset = percentageTableOffset;
//    }
    
    //Set maximum + minimum pointsand thresholds to animate so we don't perform uneccssary animations even though user has scroll past a certain point
    //Since we always keep both collection and table frames longer than the actual view, we just need to animate their positions.
    if(percentageCollectionOffset > 0.2 && !self.scrollViewFullscreen){
        
        CGRect collectionFrame = self.restaurantCollectionNode.view.frame;
        CGRect tableFrame = self.videoTableNode.view.frame;
        
        collectionFrame.size.height = self.view.bounds.size.height - CGRectGetHeight(self.segmentedControl.frame);
        tableFrame.size.height = self.view.bounds.size.height - CGRectGetHeight(self.segmentedControl.frame);
        
        self.restaurantCollectionNode.frame = collectionFrame;
        self.videoTableNode.frame = tableFrame;
        
        //Start pushing segmented control up
        [UIView animateWithDuration:0.25 animations:^{
            CGRect segmentFrame = self.segmentedControl.frame;
            CGRect collectionFrame = self.restaurantCollectionNode.view.frame;
            CGRect tableFrame = self.videoTableNode.view.frame;
            
            segmentFrame.origin.y = self.view.bounds.origin.y + CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([[UIApplication sharedApplication]statusBarFrame]);
            collectionFrame.origin.y = CGRectGetMaxY(segmentFrame);
            tableFrame.origin.y = CGRectGetMaxY(segmentFrame);
            
            self.segmentedControl.frame = segmentFrame;
            self.restaurantCollectionNode.frame = collectionFrame;
            self.videoTableNode.frame = tableFrame;
        }completion:^(BOOL finished) {
            self.scrollViewFullscreen = YES;
        }];
    }else if(percentageCollectionOffset < 0.2 && self.scrollViewFullscreen){
        //Start pulling view back down
        [UIView animateWithDuration:0.25 animations:^{
            CGRect segmentFrame = self.segmentedControl.frame;
            CGRect collectionFrame = self.restaurantCollectionNode.view.frame;
            CGRect tableFrame = self.videoTableNode.view.frame;
            
            segmentFrame.origin.y = CGRectGetMaxY(self.locationLabel.frame) + self.view.bounds.size.height * 0.01;
            collectionFrame.origin.y = CGRectGetMaxY(segmentFrame);
            tableFrame.origin.y = CGRectGetMaxY(segmentFrame);
            
            self.segmentedControl.frame = segmentFrame;
            self.restaurantCollectionNode.frame = collectionFrame;
            self.videoTableNode.frame = tableFrame;
        }completion:^(BOOL finished) {
            self.scrollViewFullscreen = NO;
            
            if (finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    CGRect collectionFrame = self.restaurantCollectionNode.view.frame;
                    CGRect tableFrame = self.videoTableNode.view.frame;
                    
                    collectionFrame.size.height = self.view.bounds.size.height - CGRectGetMaxY(self.segmentedControl.frame);
                    tableFrame.size.height = self.view.bounds.size.height - CGRectGetMaxY(self.segmentedControl.frame);
                    
                    self.restaurantCollectionNode.frame = collectionFrame;
                    self.videoTableNode.frame = tableFrame;
                }];
            }
        }];
    }
    
    //ensure that the end of scroll is fired.
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSArray *visibleNodes = [self.restaurantCollectionNode indexPathsForVisibleItems];

    for (NSIndexPath *index in visibleNodes) {
        DiscoverNode *node = [self.restaurantCollectionNode nodeForItemAtIndexPath:index];
        UICollectionViewLayoutAttributes *vidCellAttribute = [self.restaurantCollectionNode.view layoutAttributesForItemAtIndexPath:index];
        BOOL completelyVisible = CGRectContainsRect(self.restaurantCollectionNode.view.bounds, vidCellAttribute.frame);
        if (completelyVisible) {
            [node.playerNode play];
        }
    }
}

@end
