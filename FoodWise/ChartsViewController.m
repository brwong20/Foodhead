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
#import "TPLChartsDataSource.h"
#import "TPLRestaurant.h"
#import "UserAuthManager.h"
#import "TPLRestaurantPageViewController.h"
#import "TPLCameraViewController.h"
#import "NSString+Trim.h"
#import "TPLChartsViewModel.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ChartsViewController () <LocationManagerDelegate, TabledCollectionDelegate>

//Location
@property (nonatomic, strong) LocationManager *locationManager;

//Charts UI
@property (nonatomic, strong) UITableView *tableView;

//Charts Data
@property (nonatomic, strong) TabledCollectionManager *tableCollectionMngr;
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) NSMutableArray *categories;

@end

@implementation ChartsViewController

static NSString *cellId = @"tabledCollectionCell";

#define mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

#warning - Check for auth_token (user is logged in) - If not they skipped and should show login controller again somewhere else (when posting reviews)
    if([UserAuthManager isUserLoggedIn]){
        NSLog(@"LOGGED IN");
    }
    
    [self setupUI];
    
    self.locationManager = [LocationManager sharedLocationInstance];
    self.locationManager.locationDelegate = self; //Be careful with setting delegates since this is a singleton!
    [self.locationManager requestLocationAuthorization];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //LocationPermissionView *locView = [[LocationPermissionView alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - 100, self.view.frame.size.width * 0.5 -100, 200, 200)];
    //[self.view addSubview:locView];
}

#pragma mark - Helper Methods

- (void)setupUI{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    //Change this init method
    self.tableCollectionMngr = [[TabledCollectionManager alloc] initWithTableView:self.tableView cellIdentifier:cellId];
    self.tableView.delegate = self.tableCollectionMngr;
    self.tableView.dataSource = self.tableCollectionMngr;
    self.tableCollectionMngr.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *camButton = [[UIBarButtonItem alloc]initWithTitle:@"Camera" style:UIBarButtonItemStylePlain target:self action:@selector(openCamera)];
    self.navigationItem.rightBarButtonItem = camButton;
}

- (void)openCamera
{
    TPLCameraViewController *cam = [[TPLCameraViewController alloc]init];
    [self.navigationController pushViewController:cam animated:YES];
}

#pragma mark - TabledCollectionDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectTabledCollectionCellAtIndexPath:(NSIndexPath *)indexPath withItem:(TPLRestaurant *)item{
    TPLRestaurantPageViewController *restPageVC = [[TPLRestaurantPageViewController alloc]init];
    restPageVC.selectedRestaurant = item;
    [self.navigationController pushViewController:restPageVC animated:YES];
}

#pragma mark - LocationManager delegate methods
- (void)didGetCurrentLocation:(CLLocationCoordinate2D)coordinate{
    //Pass coord to VM
    self.tableCollectionMngr.currentLocation = coordinate;
    [self.tableCollectionMngr getRestaurants];
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
