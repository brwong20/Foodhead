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
#import "LocationPermissionView.h"
#import "FoodWiseDefines.h"
#import "TabledCollectionManager.h"
#import "TPLRestaurant.h"
#import "UserAuthManager.h"
#import "TPLRestaurantPageViewController.h"
#import "CameraViewController.h"
#import "TPLChartsViewModel.h"
#import "TPLExpandedChartController.h"
#import "AppDelegate.h"
#import "User.h"
#import "UIFont+Extension.h"
#import "RestaurantReview.h"
#import "TabCameraViewController.h"

@interface ChartsViewController () <LocationManagerDelegate, TabledCollectionDelegate>

//Authentication
@property (nonatomic, strong) UserAuthManager *authManager;

//Navigation
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *searchButton;

//Location
@property (nonatomic, strong) LocationManager *locationManager;

//Charts UI
@property (nonatomic, strong) UITableView *tableView;

//Tabled Collection Manager - Manages all delegate/datasources for our custom charts controller as well as populating data with TPLChartsViewModel
@property (nonatomic, strong) TabledCollectionManager *tableCollectionMngr;

//Pull to refresh
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ChartsViewController

static NSString *cellId = @"tabledCollectionCell";

#pragma mark - View Lifecyclle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavBar];
    [self setupUI];
    [self verifyCurrentUser];
    
    self.locationManager = [LocationManager sharedLocationInstance];
    self.locationManager.locationDelegate = self;
    [self.locationManager checkLocationAuthorization];
    //Need NSUSERDEFAULT to check for this - this accounts for when user sees this screen for first time and still disables - use alert view every time after
    //    LocationPermissionView *locationView = [[LocationPermissionView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //    [self.view addSubview:locationView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.delegate = self;//Must reset delegate
    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark - Helper Methods

- (void)setupNavBar{
    //This back button must be configured in parent view controller so all pushed VCs reflec this change. The back image is set in its respective VC, but this is just to get rid of the "Back" button title.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.topItem.title = @"foodhead";
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont nun_boldFontWithSize:24.0], NSForegroundColorAttributeName : [UIColor blackColor]};
    //self.navigationController.hidesBarsOnSwipe = YES;
}

- (void)setupUI{
    self.view.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    //Change this init method
    self.tableCollectionMngr = [[TabledCollectionManager alloc] initWithTableView:self.tableView cellIdentifier:cellId];
    self.tableView.delegate = self.tableCollectionMngr;
    self.tableView.dataSource = self.tableCollectionMngr;
    self.tableCollectionMngr.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
}

//- (void)openCamera
//{
//    CameraViewController *camVC = [[CameraViewController alloc]init];
//    RestaurantReview *newReview = [[RestaurantReview alloc]init];
//    newReview.reviewLocation = [self.locationManager getCurrentLocation];
//    camVC.currentReview = newReview;
//    [self.navigationController pushViewController:camVC animated:NO ];
//}

#pragma mark - User Session

//Redirect and logout if credential aren't the same as last logged in user or expired auth

- (void)verifyCurrentUser{
    self.authManager = [UserAuthManager sharedInstance];
    [self.authManager retrieveCurrentUser:^(id user) {
        NSString *lastUserId = [[NSUserDefaults standardUserDefaults]objectForKey:LAST_USER_DEFAULT];
        User *currentUser = (User *)user;
        
        //Extra check to see if this was the last logged in user 
        if ([[currentUser.userId stringValue]isEqualToString:lastUserId] ) {
            NSLog(@"SAME USER DO NOTHING!");
        }else{
            UIAlertController *invalidUserAlert = [UIAlertController alertControllerWithTitle:@"Invalid Login" message:@"There was a problem verifying who you are. Please try logging in again!" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:invalidUserAlert animated:YES completion:^{
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                [appDelegate changeRootViewControllerFor:RootViewTypeLogin];
            }];
        }
    } failureHandler:^(id error) {
        NSLog(@"Couldn't retrieve current user info. Should logout!");
    }];
}

#pragma mark - TabledCollectionDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectTabledCollectionCellAtIndexPath:(NSIndexPath *)indexPath withItem:(TPLRestaurant *)item{
    TPLRestaurantPageViewController *restPageVC = [[TPLRestaurantPageViewController alloc]init];
    restPageVC.selectedRestaurant = item;
    restPageVC.currentLocation = [self.locationManager getCurrentLocation];
    [self.navigationController pushViewController:restPageVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectSectionWithChart:(NSDictionary *)chartInfo{
    TPLExpandedChartController *chartVC = [[TPLExpandedChartController alloc]init];
    chartVC.chartInfo = chartInfo;
    [self.navigationController pushViewController:chartVC animated:YES];
}

#pragma mark - LocationManager delegate methods
- (void)didGetCurrentLocation:(CLLocationCoordinate2D)coordinate{
    [self.tableCollectionMngr getChartsAtLocation:coordinate];
}

#pragma mark - UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    UINavigationController *nav = (UINavigationController *)viewController;
    UIViewController *root = [[nav viewControllers]firstObject];
    
    if ([root isKindOfClass:[TabCameraViewController class]]) {
        TabCameraViewController *camVC = (TabCameraViewController *) root;
        camVC.tabBarController.delegate = camVC;//Always keep delegate in appropriate VC.
    }
    else if ([root isKindOfClass:[ChartsViewController class]]){
        [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];//Scroll to top only if tableview is visible
    }
}

//- (void)locationPermissionDenied{
//    UIAlertController *locationController = [UIAlertController alertControllerWithTitle:@"Enable Location" message:@"We're going to need your location to recommend you the best spots! Enable location services in your settings." preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *settingsButton = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
//    }];
//    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//
//    [locationController addAction:settingsButton];
//    [locationController addAction:cancelButton];
//
//    [self presentViewController:locationController animated:YES completion:nil];
//}

@end
