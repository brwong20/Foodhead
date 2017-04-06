//
//  TPLAssetPreviewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/5/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLAssetPreviewController.h"
#import "TPLFilterScrollView.h"
#import "BRWSearchView.h"
#import "TPLRestaurantManager.h"
#import "RestaurantSearchViewController.h"
#import "AppDelegate.h"
#import "LayoutBounds.h"
#import "FoodWiseDefines.h"
#import "LoginViewController.h"
#import "UserAuthManager.h"
#import "User.h"
#import "RatingContainerView.h"
#import "FoodheadAnalytics.h"
#import "UIFont+Extension.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <Photos/Photos.h>

@interface TPLAssetPreviewController () <FilterScrollDelegate>

@property (nonatomic, strong) UIImageView *assetImageView;

//UI Controls
@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *submitButton;

//Filters
@property (nonatomic, strong) TPLFilterScrollView *filterView;

//Ratings
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *overallRating;
@property (nonatomic, strong) NSNumber *healthRating;
@property (nonatomic, strong) RatingContainerView *ratingView;

//User
@property (nonatomic, strong) User *currentUser;

//Tooltip
@property (nonatomic, strong) UIImageView *tooltipImgView;

@end

@implementation TPLAssetPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tabBarController.tabBar setHidden:YES];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Need to refresh user in case anon logged in.
    self.currentUser = [[UserAuthManager sharedInstance]getCurrentUser];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

//Used to listen for when a user first signs up. After submitting username we will push them to next VC automatically
- (void)addObservers{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(submitReview) name:SIGNUP_NOTIFICATION object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SIGNUP_NOTIFICATION object:nil];
}

- (void)dealloc{
    [self removeObservers];
}

- (void)setupUI{
    self.assetImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.assetImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.assetImageView setImage:self.currentReview.image];
    [self.view addSubview:self.assetImageView];
    
    //Custom rating filters
    self.filterView = [[TPLFilterScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.9)];
    [self.filterView loadFilters];
    self.filterView.scrollDelegate = self;
    [self.view addSubview:self.filterView];
    
    self.saveButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.height * 0.05, CGRectGetMaxY(self.filterView.frame), self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1)];
    self.saveButton.backgroundColor = [UIColor clearColor];
    [self.saveButton setImage:[UIImage imageNamed:@"save_shot"] forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    
    self.submitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - self.view.frame.size.height * 0.1, CGRectGetMaxY(self.filterView.frame), self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1)];
    self.submitButton.backgroundColor = [UIColor clearColor];
    [self.submitButton setImage:[UIImage imageNamed:@"next_btn"] forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(submitReview) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.submitButton aboveSubview:self.filterView];
    
    self.exitButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.filterView.frame), self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1)];
    self.exitButton.backgroundColor = [UIColor clearColor];
    [self.exitButton setImage:[UIImage imageNamed:@"prev_btn"] forState:UIControlStateNormal];
    [self.exitButton addTarget:self action:@selector(exitPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.exitButton aboveSubview:self.filterView];
    
    self.ratingView = [[RatingContainerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.08)];
    self.ratingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.ratingView];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:CAMERA_RATING_TOOLTIP]) {
        self.tooltipImgView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.4, self.view.frame.size.height/1.5 - self.view.frame.size.height * 0.25, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.5)];
        self.tooltipImgView.backgroundColor = [UIColor clearColor];
        self.tooltipImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.tooltipImgView setImage:[UIImage imageNamed:@"tooltip_review"]];
        [self.view addSubview:self.tooltipImgView];
        
        UITapGestureRecognizer *dismissTooltip = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTooltip)];
        dismissTooltip.numberOfTapsRequired = 1;
        dismissTooltip.cancelsTouchesInView = YES;
        [self.view addGestureRecognizer:dismissTooltip];
        
        UISwipeGestureRecognizer *swipeDismiss = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTooltip)];
        swipeDismiss.cancelsTouchesInView = YES;
        [self.view addGestureRecognizer:swipeDismiss];
    }
}

- (void)dismissTooltip{
    if ([self.tooltipImgView superview]) {
        [self.tooltipImgView removeFromSuperview];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:CAMERA_RATING_TOOLTIP];
    }
}

- (void)exitPreview{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)submitReview{
    if (!_currentUser) {
        [self addObservers];
        [self promptSignup];
    }else{
        RestaurantSearchViewController *searchVC = [[RestaurantSearchViewController alloc]init];
        searchVC.currentReview = self.currentReview;
        [self.filterView dismissPriceKeypad];
        [FoodheadAnalytics logEvent:REVIEW_FLOW_NEXT];
        [self.navigationController pushViewController:searchVC animated:NO];
    }
}

- (void)promptSignup{
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    loginVC.isOnboarding = NO;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:loginVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)saveImage{
    [FoodheadAnalytics logEvent:USER_SAVE_PHOTO];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *changeReq = [PHAssetChangeRequest creationRequestForAssetFromImage:self.currentReview.image];
                changeReq.creationDate = [NSDate date];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    [SVProgressHUD setContainerView:self.view];
                    [SVProgressHUD setMinimumSize:CGSizeMake(self.view.frame.size.width * 0.3, self.view.frame.size.width * 0.25)];
                    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
                    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.6 alpha:0.7]];
                    [SVProgressHUD setFont:[UIFont nun_fontWithSize:16.0]];
                    [SVProgressHUD setMinimumDismissTimeInterval:1.5];
                    [SVProgressHUD showSuccessWithStatus:@"Image saved"];
                }
            }];
        }else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted)
        {
            UIAlertController *invalidAuth = [UIAlertController alertControllerWithTitle:@" Photo Album Permission" message:@"Please go to your settings and enable album perssions in order to save your photos!" preferredStyle:UIAlertControllerStyleAlert];
            [invalidAuth addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [invalidAuth dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:invalidAuth animated:YES completion:nil];
        }
    }];
}

- (void)didUpdatePrice:(NSNumber *)price{
    self.currentReview.price = price;
    [self.ratingView setPrice:price];
}

- (void)didUpdateOverall:(NSNumber *)overall{
    self.currentReview.overall = overall;
    [self.ratingView setOverall:overall];
}

- (void)didUpdateHealthiness:(NSNumber *)healthiness{
    self.currentReview.healthiness = healthiness;
    [self.ratingView setHealth:healthiness];
}

#pragma mark TPLFilterScrollViewDelegate methods

- (void)pricePadWillShow:(NSNotification *)notif{
    CGRect padFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat animDuration = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey]floatValue];

    [UIView animateWithDuration:animDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect submitFrame = self.submitButton.frame;
        CGRect saveFrame = self.saveButton.frame;
        CGRect exitFrame = self.exitButton.frame;
        
        submitFrame.origin.y -= padFrame.size.height;
        saveFrame.origin.y -= padFrame.size.height;
        exitFrame.origin.y -= padFrame.size.height;

        self.submitButton.frame = submitFrame;
        self.saveButton.frame = saveFrame;
        self.exitButton.frame = exitFrame;
    } completion:nil];
}

- (void)pricePadWillHide:(NSNotification *)notif{
    CGRect padFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat animDuration = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey]floatValue];
    
    [UIView animateWithDuration:animDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect submitFrame = self.submitButton.frame;
        CGRect saveFrame = self.saveButton.frame;
        CGRect exitFrame = self.exitButton.frame;
        
        submitFrame.origin.y += padFrame.size.height;
        saveFrame.origin.y += padFrame.size.height;
        exitFrame.origin.y += padFrame.size.height;

        self.submitButton.frame = submitFrame;
        self.saveButton.frame = saveFrame;
        self.exitButton.frame = exitFrame;
    } completion:nil];
}

- (void)filterViewDidScroll:(UIScrollView *)scrollView{
    [self dismissTooltip];
}


@end
