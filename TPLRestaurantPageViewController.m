//
//  TPLRestaurantPageViewController.m
//  FoodWise
//
//  Created by Brian Wong on 1/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLRestaurantPageViewController.h"
#import "FoodWiseDefines.h"

#import "ImageCollectionCell.h"
#import "TabledCollectionCell.h"
#import "MetricsDisplayCell.h"
#import "RestaurantAlbumViewController.h"
#import "RestaurantInfoTableViewCell.h"
#import "HoursTableViewCell.h"
#import "TPLRestaurantPageViewModel.h"
#import "TPLDetailedRestaurant.h"
#import "RestaurantDetailsTableViewCell.h"
#import "MenuTableViewCell.h"
#import "UIFont+Extension.h"
#import "LocationManager.h"
#import "WebViewController.h"
#import "LayoutBounds.h"
#import "User.h"
#import "UserReview.h"
#import "ReviewMetricView.h"
#import "AttributionTableViewCell.h"
#import "FoodheadAnalytics.h"

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TPLRestaurantPageViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, RestaurantInfoCellDelegate, IDMPhotoBrowserDelegate, ImageCollectionCellDelegate>

//UI
@property (nonatomic, strong) UITableView *detailsTableView;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, assign) CGFloat dynamicHoursHeight;//For dynamic resizing of hours cell height

//Photos
@property (nonatomic, strong) UICollectionView *photoCollection;
@property (nonatomic, strong) NSString *nextPg;

//Data source
@property (nonatomic, strong) NSMutableArray *restaurantPhotos;
@property (nonatomic, strong) NSMutableArray *idmPhotos;
@property (nonatomic, strong) NSMutableArray *userReviews;

//View Model
@property (nonatomic, strong) TPLRestaurantPageViewModel *pageViewModel;
@property (nonatomic, assign) BOOL detailsFetched;

@end

static NSString *cellId = @"detailCell";
static NSString *photoCellId = @"photoCell";

#define NUM_COLUMNS 3
#define NUM_COLLECTION_CELLS 6

@implementation TPLRestaurantPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.restaurantPhotos = [NSMutableArray array];
    self.idmPhotos = [NSMutableArray array];
    self.userReviews = [NSMutableArray array];
    self.pageViewModel = [[TPLRestaurantPageViewModel alloc]init];
    self.detailsFetched = NO;
    
    [self loadRestaurantDetails];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNavBar];
    
    //We should only load images/metrics once in viewDidLoad. If details have already been fetched, this means the user either reopened the app or submitted a review while on the restaurant page.
    if (self.detailsFetched) {
        [self refreshMetrics];
        [self loadRestaurantImages];
    }
}

- (void)loadRestaurantDetails{
    [self.pageViewModel retrieveRestaurantDetailsFor:self.selectedRestaurant atLocation:self.currentLocation completionHandler:^(TPLRestaurant* fullRestaurant) {
        if (fullRestaurant) {
            self.detailsFetched = YES;
            self.selectedRestaurant = fullRestaurant;
            self.dynamicHoursHeight = [self calculateDynamicHoursHeight];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.detailsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],
                                                                [NSIndexPath indexPathForRow:3 inSection:0],
                                                                [NSIndexPath indexPathForRow:4 inSection:0],
                                                                [NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });

            //Must load reviews after we retrieve details because restaurant might not be cached in our db
            [self.pageViewModel retrieveReviewsForRestaurant:fullRestaurant completionHandler:^(id completionHandler) {
                [self.userReviews addObjectsFromArray:completionHandler];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.detailsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                });
                
            } failureHandler:^(id failureHandler) {
                NSLog(@"Failed to get user reviews");
            }];
        }
    } failureHandler:^(id error) {
        //TODO:: Handle this by changing rest page UI?
        NSLog(@"Couldn't get details");
    }];
    
    [self loadRestaurantImages];
}

- (void)refreshMetrics{
    [self.pageViewModel retrieveReviewsForRestaurant:self.selectedRestaurant completionHandler:^(id completionHandler) {
        NSArray *userReviews = completionHandler;

#warning Is this the best way to handle photos and review refreshing? Need to revisit this logic later on
        if (self.userReviews.count == userReviews.count) {
            //No need to refresh in number of reviews didn't change
            return;
        }
        [self.userReviews removeAllObjects];
        [self.userReviews addObjectsFromArray:completionHandler];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.detailsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });

    } failureHandler:^(id failureHandler) {
        NSLog(@"Failed to refresh metrics");
    }];
}

- (void)loadRestaurantImages{
    [self.pageViewModel retrieveImagesForRestaurant:self.selectedRestaurant
                                               page:nil
                                  completionHandler:^(id media) {
                                      self.nextPg = media[@"next_page"];
                                      NSArray *images = media[@"images"];
                                  
                                      if (self.restaurantPhotos.count < images.count) {
                                          [self.restaurantPhotos removeAllObjects];
                                          [self.idmPhotos removeAllObjects];
                                      }else{
                                          //Nothing changed don't reload
                                          return;
                                      }
                                      
                                      if (images) {
                                          for (NSDictionary *imgInfo in images) {
                                              BOOL isVideo = imgInfo[@"isVideo"];
                                              if (isVideo) {
                                                  continue;
                                              }
                                              
                                              if ([imgInfo[@"type"] isEqualToString:USER_REVIEW_PHOTO]) {
                                                  UserReview *review = [MTLJSONAdapter modelOfClass:[UserReview class] fromJSONDictionary:imgInfo error:nil];
                                                  User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:imgInfo error:nil];
                                                  [review mergeValuesForKeysFromModel:user];
                                                  [self.restaurantPhotos addObject:review];
                                              }else{
                                                  [self.restaurantPhotos addObject:imgInfo];
                                              }
                                          }
                                      }
                                      
                                      //For IDMPhotoBrowser
                                      for (id photoInfo in self.restaurantPhotos){
                                          IDMPhoto *photo;
                                          //Check if UserReview or insta img
                                          if ([photoInfo isKindOfClass:[UserReview class]]) {
                                              UserReview *userReview = (UserReview *)photoInfo;
                                              photo = [IDMPhoto photoWithURL:[NSURL URLWithString:userReview.imageURL]];
                                          }else{
                                              NSURL *photoURL = [[NSURL alloc]initWithString:photoInfo[@"url"]];
                                              photo = [IDMPhoto photoWithURL:photoURL];
                                          }
                                          [self.idmPhotos addObject:photo];
                                      }
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self.photoCollection reloadData];
                                      });
                                      
      } failureHandler:^(id failureHandler) {
          NSLog(@"%@", failureHandler);
      }];
}


- (void)setupNavBar{
    self.navigationItem.title = @"Foodhead";
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont nun_boldFontWithSize:24.0], NSForegroundColorAttributeName : APPLICATION_BLUE_COLOR};
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"arrow_back"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exitRestaurantPage)];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;//Preserves swipe back gesture
}

- (void)exitRestaurantPage{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper Methods

- (void)setupUI{
    self.view.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    
    self.detailsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.detailsTableView.delegate = self;
    self.detailsTableView.dataSource = self;
    self.detailsTableView.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.detailsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views
    self.detailsTableView.contentInset = adjustForTabbarInsets;
    self.detailsTableView.scrollIndicatorInsets = adjustForTabbarInsets;
    self.detailsTableView.rowHeight = UITableViewAutomaticDimension;
    self.detailsTableView.estimatedRowHeight = RESTAURANT_HOURS_CELL_HEIGHT;
    self.detailsTableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:self.detailsTableView];
}

- (void)setupPhotoCollection{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 1.0;
    flowLayout.minimumLineSpacing = 1.0;
    CGFloat itemWidth = (CGRectGetWidth(self.view.frame) - (NUM_COLUMNS - 1.0)) / NUM_COLUMNS;
    flowLayout.itemSize = CGSizeMake(itemWidth - 0.5, itemWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.photoCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.width/3) * 2) collectionViewLayout:flowLayout];
    self.photoCollection.backgroundColor = [UIColor whiteColor];
    self.photoCollection.delegate = self;
    self.photoCollection.dataSource= self;
    self.photoCollection.scrollEnabled = NO;
    [self.photoCollection registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:photoCellId];
}

//Calculates a dynamic height based on hours available then resizes the cell
- (CGFloat)calculateDynamicHoursHeight{
    CGFloat cellHeight = 0.0;
    if (self.selectedRestaurant.hours) {
        NSMutableArray *hoursOfWeek = [NSMutableArray array];
        //Filter out today's hours from hours cell
        for (NSDictionary *hrsForDay in self.selectedRestaurant.hours) {
            if ([hrsForDay objectForKey:@"Today"]) {
                continue;
            }
            [hoursOfWeek addObject:hrsForDay];
        }
        
        for (NSDictionary *hrs in hoursOfWeek) {
            NSArray *hoursAsStrs = [hrs allValues];
            for (NSString *hrStr in hoursAsStrs) {
                CGRect hrSize = [hrStr boundingRectWithSize:CGSizeMake(APPLICATION_FRAME.size.width * 0.4, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont nun_fontWithSize:RESTAURANT_HOURS_CELL_HEIGHT * 0.2]} context:nil];
                cellHeight += hrSize.size.height + RESTAURANT_HOURS_CELL_HEIGHT * 0.42;
            }
        }
    }

    //Keep a constant height as a minimum or when there are no hours
    if (cellHeight < RESTAURANT_HOURS_CELL_HEIGHT) {
        cellHeight = RESTAURANT_HOURS_CELL_HEIGHT + APPLICATION_FRAME.size.height * 0.02;
    }
    return cellHeight;
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

- (void)didTapRestaurantLink:(NSURL *)url{
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.webLink = url.absoluteString;
    [self.navigationController pushViewController:webVC animated:YES];
}

//- (void)didTapShareButton{
//    
//}

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
            if (self.detailsFetched) {
                [metricsCell populateMetrics:self.selectedRestaurant withUserReviews:self.userReviews];
            }
            cell = metricsCell;
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
            
            //Only show menu text after we know for sure if there is a menu (after we get details)
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
            hoursCell.dynamicHeight = self.dynamicHoursHeight;
            [hoursCell populateHours:self.selectedRestaurant];
            cell = hoursCell;
            break;
        }
        case 6:{
            AttributionTableViewCell *attributeCell = [[AttributionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell = attributeCell;
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
            cellHeight = RESTAURANT_INFO_CELL_HEIGHT;
            break;
        }
        case 1:
            cellHeight = METRIC_CELL_HEIGHT;
            break;
        case 2:{
            CGFloat itemWidth = (CGRectGetWidth(self.view.frame) - (NUM_COLUMNS - 1.0)) / NUM_COLUMNS;
            cellHeight = itemWidth * 2;
            break;
        }
        case 3:
            cellHeight = METRIC_CELL_HEIGHT;
            break;
        case 4:
            cellHeight = RESTAURANT_LOCATION_CELL_HEIGHT;
            break;
        case 5:{
            if (self.dynamicHoursHeight > 0.0) {
                cellHeight = self.dynamicHoursHeight;
            }else{
                cellHeight = RESTAURANT_HOURS_CELL_HEIGHT;
            }
            break;
        }
        case 6:
            cellHeight = ATTRIBUTION_CELL_HEIGHT;
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
        case 2:
            break;
        case 3:{
            if (self.selectedRestaurant.menu) {
                [FoodheadAnalytics logEvent:OPEN_RESTAURANT_MENU];
                WebViewController *menuVC = [[WebViewController alloc]init];
                menuVC.webLink = self.selectedRestaurant.menu;
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

    //If there are no photos load a placeholder
    BOOL photoExists = YES;
    if (indexPath.row + 1 > self.restaurantPhotos.count) {
        photoExists = NO;
    }
    
    if (self.restaurantPhotos.count > 0 && photoExists) {
        
        //Check if UserReview, insta img, foursquare, etc.
        id photo = self.restaurantPhotos[indexPath.row];
        NSURL *photoUrl;
        if ([photo isKindOfClass:[UserReview class]]) {
            UserReview *userReview = (UserReview *)photo;
            photoUrl = [NSURL URLWithString:userReview.thumbnailURL];
        }else{
            NSDictionary *imgInfo = photo;
            NSString *imgURL = imgInfo[@"url"];
            photoUrl = [NSURL URLWithString:imgURL];
        }
        
        if (indexPath.row == 5) {
            collectionCell.delegate = self;
            [collectionCell showSeeAllButton];
        }
        
        [collectionCell.coverImageView sd_setImageWithURL:photoUrl placeholderImage:[UIImage imageNamed:@"image_unavailable"] options:SDWebImageRetryFailed|SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (cacheType == SDImageCacheTypeNone) {
                collectionCell.coverImageView.alpha = 0.0;
                [UIView animateWithDuration:0.25 animations:^{
                    collectionCell.coverImageView.alpha = 1.0;
                }];
            }else{
                collectionCell.coverImageView.alpha = 1.0;
            }
        }];
    }else{
        [collectionCell.coverImageView setImage:[UIImage imageNamed:@"image_unavailable"]];
    }
    return collectionCell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return NUM_COLLECTION_CELLS;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //Don't allow user to enter browser through a cell which has no photo
    if (indexPath.row + 1 > self.idmPhotos.count) {
        return;
    }

    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc]initWithPhotos:self.idmPhotos];
    browser.delegate = self;
    browser.useWhiteBackgroundColor = YES;
    browser.displayDoneButton = NO;
    browser.dismissOnTouch = YES;
    browser.displayToolbar = NO;
    browser.autoHideInterface = NO;
    browser.forceHideStatusBar = YES;
    browser.usePopAnimation = YES;
    browser.disableVerticalSwipe = YES;
    browser.progressTintColor = APPLICATION_BLUE_COLOR;
    [browser setInitialPageIndex:indexPath.row];
    [browser trackPageCount];
    
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark ImageCollectionCellDelegate methods

- (void)didTapSeeAllButton{
    [FoodheadAnalytics logEvent:OPEN_RESTAURANT_ALBUM];
    RestaurantAlbumViewController *albumVC = [[RestaurantAlbumViewController alloc]init];
    albumVC.media = self.restaurantPhotos;
    albumVC.nextPg = self.nextPg;
    albumVC.restaurant = self.selectedRestaurant;
    [self.navigationController pushViewController:albumVC animated:YES];
}

#pragma mark IDMPhotoBrowserDelegate Methods

//Display our custom metric view if it's a user photo
- (IDMCaptionView *)photoBrowser:(IDMPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index{
    id photoInfo = self.restaurantPhotos[index];
    if ([photoInfo isKindOfClass:[UserReview class]]) {
        UserReview *userReview = (UserReview *)photoInfo;
        IDMPhoto *photo = [[IDMPhoto alloc]initWithURL:[NSURL URLWithString:userReview.imageURL]];
        ReviewMetricView *ratingView = [[ReviewMetricView alloc]initWithPhoto:photo];
        [ratingView loadReview:userReview];
        return ratingView;
    }
    return nil;
}

- (void)willDisappearPhotoBrowser:(IDMPhotoBrowser *)photoBrowser{
    [FoodheadAnalytics logEvent:ALBUM_SWIPE_COUNT withParameters:@{@"albumSwipeCount" : photoBrowser.pagingCount}];
}

@end
