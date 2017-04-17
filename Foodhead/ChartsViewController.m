//
//  ChartsViewController.m
//  FoodWise
//
//  Created by Brian Wong on 1/12/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//
#import "ChartsViewController.h"
#import "LoginViewController.h"
#import "LocationManager.h"
#import "FoodWiseDefines.h"
#import "TabledCollectionManager.h"
#import "TPLRestaurant.h"
#import "UserAuthManager.h"
#import "TPLRestaurantPageViewController.h"
#import "TPLChartsViewModel.h"
#import "TPLExpandedChartController.h"
#import "AppDelegate.h"
#import "User.h"
#import "UIFont+Extension.h"
#import "TabCameraViewController.h"
#import "Chart.h"
#import "UserFeedbackViewController.h"
#import "ServiceErrorView.h"
#import "FoodheadAnalytics.h"
#import "UserProfileViewController.h"
#import "LayoutBounds.h"


#import "NSString+IsEmpty.h"

@interface ChartsViewController () <LocationManagerDelegate, TabledCollectionDelegate, ServiceErrorViewDelegate>

//Authentication
@property (nonatomic, strong) UserAuthManager *authManager;

//Navigation
@property (nonatomic, strong) UIButton *cameraButton;

//Location
@property (nonatomic, strong) LocationManager *locationManager;

//Charts UI
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL canScrollToTop;

//Tabled Collection Manager - Manages all delegate/datasources for our custom charts controller as well as populating data with TPLChartsViewModel
@property (nonatomic, strong) TabledCollectionManager *tableCollectionMngr;

//Pull to refresh
@property (nonatomic, strong) UIRefreshControl *refreshControl;

//Service Error
@property (nonatomic, strong) ServiceErrorView *errorView;

@end

@implementation ChartsViewController

static NSString *cellId = @"tabledCollectionCell";

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tabBarController.delegate = self;
    
    [self setupNavBar];
    [self setupUI];
    [self verifyCurrentUser];
    
    self.locationManager = [LocationManager sharedLocationInstance];
    self.locationManager.locationDelegate = self;
    [self addObservers];

    if (self.locationManager.authorizedStatus == kCLAuthorizationStatusAuthorizedWhenInUse || self.locationManager.authorizedStatus == kCLAuthorizationStatusAuthorizedAlways){
        //Find a better way to only call this once
        [self.locationManager retrieveCurrentLocation];
    }else{
        self.errorView = [[ServiceErrorView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height) andErrorType:ServiceErrorTypeLocation];
        [self.view addSubview:self.errorView];
    }
}

- (void)addObservers{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkLocationPermissions) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc{
    [self removeObservers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.canScrollToTop = YES;
    [[[self navigationController] interactivePopGestureRecognizer] setEnabled:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.canScrollToTop = NO;
    [[[self navigationController] interactivePopGestureRecognizer] setEnabled:YES];
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark - Helper Methods

- (void)setupUI{
    self.view.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    UIEdgeInsets adjustForBarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views
    self.tableView.contentInset = adjustForBarInsets;
    self.tableView.scrollIndicatorInsets = adjustForBarInsets;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableCollectionMngr = [[TabledCollectionManager alloc] initWithTableView:self.tableView cellIdentifier:cellId];
    self.tableView.delegate = self.tableCollectionMngr;
    self.tableView.dataSource = self.tableCollectionMngr;
    self.tableCollectionMngr.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}


- (void)setupNavBar{
    //This back button must be configured in parent view controller so all pushed VCs reflec this change. The back image is set in its respective VC, but this is just to get rid of the "Back" button title.
    self.navigationController.navigationBar.barTintColor = APPLICATION_BACKGROUND_COLOR;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationController.navigationBar.topItem.title = @"Foodhead";
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont nun_boldFontWithSize:24.0], NSForegroundColorAttributeName : APPLICATION_BLUE_COLOR};
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"feedback"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(submitFeedback)];    
}

- (void)submitFeedback{
    UserFeedbackViewController *feedbackVC = [[UserFeedbackViewController alloc]init];
    [self.navigationController pushViewController:feedbackVC animated:YES];
}

- (void)checkLocationPermissions{
    [self.locationManager checkLocationAuthorization];
    if(self.locationManager.authorizedStatus == kCLAuthorizationStatusAuthorizedWhenInUse || self.locationManager.authorizedStatus == kCLAuthorizationStatusAuthorizedAlways)
    {//If user denies location at first, but allows and comes back into app
        if ([self.errorView superview] && self.errorView.errorType == ServiceErrorTypeLocation){
            [self.errorView removeFromSuperview];
            [self.locationManager retrieveCurrentLocation];
        }
    }
    else
    {//If user goes to settings and denies location access
        if (![self.errorView superview]) {
            self.errorView = [[ServiceErrorView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height) andErrorType:ServiceErrorTypeLocation];
            [self.view addSubview:self.errorView];
        }
    }
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
            NSLog(@"Same user, do nothing.");
        }
    }failureHandler:^(id error) {
        //Anon login handle
    }];
}

#pragma mark - TabledCollectionDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectTabledCollectionCellAtIndexPath:(NSIndexPath *)indexPath withItem:(TPLRestaurant *)item{
    TPLRestaurantPageViewController *restPageVC = [[TPLRestaurantPageViewController alloc]init];
    restPageVC.selectedRestaurant = item;
    restPageVC.currentLocation = [LocationManager sharedLocationInstance].currentLocation;
    [FoodheadAnalytics logEvent:OPEN_RESTAURANT_PAGE];
    [self.navigationController pushViewController:restPageVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectSectionWithChart:(Chart *)chartInfo{
//    TPLExpandedChartController *chartVC = [[TPLExpandedChartController alloc]init];
//    chartVC.selectedChart = chartInfo;
//    chartVC.currentLocation = [[LocationManager sharedLocationInstance]currentLocation];
//    [FoodheadAnalytics logEvent:EXPANDED_CHART_PAGE withParameters:@{@"chartName" : chartInfo.name}];
//    [self.navigationController pushViewController:chartVC animated:YES];
}

#pragma mark - LocationManager delegate methods

- (void)didGetCurrentLocation:(CLLocationCoordinate2D)coordinate{
    [self.tableCollectionMngr getChartsAtLocation:coordinate];
}

#pragma mark - ServiceErrorViewDelegate methods

- (void)serviceErrorViewToggledRefresh{
    //Verify connection and update user info by verifying user - Could also just check for internet connection (should do this instead and put user logic into profile tab)
    [self verifyCurrentUser];
}

#pragma mark - UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
//    UINavigationController *nav = (UINavigationController *)viewController;
//    UIViewController *root = [[nav viewControllers]firstObject];
//    if ([root isKindOfClass:[TabCameraViewController class]]) {
//        TabCameraViewController *camVC = (TabCameraViewController *) root;
//        camVC.tabBarController.delegate = camVC;//Always keep delegate in appropriate VC.
//    }
    
    //Disable scroll to top if coming from a different page
    if (self.canScrollToTop) {
        [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];//Scroll to top only if tableview is visible
    }
    
    UINavigationController *nav = (UINavigationController *)viewController;
    UIViewController *root = [[nav viewControllers]firstObject];
    if ([root isKindOfClass:[UserProfileViewController class]]) {
        [FoodheadAnalytics logEvent:PROFILE_TAB_CLICK];
    }
}

@end
