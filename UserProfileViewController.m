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

#import <SDWebImage/UIImageView+WebCache.h>
#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

@interface UserProfileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, IDMPhotoBrowserDelegate>

@property (nonatomic, strong) UserAuthManager *userManager;
@property (nonatomic, strong) User *currentUser;

//@property (nonatomic, strong) UIButton *logoutButton;

@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, strong) UILabel *reviewsLabel;
@property (nonatomic, strong) UILabel *reviewsCount;

@property (nonatomic, strong) UILabel *pointsLabel;
@property (nonatomic, strong) UILabel *pointsCount;

@property (nonatomic, strong) UICollectionView *userPhotoCollection;

//Utilize an ordered set (reviews are returned sorted in db by descending order so just add them in order) to handle not adding already retrieved reviews (instead of removing and refreshing).
@property (nonatomic, strong) NSMutableOrderedSet *userReviewSet;
@property (nonatomic, strong) NSMutableArray *userReviews;//Holds our sorted reviews
@property (nonatomic, strong) NSMutableArray *idmPhotos;

//Overlaid on the photo collection if user has no meals
@property (nonatomic, strong) UIView *noPhotoView;
@property (nonatomic, strong) UILabel *noPhotoLabel;
@property (nonatomic, strong) UIImageView *noPhotoArrowImg;

//For when user has poor/no connection and needs to reload photos
@property (nonatomic, strong) UIView *noConnectionView;
@property (nonatomic, strong) UILabel *noConnectionLabel;
@property (nonatomic, strong) UITapGestureRecognizer *reloadPhotosGesture;
@property (nonatomic, strong) UIActivityIndicatorView *reloadView;

@end

static NSString *cellId = @"userPhoto";

#define NUM_COLUMNS 2

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userReviews = [NSMutableArray array];
    self.idmPhotos = [NSMutableArray array];
    self.userReviewSet = [NSMutableOrderedSet orderedSet];
    self.userManager = [UserAuthManager sharedInstance];
    
    [self setupNavBar];
    [self setupUI];
    [self populateUserData];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUserPhotos];
}

- (void)dealloc{
    [self removeObservers];
}

- (void)setupNavBar{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"settings"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    
    self.profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.125, self.view.frame.size.height * 0.12, self.view.frame.size.width * 0.25, self.view.frame.size.width * 0.25)];
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
    
    self.usernameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.4, CGRectGetMaxY(self.profileImageView.frame) + self.view.frame.size.height * 0.02, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.06)];
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

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 1.0;
    flowLayout.minimumInteritemSpacing = 1.0;
    CGFloat itemWidth = (CGRectGetWidth(self.view.frame) - (NUM_COLUMNS - 1.0)) / NUM_COLUMNS;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    self.userPhotoCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height * 0.45, self.view.frame.size.width, self.view.frame.size.height * 0.55) collectionViewLayout:flowLayout];
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views
    self.userPhotoCollection.contentInset = adjustForTabbarInsets;
    self.userPhotoCollection.scrollIndicatorInsets = adjustForTabbarInsets;
    self.userPhotoCollection.delegate = self;
    self.userPhotoCollection.dataSource= self;
    self.userPhotoCollection.showsVerticalScrollIndicator = NO;
    self.userPhotoCollection.bounces = NO;
    self.userPhotoCollection.backgroundColor = [UIColor whiteColor];
    self.userPhotoCollection.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.userPhotoCollection registerClass:[ReviewCollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.userPhotoCollection];
    
    UIView *sepLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(self.userPhotoCollection.frame), self.view.frame.size.width, 1.0)];
    sepLine.backgroundColor = UIColorFromRGB(0x979797);
    [self.view addSubview:sepLine];
    
}

#pragma mark - User methods

- (void)populateUserData{
    self.currentUser = [self.userManager getCurrentUser];
    if (self.currentUser && (self.currentUser.avatarURL || self.currentUser.avatarImg)) {
        self.navigationController.navigationBar.topItem.title = self.currentUser.username;
        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont nun_fontWithSize:22.0], NSForegroundColorAttributeName : [UIColor blackColor]};
        
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


- (void)updateUserPhotos{
    if ([self.noConnectionView superview]) {
        [self.noConnectionLabel setHidden:YES];
        self.reloadView = [[UIActivityIndicatorView alloc]init];
        self.reloadView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.reloadView.center = CGPointMake(self.noConnectionView.center.x, self.noConnectionView.center.y - self.noConnectionView.frame.size.height * 0.12);
        [self.noConnectionView addSubview:self.reloadView];
        [self.reloadView startAnimating];
    }
    
    [self.userManager retrieveUserReviews:^(id reviews) {
        NSArray *userReviews = (NSArray *)reviews;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (userReviews.count == 0) {
                [self showNoPhotoPrompt];
            }else{
                [self removeErrorView];
            }
        });
        
#warning Have to be careful with this simple check bc what if a user can eventaully delete and upload at same time...?
        //Don't parse or reload if the number of reviews are the same (haven't changed).
        if (self.userReviews.count != userReviews.count) {
            for (NSDictionary *reviewInfo in userReviews) {
                UserReview *review = [MTLJSONAdapter modelOfClass:[UserReview class] fromJSONDictionary:reviewInfo error:nil];
                TPLRestaurant *place = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:reviewInfo[@"place"] error:nil];
                [review mergeValuesForKeysFromModel:place];
                [self.userReviewSet addObject:review];
            }
            
            self.userReviews = [[self.userReviewSet array]mutableCopy];
            [self.idmPhotos removeAllObjects];
            for (UserReview *review in self.userReviews) {
                IDMPhoto *photo = [[IDMPhoto alloc]initWithURL:[NSURL URLWithString:review.imageURL]];
                [self.idmPhotos addObject:photo];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.userPhotoCollection reloadData];
            });
        }
    } failureHandler:^(id error) {
        NSDictionary *userInfo = [error userInfo];
        NSString* errorCode = userInfo[NSLocalizedDescriptionKey];
        if (![NSString isEmpty:errorCode]) {
            if (self.reloadView) {//If this isn't nil, user MUST be seeing no connection prompt
                [self.reloadView stopAnimating];
                [self.noConnectionLabel setHidden:NO];
            }
            
            //Unauthorized user, tell them to start sharing
            if ([errorCode containsString:STATUS_CODE_UNAUTHORIZED]) {
                [self removeErrorView];//If re-connected but user is anon, refresh error screen
                if (![self.noPhotoView superview]) {
                    [self showNoPhotoPrompt];
                }
            }else if ([errorCode containsString:STATUS_NO_INTERNET]){//Bad/No internet connection
                [self removeErrorView];//If anon lost connection, refresh and show couldn't load photos error
                if (![self.noConnectionView superview]) {
                    [self showNoConnectionView];
                }
            }
        }
    }];
}

#pragma mark - Helper Methods

- (void)showNoPhotoPrompt{
    if (![self.noPhotoView superview]) {
        self.noPhotoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.userPhotoCollection.frame.size.width, self.userPhotoCollection.frame.size.height)];
        self.noPhotoView.backgroundColor = [UIColor whiteColor];
        [self.userPhotoCollection addSubview:self.noPhotoView];
        
        self.noPhotoLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.noPhotoView.frame.size.width/2 - self.noPhotoView.frame.size.width * 0.4, self.noPhotoView.frame.size.height * 0.05, self.noPhotoView.frame.size.width * 0.8, self.noPhotoView.frame.size.height * 0.2)];
        self.noPhotoLabel.backgroundColor = [UIColor clearColor];
        self.noPhotoLabel.textAlignment = NSTextAlignmentCenter;
        self.noPhotoLabel.numberOfLines = 2;
        self.noPhotoLabel.font = [UIFont nun_fontWithSize:self.noPhotoView.frame.size.height * 0.05];
        self.noPhotoLabel.text = @"You haven't posted any meals yet.\nStart here!";
        [self.noPhotoView addSubview:self.noPhotoLabel];
        
        self.noPhotoArrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.noPhotoLabel.frame) - self.noPhotoView.frame.size.width * 0.075, CGRectGetMaxY(self.noPhotoLabel.frame) + self.noPhotoView.frame.size.height * 0.05, self.noPhotoView.frame.size.width * 0.15, self.noPhotoView.frame.size.height * 0.5)];
        self.noPhotoArrowImg.backgroundColor = [UIColor clearColor];
        self.noPhotoArrowImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.noPhotoArrowImg setImage:[UIImage imageNamed:@"profile_arrow"]];
        [self.noPhotoView addSubview:self.noPhotoArrowImg];
    }
}

- (void)showNoConnectionView{
    self.noConnectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.userPhotoCollection.frame.size.width, self.userPhotoCollection.frame.size.height)];
    self.noConnectionView.backgroundColor = [UIColor whiteColor];
    [self.userPhotoCollection addSubview:self.noConnectionView];
    
    self.noConnectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.noConnectionView.frame.size.width/2 - self.noConnectionView.frame.size.width * 0.4, self.noConnectionView.frame.size.height * 0.05, self.noConnectionView.frame.size.width * 0.8, self.noConnectionView.frame.size.height * 0.2)];
    self.noConnectionLabel.backgroundColor = [UIColor clearColor];
    self.noConnectionLabel.textAlignment = NSTextAlignmentCenter;
    self.noConnectionLabel.numberOfLines = 1;
    self.noConnectionLabel.font = [UIFont nun_fontWithSize:self.noConnectionView.frame.size.height * 0.05];
    self.noConnectionLabel.text = @"Couldn't load photos. Tap to retry!";
    [self.noConnectionView addSubview:self.noConnectionLabel];
    
    self.reloadPhotosGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(updateUserPhotos)];
    self.reloadPhotosGesture.numberOfTapsRequired = 1;
    [self.noConnectionView addGestureRecognizer:self.reloadPhotosGesture];
}

- (void)removeErrorView{
    if ([self.noPhotoView superview]) {
        [self.noPhotoView removeFromSuperview];
    }else if ([self.noConnectionView superview]){
        [self.noConnectionView removeFromSuperview];
    }
}

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
}

#pragma mark - UICollectionViewDataSource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ReviewCollectionViewCell *reviewCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    reviewCell.backgroundColor = [UIColor whiteColor];
    UserReview *review = self.userReviews[indexPath.row];
    [reviewCell populateUserReview:review];
    return reviewCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.userReviews.count;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc]initWithPhotos:self.idmPhotos];
    browser.delegate = self;
    browser.useWhiteBackgroundColor = YES;
    browser.displayDoneButton = NO;
    browser.dismissOnTouch = YES;
    browser.displayToolbar = NO;
    browser.autoHideInterface = NO;
    browser.forceHideStatusBar = YES;
    [browser setInitialPageIndex:indexPath.row];
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark IDMPhotoBrowserDelegate Methods

//Display our custom metric view if it's a user photo
- (IDMCaptionView *)photoBrowser:(IDMPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index{
    id photoInfo = self.userReviews[index];
    if ([photoInfo isKindOfClass:[UserReview class]]) {
        UserReview *userReview = (UserReview *)photoInfo;
        IDMPhoto *photo = [[IDMPhoto alloc]initWithURL:[NSURL URLWithString:userReview.imageURL]];
        ReviewMetricView *ratingView = [[ReviewMetricView alloc]initWithPhoto:photo];
        [ratingView loadReview:userReview];
        return ratingView;
    }
    return nil;
}

#pragma mark - UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
//    UINavigationController *nav = (UINavigationController *)viewController;
//    UIViewController *root = [[nav viewControllers]firstObject];
//    if ([root isKindOfClass:[TabCameraViewController class]]) {
//        TabCameraViewController *camVC = (TabCameraViewController *) root;
//        camVC.tabBarController.delegate = camVC;
//    }
}

@end
