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
#import "AnimationPreviewViewController.h"
#import "PreviewAnimation.h"
#import "NSString+IsEmpty.h"
#import "DiscoverRealm.h"
#import "RestaurantPageControlView.h"
#import "RestaurantPageScoreView.h"

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface TPLRestaurantPageViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, RestaurantInfoCellDelegate, IDMPhotoBrowserDelegate, ImageCollectionCellDelegate, LocationManagerDelegate, RestaurantPageControlViewDelegate>

//UI
@property (nonatomic, strong) UITableView *detailsTableView;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, assign) CGFloat dynamicHoursHeight;//For dynamic resizing of hours cell height
@property (nonatomic, strong) RestaurantPageControlView *restControlView;

//Photos
@property (nonatomic, strong) UICollectionView *photoCollection;
@property (nonatomic, strong) NSString *nextPg;

//Data source
@property (nonatomic, strong) NSMutableArray *restaurantPhotos;
@property (nonatomic, strong) NSMutableArray *idmPhotos;
@property (nonatomic, strong) NSMutableArray *userReviews;

@property (nonatomic, strong) RLMResults *favRestaurants;
@property (nonatomic, strong) RLMNotificationToken *favNotif;
@property (nonatomic, assign) BOOL isFavorite;

//View Model
@property (nonatomic, strong) TPLRestaurantPageViewModel *pageViewModel;
@property (nonatomic, assign) BOOL detailsFetched;

//Hold to preview
@property (nonatomic, strong) AnimationPreviewViewController *previewVC;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGest;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL gestureCancelled;

//Location
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, strong) LocationManager *locationManager;


@end


static NSString *cellId = @"detailCell";
static NSString *photoCellId = @"photoCell";

#define NUM_COLUMNS 3
#define NUM_COLLECTION_CELLS 6
#define FAKE_NAV_BAR_HEIGHT 60.0

@implementation TPLRestaurantPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.restaurantPhotos = [NSMutableArray array];
    self.idmPhotos = [NSMutableArray array];
    self.userReviews = [NSMutableArray array];
    self.pageViewModel = [[TPLRestaurantPageViewModel alloc]init];
    self.detailsFetched = NO;
    
    self.locationManager = [LocationManager sharedLocationInstance];
    
    //We use these notification blocks to reflect favorite/unfavorite across the app(tabs) - (i.e. Each restaurant page has to have the same favorite button)
    self.favRestaurants = [DiscoverRealm allObjects];
    __weak typeof(self) weakSelf = self;
    self.favNotif = [self.favRestaurants addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Couldn't create discover realm token");
        }
        
        //Change is nil for the intial run of realm query, so just load whatever we have
        if (!change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                RLMResults *favResults = [results objectsWithPredicate:[NSPredicate predicateWithFormat:@"foursqId == %@", weakSelf.selectedRestaurant.foursqId]];
                DiscoverRealm *favRestaurant = [favResults firstObject];
                if (favRestaurant) {
                    weakSelf.isFavorite = YES;
                }else{
                    weakSelf.isFavorite = NO;
                }
                [weakSelf.restControlView toggleFavoriteButton:weakSelf.isFavorite];
                return;
            });
        }
        
        if ([change insertionsInSection:0].count > 0) {
            [weakSelf checkForFavorite];
        }
        
        if ([change deletionsInSection:0].count > 0) {
            [weakSelf checkForUnfavorite];
        }
    }];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNavBar];
    self.locationManager.locationDelegate = self;
    [[LocationManager sharedLocationInstance]retrieveCurrentLocation];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //We should only load images/metrics once in viewDidLoad. Refresh images here so this request isn't being called if user swipes in/out halfway. This also takes care of the media reference bug noted in RestaurantAlbumView
    if (self.detailsFetched) {
        //[self refreshMetrics];
        [self loadRestaurantImages];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.locationManager.locationDelegate = nil;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)loadRestaurantDetails{
    [self.pageViewModel retrieveRestaurantDetailsFor:self.selectedRestaurant atLocation:self.currentLocation completionHandler:^(TPLRestaurant* fullRestaurant) {
        if (fullRestaurant) {
            self.detailsFetched = YES;
            self.selectedRestaurant = fullRestaurant;
            self.dynamicHoursHeight = [self calculateDynamicHoursHeight];
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self.detailsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0],
                                                                    [NSIndexPath indexPathForRow:3 inSection:0],
                                                                    [NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });

            //Must load reviews after we retrieve details because restaurant might not be cached in our db
            [self.pageViewModel retrieveReviewsForRestaurant:fullRestaurant completionHandler:^(id completionHandler) {
                [self.userReviews addObjectsFromArray:completionHandler];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.detailsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                });
                
            } failureHandler:^(id failureHandler) {
                DLog(@"Failed to get user reviews");
            }];
        }
    } failureHandler:^(id error) {
        //TODO:: Handle this by changing rest page UI?
        DLog(@"Couldn't get details");
    }];
    
    [self loadRestaurantImages];
}

//- (void)refreshMetrics{
//    [self.pageViewModel retrieveReviewsForRestaurant:self.selectedRestaurant completionHandler:^(id completionHandler) {
//        NSArray *userReviews = completionHandler;
//
//#warning Is this the best way to handle photos and review refreshing? Need to revisit this logic later on
//        if (self.userReviews.count == userReviews.count) {
//            //No need to refresh in number of reviews didn't change
//            return;
//        }
//        [self.userReviews removeAllObjects];
//        [self.userReviews addObjectsFromArray:completionHandler];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.detailsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//        });
//
//    } failureHandler:^(id failureHandler) {
//        DLog(@"Failed to refresh metrics");
//    }];
//}

- (void)loadRestaurantImages{
    [self.pageViewModel retrieveImagesForRestaurant:self.selectedRestaurant
                                               page:nil
                                  completionHandler:^(id media) {
                                      self.nextPg = media[@"next_page"];
                                      NSArray *images = media[@"images"];
                                
                                      if (self.restaurantPhotos.count != images.count) {
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
          DLog(@"%@", failureHandler);
      }];
}


- (void)setupNavBar{
    //Still need navigation bar for pushing/popping so just completely hide it so it doesn't get in the way of our animations
    self.navigationItem.title = @"";
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage new] style:UIBarButtonItemStylePlain target:self action:@selector(exitRestaurantPage)];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;//Preserves swipe back gesture
    
    //Will make our status bar opaque
    UIView *statusBarBg = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    statusBarBg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:statusBarBg];
}

- (void)exitRestaurantPage{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper Methods

- (void)setupUI{
    self.view.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    
    self.detailsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.detailsTableView.delegate = self;
    self.detailsTableView.dataSource = self;
    self.detailsTableView.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.detailsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(FAKE_NAV_BAR_HEIGHT, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views
    self.detailsTableView.contentInset = adjustForTabbarInsets;
    self.detailsTableView.scrollIndicatorInsets = adjustForTabbarInsets;
    self.detailsTableView.rowHeight = UITableViewAutomaticDimension;
    self.detailsTableView.estimatedRowHeight = RESTAURANT_HOURS_CELL_HEIGHT;
    self.detailsTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.detailsTableView];
    
    //Create custom nav bar to get custom title
    UIView *fakeNavBar = [[UIView alloc]initWithFrame:CGRectMake(0.0, [[UIApplication sharedApplication]statusBarFrame].size.height, self.view.frame.size.width, FAKE_NAV_BAR_HEIGHT)];
    fakeNavBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:fakeNavBar];
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0.0, fakeNavBar.frame.size.height/2 - fakeNavBar.frame.size.height * 0.25, fakeNavBar.frame.size.width * 0.1, fakeNavBar.frame.size.height * 0.5)];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"arrow_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(exitRestaurantPage) forControlEvents:UIControlEventTouchUpInside];
    [fakeNavBar addSubview:backButton];
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(fakeNavBar.frame.size.width/2 - fakeNavBar.frame.size.width * 0.39, fakeNavBar.frame.size.height/2.7 - fakeNavBar.frame.size.height * 0.24, fakeNavBar.frame.size.width * 0.78, fakeNavBar.frame.size.height * 0.48)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = self.selectedRestaurant.name;
    [titleLabel setFont:[UIFont nun_fontWithSize:APPLICATION_FRAME.size.width * 0.05]];
    [fakeNavBar addSubview:titleLabel];
    
    NSString *categoriesStr = @"";
    if (self.selectedRestaurant.categories.count > 0) {
        NSString *catStr = [[self.selectedRestaurant.categories firstObject]stringByReplacingOccurrencesOfString:@" Restaurant" withString:@""];
        categoriesStr = catStr;
    }
    
    //Center title if there's no category
    if ([NSString isEmpty:categoriesStr]) {
        CGRect titleFrame = titleLabel.frame;
        titleFrame.origin.y = fakeNavBar.frame.size.height/2 - fakeNavBar.frame.size.height * 0.25;
        titleLabel.frame = titleFrame;
    }else{
        UILabel *categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(fakeNavBar.frame.size.width/2 - fakeNavBar.frame.size.width * 0.39, CGRectGetMaxY(titleLabel.frame), fakeNavBar.frame.size.width * 0.78, fakeNavBar.frame.size.height * 0.34)];
        categoryLabel.backgroundColor = [UIColor clearColor];
        categoryLabel.numberOfLines = 1;
        categoryLabel.textAlignment = NSTextAlignmentCenter;
        categoryLabel.textColor = UIColorFromRGB(0x505254);
        categoryLabel.text = categoriesStr;
        [categoryLabel setFont:[UIFont nun_fontWithSize:REST_PAGE_HEADER_FONT_SIZE]];
        [fakeNavBar addSubview:categoryLabel];
    }
}

- (void)setupPhotoCollection{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 1.0;
    flowLayout.minimumLineSpacing = 1.0;
    CGFloat itemWidth = (CGRectGetWidth(self.view.frame) - (NUM_COLUMNS - 1.0)) / NUM_COLUMNS;
    flowLayout.itemSize = CGSizeMake(itemWidth - 0.5, itemWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.photoCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.width/3) * 2) collectionViewLayout:flowLayout];
    self.photoCollection.backgroundColor = [UIColor whiteColor];
    self.photoCollection.delegate = self;
    self.photoCollection.dataSource= self;
    self.photoCollection.scrollEnabled = NO;
    [self.photoCollection registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:photoCellId];
    
    self.longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressGest.minimumPressDuration = 0.15;
    [self.photoCollection addGestureRecognizer:self.longPressGest];
    
    //Sometimes the guesture finishes too fast so we use this in order to find out
    self.gestureCancelled = NO;
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
                CGRect hrSize = [hrStr boundingRectWithSize:CGSizeMake(APPLICATION_FRAME.size.width * 0.4, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont nun_fontWithSize:REST_PAGE_DETAIL_FONT_SIZE]} context:nil];
                cellHeight += hrSize.size.height + RESTAURANT_HOURS_CELL_HEIGHT * 0.4;//Need extra padding here for spacing
            }
        }
    }

    //Keep a constant height as a minimum or when there are no hours
    if (cellHeight < RESTAURANT_HOURS_CELL_HEIGHT) {
        cellHeight = RESTAURANT_HOURS_CELL_HEIGHT + APPLICATION_FRAME.size.height * 0.02;
    }
    return cellHeight;
}

- (void)checkForUnfavorite{
    //Check to see if it was this restaurant that was deleted from favorites
    RLMResults *favResults = [self.favRestaurants objectsWithPredicate:[NSPredicate predicateWithFormat:@"foursqId == %@", _selectedRestaurant.foursqId]];
    DiscoverRealm *isFavorite = [favResults firstObject];
                              
    if (!isFavorite) {
        _isFavorite = NO;
        [self.restControlView toggleFavoriteButton:_isFavorite];
    }
}

- (void)checkForFavorite{
    RLMResults *favResults = [self.favRestaurants objectsWithPredicate:[NSPredicate predicateWithFormat:@"foursqId == %@", _selectedRestaurant.foursqId]];
    DiscoverRealm *addedFav = [favResults firstObject];
    
    if (addedFav) {
        _isFavorite = YES;
        [self.restControlView toggleFavoriteButton:_isFavorite];
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
        
        CLLocationCoordinate2D currentLocation = [[LocationManager sharedLocationInstance]currentLocation];
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

#pragma mark -
- (void)userCLickedCallButton{
    if (![NSString isEmpty:self.selectedRestaurant.phoneNumber]) {
        [FoodheadAnalytics logEvent:CALL_RESTAURANT];
        NSString *formattedNumber = [self.selectedRestaurant.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:formattedNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber] options:@{} completionHandler:nil];
    }
}

- (void)userClickedShareButton{
    
}

- (void)userClickedFavoriteButton{
    [self toggleFavoriteButton];
}

- (void)toggleFavoriteButton{
    RLMRealm *realm = [RLMRealm defaultRealm];
    if (_isFavorite) {
        NSError *error;
        [realm transactionWithBlock:^{
            [realm deleteObject:[DiscoverRealm objectForPrimaryKey:self.selectedRestaurant.foursqId]];
        } error:&error];
        
        if (!error) {
            _isFavorite = NO;
            [self.restControlView toggleFavoriteButton:_isFavorite];

        }else{
            DLog(@"Couldn't unfavorite specific restaurant: %@", error);
        }
    }else{
        DiscoverRealm *discoverRlm = [[DiscoverRealm alloc]init];
        discoverRlm.name = _selectedRestaurant.name;
        discoverRlm.foursqId = _selectedRestaurant.foursqId;
        discoverRlm.hasVideo = _selectedRestaurant.hasVideo;
        if (_selectedRestaurant.categories.count > 0) {
            discoverRlm.primaryCategory = [_selectedRestaurant.categories firstObject];
        }
        discoverRlm.lat = _selectedRestaurant.latitude;
        discoverRlm.lng = _selectedRestaurant.longitude;
        discoverRlm.website = _selectedRestaurant.website;
        
        if (self.selectedRestaurant.address) {
            discoverRlm.address = self.selectedRestaurant.address;
            discoverRlm.zipCode = self.selectedRestaurant.zipCode;
            discoverRlm.city = self.selectedRestaurant.city;
            discoverRlm.state = self.selectedRestaurant.state;
        }
        
        if (_selectedRestaurant.hasVideo.boolValue) {
            discoverRlm.thumbnailVideoLink = _selectedRestaurant.blogVideoLink;
            discoverRlm.thumbnailVideoWidth = _selectedRestaurant.blogVideoWidth;
            discoverRlm.thumbnailVideoHeight = _selectedRestaurant.blogVideoHeight;
        }else{
            if(_selectedRestaurant.blogPhotoLink){
                discoverRlm.thumbnailPhotoLink = _selectedRestaurant.blogPhotoLink;
                discoverRlm.thumbnailPhotoWidth = _selectedRestaurant.blogPhotoWidth;
                discoverRlm.thumbnailPhotoHeight = _selectedRestaurant.blogPhotoHeight;
            }else{
                discoverRlm.thumbnailPhotoLink = _selectedRestaurant.thumbnail;
                discoverRlm.thumbnailPhotoWidth = _selectedRestaurant.thumbnailWidth;
                discoverRlm.thumbnailPhotoHeight = _selectedRestaurant.thumbnailHeight;
            }
        }
        
        discoverRlm.sourceBlogName = _selectedRestaurant.blogTitle;
        discoverRlm.sourceBlogProfilePhoto = _selectedRestaurant.blogPhotoLink;
        discoverRlm.creationDate = [NSDate date];
        
        NSError *error;
        [realm transactionWithBlock:^{
            [realm addObject:discoverRlm];
        } error:&error];
        
        if (!error) {
            _isFavorite = YES;
            [self.restControlView toggleFavoriteButton:_isFavorite];
        }else{
            DLog(@"Couldn't favorite specific restaurant: %@", error);
        }
    }
}


#pragma mark - UTableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:{
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            RestaurantPageScoreView *scoreView = [[RestaurantPageScoreView alloc]initWithFrame:CGRectMake(0.0, 0.0, APPLICATION_FRAME.size.width, RESTAURANT_SCORE_CELL_HEIGHT)];
            NSString *convertedScore;
            if (self.selectedRestaurant.foursq_rating) {
                NSNumber *rating = @(self.selectedRestaurant.foursq_rating.doubleValue * 10.0);
                convertedScore = rating.stringValue;
                scoreView.scoreLabel.text = [NSString stringWithFormat:@"%ld%%", (long)convertedScore.integerValue];
            }
            [cell addSubview:scoreView];
            break;
        }
        case 1:{
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self setupPhotoCollection];
            [cell.contentView addSubview:self.photoCollection];
            break;
        }case 2:{
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.restControlView = [[RestaurantPageControlView alloc]initWithFrame:CGRectMake(0, 0, APPLICATION_FRAME.size.width, METRIC_CELL_HEIGHT)];
            [self.restControlView setTextForPrice:self.selectedRestaurant.foursq_price_tier];
            [self.restControlView toggleFavoriteButton:self.isFavorite];
            if (!self.selectedRestaurant.phoneNumber) {
                [self.restControlView.callButton setEnabled:NO];
            }
            
            self.restControlView.delegate = self;
            [cell addSubview:self.restControlView];
            break;
        }case 3:{
            RestaurantInfoTableViewCell *infoCell = [[RestaurantInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            infoCell.delegate = self;
            if (self.detailsFetched) {
                [infoCell populateInfo:self.selectedRestaurant];
            }
            cell = infoCell;
            break;
        }case 4:{
            HoursTableViewCell *hoursCell = [[HoursTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            if (self.detailsFetched) {
                hoursCell.dynamicHeight = self.dynamicHoursHeight;
                [hoursCell populateHours:self.selectedRestaurant];
            }
            cell = hoursCell;
            break;
        }case 5:{
            AttributionTableViewCell *attributeCell = [[AttributionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell = attributeCell;
            break;
        }default:
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
            cellHeight = RESTAURANT_SCORE_CELL_HEIGHT;
            break;
        case 1:{
            CGFloat itemWidth = (CGRectGetWidth(self.view.frame) - (NUM_COLUMNS - 1.0)) / NUM_COLUMNS;
            cellHeight = itemWidth * 2;
            break;
        }
        case 2:
            cellHeight = METRIC_CELL_HEIGHT;
            break;
        case 3:
            cellHeight = RESTAURANT_LOCATION_CELL_HEIGHT;
            break;
        case 4:{
            if (self.dynamicHoursHeight > 0.0) {
                cellHeight = self.dynamicHoursHeight;
            }else{
                cellHeight = RESTAURANT_HOURS_CELL_HEIGHT;
            }
            break;
        }
        case 5:
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
//            if (self.selectedRestaurant.menu) {
//                [FoodheadAnalytics logEvent:OPEN_RESTAURANT_MENU];
//                WebViewController *menuVC = [[WebViewController alloc]init];
//                menuVC.webLink = self.selectedRestaurant.menu;
//                [self.navigationController pushViewController:menuVC animated:YES];
//            }
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
            photoUrl = [NSURL URLWithString:imgInfo[@"thumbnail_url"]];
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
    //browser.disableVerticalSwipe = YES;
    browser.progressTintColor = APPLICATION_BLUE_COLOR;
    [browser setInitialPageIndex:indexPath.row];
    [browser trackPageCount];
    
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark ImageCollectionCellDelegate methods

- (void)didTapSeeAllButton{
    [FoodheadAnalytics logEvent:OPEN_RESTAURANT_ALBUM];
    RestaurantAlbumViewController *albumVC = [[RestaurantAlbumViewController alloc] initWithMedia:self.restaurantPhotos nextPage:self.nextPg forRestuarant:self.selectedRestaurant];
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

#pragma mark - UIGestureRecognizerDelegate methods

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.gestureCancelled = NO;
        CGPoint p = [gestureRecognizer locationInView:self.photoCollection];
        self.selectedIndexPath = [self.photoCollection indexPathForItemAtPoint:p];
        
        //Don't let user hold to preview an empty cell
        if (self.selectedIndexPath.row + 1 > self.restaurantPhotos.count) {
            return;
        }
        
        if (self.selectedIndexPath) {
            //Must check if thumbnail has loaded first b/c we need the smaller image to perform animation as
            ImageCollectionCell *imgCell = (ImageCollectionCell *)[self.photoCollection cellForItemAtIndexPath:self.selectedIndexPath];
            if (!CGSizeEqualToSize(imgCell.coverImageView.image.size, CGSizeZero)) {
                id imgInfo = self.restaurantPhotos[self.selectedIndexPath.row];
                
                NSString *imgURLStr;
                if ([imgInfo isKindOfClass:[NSDictionary class]]) {
                    imgURLStr = imgInfo[@"url"];
                }else if([imgInfo isKindOfClass:[UserReview class]]){
                    UserReview *review = imgInfo;
                    imgURLStr = review.thumbnailURL;
                }
                NSURL *imgURL = [NSURL URLWithString:imgURLStr];
                
                //Init the view controller for previewing
                self.previewVC = [[AnimationPreviewViewController alloc] initWithIndex:0 andImageURL:imgURL withPlaceHolder:imgCell.coverImageView.image];
                self.previewVC.modalPresentationCapturesStatusBarAppearance = YES;//Must use this in order to hide the status bar
                self.previewVC.transitioningDelegate = self;
                [self.previewVC setModalPresentationStyle:UIModalPresentationCustom];
                [self presentViewController:self.previewVC animated:YES completion:^{
                    if (self.gestureCancelled) {
                        //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                    }
                }];
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.previewVC dismissViewControllerAnimated:YES completion:nil];
    } else if(gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        self.gestureCancelled = YES;
        [self.previewVC dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    UIImageView *smallImageView;
    UIImageView *bigImageView;
    
    //First lets get the current cell
    ImageCollectionCell* cell = (ImageCollectionCell*)[self.photoCollection cellForItemAtIndexPath:self.selectedIndexPath];
    
    //Now lets get the current image
    smallImageView = cell.coverImageView;
    
    //Now lets get the Animation Imageview
    bigImageView = [(AnimationPreviewViewController*)presented imageView];
    
    return [[PreviewAnimation alloc] initWithSmallImageView:smallImageView ToBigImageView:bigImageView];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    UIImageView *smallImageView;
    UIImageView *bigImageView;
    
    //First lets get the current cell
    ImageCollectionCell* cell = (ImageCollectionCell*)[self.photoCollection cellForItemAtIndexPath:self.selectedIndexPath];
    
    //Now lets get the current image
    smallImageView = cell.coverImageView;
    
    //Now lets get the Animation Imageview
    bigImageView = [(AnimationPreviewViewController*)dismissed imageView];
    
    return [[PreviewAnimation alloc] initWithSmallImageView:smallImageView ToBigImageView:bigImageView];
}

#pragma mark - LocationManagerDelegate methods

- (void)didGetCurrentLocation:(CLLocationCoordinate2D)coordinate{
    self.currentLocation = coordinate;
    
    //Should only be called once the first time the page is opened.
    if (!self.detailsFetched) {
        [self loadRestaurantDetails];
    }
}

@end
