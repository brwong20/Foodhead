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

#import <SDWebImage/UIImageView+WebCache.h>

@interface TPLRestaurantPageViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

//UI
@property (nonatomic, strong) UITableView *detailsTableView;
@property (nonatomic, strong) UIButton *submitButton;

//Photos
@property (nonatomic, strong) UICollectionView *photoCollection;

//Data source
@property (nonatomic, strong) NSMutableArray *restaurantPhotos;

//View Model
@property (nonatomic, strong) TPLRestaurantPageViewModel *pageViewModel;

@end

static NSString *cellId = @"detailCell";
static NSString *photoCellId = @"photoCell";

@implementation TPLRestaurantPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.restaurantPhotos = [NSMutableArray array];
    
    self.pageViewModel = [[TPLRestaurantPageViewModel alloc]init];
    [self loadRestaurantDetails];
    [self loadRestaurantReviews];
    [self setupNavBar];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //[self setupCustomNavBar];
    
    //[self getFSQRestuarantInfo:self.selectedRestaurant.venue_id];
}

//- (BOOL)prefersStatusBarHidden{
//    return YES;
//}

- (void)loadRestaurantDetails{
    NSString *restId = self.selectedRestaurant.foursqId;
    [self.pageViewModel retrieveRestaurantDetailsFor:restId  atLocation:self.currentLocation completionHandler:^(id data) {
        NSLog(@"%@", data);
        NSDictionary *result = data[@"result"];
        TPLDetailedRestaurant *detailedRestaurant = [MTLJSONAdapter modelOfClass:[TPLDetailedRestaurant class] fromJSONDictionary:result error:nil];
        [self.selectedRestaurant mergeValuesForKeysFromModel:detailedRestaurant];
        NSArray *imgs = result[@"instagram_images"];
        
        if (imgs.count < 5) {
            imgs = result[@"images"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.restaurantPhotos = [[self.restaurantPhotos arrayByAddingObjectsFromArray:imgs]mutableCopy];
            [self.detailsTableView reloadData];
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
    self.title = @"";
    
    UIImage *backBtn = [UIImage imageNamed:@"exit"];
    backBtn = [backBtn imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationController.navigationBar.backIndicatorImage = backBtn;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backBtn;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    //self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];//Hide pushed VC back button title
    
//    RestaurantPageNavBarView *navBar = [[RestaurantPageNavBarView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 32)];
//    navBar.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.titleView = navBar;
    
}
    
#pragma mark - Helper Methods

- (void)setupUI{
    CGSize frameSize = self.view.frame.size;
    self.detailsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height) style:UITableViewStylePlain];
    self.detailsTableView.delegate = self;
    self.detailsTableView.dataSource = self;
    self.detailsTableView.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.detailsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.detailsTableView];
    
    self.submitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.82, self.view.frame.size.height * 0.8, self.view.frame.size.width * 0.13, self.view.frame.size.width * 0.13)];
    self.submitButton.backgroundColor = [UIColor purpleColor];
    self.submitButton.layer.cornerRadius = 15.0;
    [self.submitButton setTitle:@"+" forState:UIControlStateNormal];
    [self.submitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    [self.submitButton addTarget:self action:@selector(submitReview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
}

#pragma mark - Helper Methods

- (void)viewRestaurantPhotos{
    RestaurantAlbumViewController *albumVC = [[RestaurantAlbumViewController alloc]init];
    [self.navigationController pushViewController:albumVC animated:YES];
}

- (void)setupPhotoCollection{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 0.0;
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.photoCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, RESTAURANT_PHOTO_COLLECTION_HEIGHT) collectionViewLayout:flowLayout];
    self.photoCollection.delegate = self;
    self.photoCollection.dataSource= self;
    self.photoCollection.scrollEnabled = YES;
    [self.photoCollection registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:photoCellId];
}

- (UIView *)createAllButton{
    UIView *allButton = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.25, RESTAURANT_PHOTO_COLLECTION_HEIGHT/5)];
    allButton.backgroundColor = [UIColor blackColor];
    
    UILabel *allLabel = [[UILabel alloc]initWithFrame:CGRectMake(5.0, 0, allButton.frame.size.width * 0.4, allButton.frame.size.height)];
    allLabel.text = @"All";
    allLabel.textColor = [UIColor whiteColor];
    allLabel.backgroundColor = [UIColor clearColor];
    allLabel.font = [UIFont systemFontOfSize:17.0];
    [allButton addSubview:allLabel];
    
    return allButton;
}

- (void)submitReview{
    CameraViewController *cameraVC = [[CameraViewController alloc]init];
    [self.navigationController pushViewController:cameraVC animated:YES];
}

#pragma mark - UTableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:{
            GeneralRestaurantInfoView *generalView = [[GeneralRestaurantInfoView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.25)];
            generalView.restaurantName.text = self.selectedRestaurant.name;
            generalView.distanceLabel.text = [self.selectedRestaurant.distance stringValue];
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell.contentView addSubview:generalView];
            break;
        }
        case 1:{
            MetricsDisplayCell *metricsCell = [[MetricsDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            //metricsCell.numReviews = @(self.selectedRestaurant.foursq_rating);
            cell = metricsCell;
            break;
        }
        case 2:{
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.backgroundColor = [UIColor grayColor];
            
            [self setupPhotoCollection];
            [cell.contentView addSubview:self.photoCollection];
            break;
        }
        case 3:{
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.backgroundColor = APPLICATION_BACKGROUND_COLOR;
            //Custom disclosure cell.accessoryView =
            cell.textLabel.text = @"Menu";
            break;
        }
        case 4:{
            RestaurantInfoTableViewCell *infoCell = [[RestaurantInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            infoCell.restaurantName.text = self.selectedRestaurant.name;
            infoCell.addressLabel.text = self.selectedRestaurant.address;
            cell = infoCell;
            break;
        }
        case 5:{
            HoursTableViewCell *hoursCell = [[HoursTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
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
        case 0:
            cellHeight = self.view.frame.size.height * 0.25;
            break;
        case 1:
            cellHeight = METRIC_CELL_HEIGHT;
            break;
        case 2:
            cellHeight = RESTAURANT_PHOTO_COLLECTION_HEIGHT;
            break;
        case 3:
            cellHeight = METRIC_CELL_HEIGHT;
            break;
        case 4:
            cellHeight = RESTAURANT_INFO_CELL_HEIGHT;
            break;
        case 5:
            //Multiply by how many days there are
            cellHeight = RESTAURANT_HOURS_CELL_HEIGHT;
            break;
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
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //Make sure to register the cell type you want to use in the TabledCollectionCell subclass!
    ImageCollectionCell *collectionCell = (ImageCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:photoCellId forIndexPath:indexPath];
    collectionCell.coverImageView.image = [UIImage imageNamed:@"AppIcon"];
    if(indexPath.row == 0){
        collectionCell.backgroundColor = [UIColor greenColor];
    }else if(indexPath.row == 4){
        [collectionCell.contentView addSubview:[self createAllButton]];
        collectionCell.backgroundColor = [UIColor grayColor];
    }else{
        collectionCell.backgroundColor = [UIColor redColor];
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
    return 5;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //Pass data (whatevers in cell) along with this as well
    if (indexPath.row == 4) {
        RestaurantAlbumViewController *albumVC = [[RestaurantAlbumViewController alloc]init];
        [self.navigationController pushViewController:albumVC animated:YES];
    }
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return CGSizeMake(self.view.frame.size.width/2, RESTAURANT_PHOTO_COLLECTION_HEIGHT);
    }
    return CGSizeMake(self.view.frame.size.width * 0.25, RESTAURANT_PHOTO_COLLECTION_HEIGHT/2);
}

#pragma mark - View Model

//RACObserve and retrieve data to update mantle object

- (void)bindViewModel{
    
    
    
}

@end
