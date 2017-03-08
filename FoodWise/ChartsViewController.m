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
#import "TPLCameraViewController.h"
#import "CameraViewController.h"
#import "TPLChartsViewModel.h"
#import "TPLExpandedChartController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "User.h"

@interface ChartsViewController () <LocationManagerDelegate, TabledCollectionDelegate, SWRevealViewControllerDelegate>

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

@end

@implementation ChartsViewController

static NSString *cellId = @"tabledCollectionCell";

#pragma mark - View Lifecyclle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //This back button must be configured in parent view controller so all pushed VCs reflec this change. The back image is set in its respective VC, but this is just to get rid of the "Back" button title.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    [self setupUI];
    [self verifyCurrentUser];
    
    self.locationManager = [LocationManager sharedLocationInstance];
    self.locationManager.locationDelegate = self;
    
    //Only call if we aren't authorized
    //[self.locationManager requestLocationAuthorization];//Should be db call instead
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //Need NSUSERDEFAULT to check for this - also account for when user already sees this screen and still disables - use alert view
    //    LocationPermissionView *locationView = [[LocationPermissionView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //    [self.view addSubview:locationView];
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark - Helper Methods

- (void)setupUI{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    //Change this init method
    self.tableCollectionMngr = [[TabledCollectionManager alloc] initWithTableView:self.tableView cellIdentifier:cellId];
    self.tableView.delegate = self.tableCollectionMngr;
    self.tableView.dataSource = self.tableCollectionMngr;
    self.tableCollectionMngr.delegate = self;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    self.cameraButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.9 - self.view.frame.size.width * 0.05, self.view.frame.size.height * 0.93 - self.view.frame.size.width * 0.05, self.view.frame.size.width * 0.1, self.view.frame.size.width * 0.1)];
    self.cameraButton.backgroundColor = [UIColor cyanColor];
    [self.cameraButton setTitle:@"+" forState:UIControlStateNormal];
    [self.cameraButton.titleLabel setFont:[UIFont boldSystemFontOfSize:19.0]];
    [self.cameraButton addTarget:self action:@selector(openCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cameraButton];
    
    //Configure SWReveal behavior
    SWRevealViewController *revealVC = [self revealViewController];
    [self.view addGestureRecognizer:revealVC.panGestureRecognizer];
    revealVC.delegate = self;
    [self.view addGestureRecognizer:revealVC.tapGestureRecognizer];
    
    self.searchButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.1 - self.view.frame.size.width * 0.05, self.view.frame.size.height * 0.93 - self.view.frame.size.width * 0.05,  self.view.frame.size.width * 0.1,  self.view.frame.size.width * 0.1)];
    [self.searchButton setBackgroundColor:[UIColor redColor]];
    [self.searchButton addTarget:revealVC action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.searchButton];
    
    //Retrieves only the titles, then gets data right after if location is authorized. This makes the app seem faster
}

- (void)openCamera
{
    CameraViewController *camVC = [[CameraViewController alloc]init];
    [self.navigationController pushViewController:camVC animated:YES];
}

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
    //Pass coord to VM
    //[self.tableCollectionMngr getRestaurants];
    [self.tableCollectionMngr getChartsAtLocation:coordinate];
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

#pragma mark - SWRevealControllerDelegate methods

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position{
    if (position == FrontViewPositionRight) {
        self.tableView.userInteractionEnabled = NO;
    }else if(position == FrontViewPositionLeft){
        self.tableView.userInteractionEnabled = YES;
    }
}
@end
