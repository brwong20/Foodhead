//
//  TPLRestaurantPageViewController.m
//  FoodWise
//
//  Created by Brian Wong on 1/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLRestaurantPageViewController.h"
#import "FoodWiseDefines.h"

#import "RestaurantPageNavBarView.h"
#import "ImageCollectionCell.h"
#import "TabledCollectionCell.h"
#import "MetricsDisplayCell.h"
#import "RestaurantAlbumViewController.h"
#import "RestaurantInfoTableViewCell.h"
#import "GeneralRestaurantInfoView.h"
#import "HoursTableViewCell.h"
#import "CameraViewController.h"
#import "TPLRestaurantPageViewModel.h"
#import "TPLDetailedRestaurant.h"
#import "RestaurantDetailsTableViewCell.h"
#import "MenuTableViewCell.h"
#import "UIFont+Extension.h"
#import "LocationManager.h"
#import "MenuViewController.h"
#import "LayoutBounds.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface TPLRestaurantPageViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RestaurantInfoCellDelegate>

//UI
@property (nonatomic, strong) UITableView *detailsTableView;
@property (nonatomic, strong) UIButton *submitButton;

//Photos
@property (nonatomic, strong) UICollectionView *photoCollection;

//Data source
@property (nonatomic, strong) NSMutableArray *restaurantPhotos;

//View Model
@property (nonatomic, strong) TPLRestaurantPageViewModel *pageViewModel;
@property (nonatomic, assign) BOOL detailsFetched;

@end

static NSString *cellId = @"detailCell";
static NSString *photoCellId = @"photoCell";

#define COLLECTION_PADDING 4.0

@implementation TPLRestaurantPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.detailsFetched = NO;
    
    [self setupNavBar];
    [self setupUI];
    
    self.restaurantPhotos = [NSMutableArray array];
    self.pageViewModel = [[TPLRestaurantPageViewModel alloc]init];
    [self loadRestaurantDetails];
    [self loadRestaurantReviews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)loadRestaurantDetails{
    NSString *restId = self.selectedRestaurant.foursqId;
    [self.pageViewModel retrieveRestaurantDetailsFor:restId  atLocation:self.currentLocation completionHandler:^(id data) {
        NSLog(@"%@", data);
        
        NSDictionary *result = data[@"result"];

        NSError *err;
        TPLDetailedRestaurant *detailedRestaurant;
        if (result) {
            detailedRestaurant = [MTLJSONAdapter modelOfClass:[TPLDetailedRestaurant class] fromJSONDictionary:result error:&err];
        }else{
            detailedRestaurant = [MTLJSONAdapter modelOfClass:[TPLDetailedRestaurant class] fromJSONDictionary:data error:&err];//Cached data returned by itself w/o 'result' key
        }
        //NSLog(@"%@", err.description);
        [self.selectedRestaurant mergeValuesForKeysFromModel:detailedRestaurant];
        self.restaurantPhotos = [self.selectedRestaurant.images mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.detailsFetched = YES;
            [self.detailsTableView reloadData];
            //[LayoutBounds drawBoundsForAllLayers:self.view];
        });
    } failureHandler:^(id error) {
        
    }];
}

- (void)loadRestaurantReviews{
    [self.pageViewModel getReviewsForRestaurant:[self.selectedRestaurant.restaurantId stringValue] completionHandler:^(id completionHandler) {
        
    } failureHandler:^(id failureHandler) {
        
    }];
}

- (void)setupNavBar{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIImage *backBtn = [[UIImage imageNamed:@"arrow_back"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationController.navigationBar.backIndicatorImage = backBtn;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backBtn;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"call_btn"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(callRestaurant)];
    
}
    
#pragma mark - Helper Methods

- (void)setupUI{

    self.detailsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.detailsTableView.delegate = self;
    self.detailsTableView.dataSource = self;
    self.detailsTableView.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.detailsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.detailsTableView];
/*
    self.submitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.82, self.view.frame.size.height * 0.8, self.view.frame.size.width * 0.13, self.view.frame.size.width * 0.13)];
    self.submitButton.backgroundColor = [UIColor purpleColor];
    self.submitButton.layer.cornerRadius = 15.0;
    [self.submitButton setTitle:@"+" forState:UIControlStateNormal];
    [self.submitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    [self.submitButton addTarget:self action:@selector(submitReview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
 */
}

#pragma mark - Helper Methods

- (void)viewRestaurantPhotos{
    RestaurantAlbumViewController *albumVC = [[RestaurantAlbumViewController alloc]init];
    [self.navigationController pushViewController:albumVC animated:YES];
}

- (void)setupPhotoCollection{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 1.0;
    flowLayout.minimumLineSpacing = 2.0;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width/3, self.view.frame.size.width/3);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.photoCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ((self.view.frame.size.width/3) * 2) + COLLECTION_PADDING/2) collectionViewLayout:flowLayout];
    self.photoCollection.backgroundColor = [UIColor whiteColor];
    self.photoCollection.delegate = self;
    self.photoCollection.dataSource= self;
    self.photoCollection.scrollEnabled = NO;
    [self.photoCollection registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:photoCellId];
}

- (UIView *)createAllButton{
    UIView *allButton = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/3, 30.0)];
    allButton.backgroundColor = [UIColor blackColor];
    
    UILabel *allLabel = [[UILabel alloc]initWithFrame:CGRectMake(5.0, 0, allButton.frame.size.width * 0.4, allButton.frame.size.height)];
    allLabel.text = @"See all";
    allLabel.textColor = [UIColor whiteColor];
    allLabel.backgroundColor = [UIColor clearColor];
    allLabel.font = [UIFont nun_fontWithSize:17.0];
    [allButton addSubview:allLabel];
    
    return allButton;
}

- (void)submitReview{
    CameraViewController *cameraVC = [[CameraViewController alloc]init];
    [self.navigationController pushViewController:cameraVC animated:YES];
}

#pragma mark - Call Restaurant

- (void)callRestaurant{
    if (self.selectedRestaurant.phoneNumber) {
        NSString *formattedNumber = [self.selectedRestaurant.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:formattedNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber] options:@{} completionHandler:nil];
    }
}

#pragma mark - Map Restaurant

- (void)presentNavigationAlert
{
    CLLocationCoordinate2D restaurantCoordinate = CLLocationCoordinate2DMake([self.selectedRestaurant.latitude floatValue], [self.selectedRestaurant.longitude floatValue]);
    
    UIAlertController *navAlert = [UIAlertController alertControllerWithTitle:@"Open with" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *appleMaps = [UIAlertAction actionWithTitle:@"Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MKPlacemark *placeMark = [[MKPlacemark alloc]initWithCoordinate:restaurantCoordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placeMark];
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        mapItem.name = self.selectedRestaurant.name;
        [mapItem openInMapsWithLaunchOptions:launchOptions];
        
    }];
    
    UIAlertAction *googleMaps = [UIAlertAction actionWithTitle:@"Google Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]];
        
        NSString *destinationLat = [NSString stringWithFormat:@"%f", restaurantCoordinate.latitude];
        NSString *destinationLng = [NSString stringWithFormat:@"%f", restaurantCoordinate.longitude];
        
        CLLocationCoordinate2D currentLocation = [LocationManager sharedLocationInstance].currentLocation;
        NSString *currentLat = [NSString stringWithFormat:@"%f", currentLocation.latitude];
        NSString *currentLng = [NSString stringWithFormat:@"%f", currentLocation.longitude];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@,%@&daddr=%@,%@&directionsmode=driving&views=", currentLat, currentLng, destinationLat, destinationLng]]options:@{} completionHandler:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [navAlert addAction:appleMaps];
    [navAlert addAction:googleMaps];
    [navAlert addAction:cancel];
    
    [self presentViewController:navAlert animated:YES completion:nil];
}

#pragma mark - RestaurantInfoCell Delegate

- (void)didTapLocation{
    [self presentNavigationAlert];
}

- (void)didTapShareButton{
    
}

#pragma mark - UTableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:{
            RestaurantDetailsTableViewCell *detail = [[RestaurantDetailsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [detail setInfoForRestaurant:self.selectedRestaurant];
            cell = detail;
            break;
        }
        case 1:{
            MetricsDisplayCell *metricsCell = [[MetricsDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell = metricsCell;
            //cell.layoutMargins = UIEdgeInsetsZero;
            break;
        }
        case 2:{
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.backgroundColor = [UIColor clearColor];
            [self setupPhotoCollection];
            [cell.contentView addSubview:self.photoCollection];
            break;
        }
        case 3:{
            MenuTableViewCell *menuCell = [[MenuTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            if (self.selectedRestaurant.menu) {
                menuCell.menuLabel.text = @"Menu";
                [menuCell.arrowImg setHidden:NO];
            }else{
                if (self.detailsFetched) {
                    menuCell.menuLabel.text = @"Menu unavailable";
                    [menuCell.arrowImg setHidden:YES];
                }else{
                    menuCell.menuLabel.text = @"";
                    [menuCell.arrowImg setHidden:YES];
                }
            }
            cell = menuCell;
            break;
        }
        case 4:{
            RestaurantInfoTableViewCell *infoCell = [[RestaurantInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            infoCell.delegate = self;
            [infoCell populateInfo:self.selectedRestaurant];
            cell = infoCell;
            break;
        }
        case 5:{
            HoursTableViewCell *hoursCell = [[HoursTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [hoursCell populateHours:self.selectedRestaurant];
            cell = hoursCell;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return RESTAURANT_PAGE_CELL_COUNT;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0.0;
    switch (indexPath.row) {
        case 0:{
//            CGSize maxCellSize = CGSizeMake(APPLICATION_FRAME.size.width * 0.7, INT_MAX);//Setting the appropriate width is a MUST here!!
//            CGRect nameSize = [self.selectedRestaurant.name boundingRectWithSize:maxCellSize
//                                                                         options:NSStringDrawingUsesLineFragmentOrigin
//                                                                      attributes:@{NSFontAttributeName:[UIFont nun_fontWithSize:22.0]} context:nil];
//            
//            //Account for other elements (hours, categories, etc)
//            cellHeight = APPLICATION_FRAME.size.height * 0.1 + nameSize.size.height;
//            
//            //Only if the cellHeight is larger than our default do we expand the cell size
//            if (cellHeight <= RESTAURANT_INFO_CELL_HEIGHT) {
//                cellHeight = RESTAURANT_INFO_CELL_HEIGHT;
//            }
//            
            cellHeight = RESTAURANT_INFO_CELL_HEIGHT;
            break;
        }
        case 1:
            cellHeight = METRIC_CELL_HEIGHT;
            break;
        case 2:
            cellHeight = ((self.view.frame.size.width/3) * 2) + COLLECTION_PADDING;
            break;
        case 3:
            cellHeight = METRIC_CELL_HEIGHT;
            break;
        case 4:
            cellHeight = RESTAURANT_LOCATION_CELL_HEIGHT;
            break;
        case 5:{
            if (self.selectedRestaurant.hours) {
                if ((self.selectedRestaurant.hours.count - 1) == 1 || self.selectedRestaurant.hours.count == 0) {
                    cellHeight = RESTAURANT_HOURS_CELL_HEIGHT;//Only one line needed, use default
                }else{
                    cellHeight = RESTAURANT_HOURS_CELL_HEIGHT * (self.selectedRestaurant.hours.count * HOUR_CELL_SPACING); //Dynamically size hours cell based on number of days
                }
            }else{
                cellHeight = RESTAURANT_HOURS_CELL_HEIGHT;//Before we load detail data or no hours
            }
            break;
        }
        default:
            break;
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:{
            if (self.selectedRestaurant.menu) {
                MenuViewController *menuVC = [[MenuViewController alloc]init];
                menuVC.menuLink = self.selectedRestaurant.menu;
                [self.navigationController pushViewController:menuVC animated:YES];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //Make sure to register the cell type you want to use in the TabledCollectionCell subclass!
    ImageCollectionCell *collectionCell = (ImageCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:photoCellId forIndexPath:indexPath];
    collectionCell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.row == 5) {
        [collectionCell.contentView insertSubview:[self createAllButton] aboveSubview:collectionCell.coverImageView];
    }
    
    //Get section instead and check if a dict exists
    if (self.restaurantPhotos.count > 0) {
        NSDictionary *imgInfo = self.restaurantPhotos[indexPath.row];
        NSString *imgURL = imgInfo[@"url"];
        [collectionCell.coverImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage new] options:SDWebImageHighPriority completed:nil];
    }
    return collectionCell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.restaurantPhotos.count >= 6) {
        return 6;
    }
    return self.restaurantPhotos.count;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 5) {
        RestaurantAlbumViewController *albumVC = [[RestaurantAlbumViewController alloc]init];
        albumVC.images = self.selectedRestaurant.images;
        [self.navigationController pushViewController:albumVC animated:YES];
    }
}

@end
