//
//  RestaurantSearchViewController.m
//  Foodhead
//
//  Created by Brian Wong on 3/9/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RestaurantSearchViewController.h"
#import "TPLRestaurantManager.h"
#import "RatingContainerView.h"
#import "BRWSearchView.h"
#import "FoodWiseDefines.h"
#import "FoodheadAnalytics.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface RestaurantSearchViewController () <BRWSearchViewDelegate>

@property (nonatomic, strong) BRWSearchView *searchView;
@property (nonatomic, strong) RatingContainerView *ratingView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation RestaurantSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.backgroundColor = [UIColor whiteColor];
    [self.imgView setImage:self.currentReview.image];
    [self.view addSubview:self.imgView];
    
    self.ratingView = [[RatingContainerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.08)];
    self.ratingView.backgroundColor = [UIColor clearColor];
    [self.ratingView setPrice:self.currentReview.price];
    [self.ratingView setHealth:self.currentReview.healthiness];
    [self.ratingView setOverall:self.currentReview.overall];
    [self.view addSubview:self.ratingView];
    
    self.searchView = [[BRWSearchView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.45, CGRectGetMaxY(self.ratingView.frame) + self.view.frame.size.height * 0.02, self.view.frame.size.width * 0.9, 50.0)];
    self.searchView.delegate = self;
    self.searchView.currentReview = self.currentReview;
    [self.view addSubview:self.searchView];
    
    self.submitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.9, self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1)];
    self.submitButton.backgroundColor = [UIColor clearColor];
    self.submitButton.alpha = 0.0;
    self.submitButton.userInteractionEnabled = NO;
    [self.submitButton setImage:[UIImage imageNamed:@"accept_btn"] forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(submitReview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
    
    self.backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height * 0.9, self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1)];
    self.backButton.backgroundColor = [UIColor clearColor];
    [self.backButton setImage:[UIImage imageNamed:@"prev_btn"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(exitSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    UITapGestureRecognizer *dismiss = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    dismiss.numberOfTapsRequired = 1;
    dismiss.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:dismiss];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.searchView showKeyboard];
}

- (BOOL)hidesBottomBarWhenPushed{
    return YES;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)submitReview{
    [FoodheadAnalytics logEvent:REVIEW_SUBMIT];
    if (self.currentReview.overall) [FoodheadAnalytics logEvent:OVERALL_SUBMIT];
    if (self.currentReview.price) [FoodheadAnalytics logEvent:PRICE_SUBMIT];
    if (self.currentReview.healthiness) [FoodheadAnalytics logEvent:HEALTHINESS_SUBMIT];
    
    if (self.currentReview.restaurant_id) {
        [SVProgressHUD setContainerView:self.view];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        [SVProgressHUD setBackgroundColor:APPLICATION_BLUE_COLOR];
        [SVProgressHUD setFont:[UIFont nun_boldFontWithSize:20.0]];
        [SVProgressHUD setMinimumSize:CGSizeMake(self.view.frame.size.width * 0.6, self.view.frame.size.height * 0.22)];
        [SVProgressHUD showWithStatus:@"Uploading your meal"];
        
        TPLRestaurantManager *restaurantManager = [[TPLRestaurantManager alloc]init];
        NSData *imgData = UIImageJPEGRepresentation(self.currentReview.image, 0.8);
        self.backButton.userInteractionEnabled = NO;
        self.submitButton.userInteractionEnabled = NO;
        
        [restaurantManager submitReviewForRestaurant:self.currentReview.restaurant_id
                                       overallRating:[self.currentReview.overall stringValue]
                                         healthScore:[self.currentReview.healthiness stringValue]
                                               price:[self.currentReview.price stringValue]
                                               photo:imgData
                                   completionHandler:^(id success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithCompletion:^{
                    [self showSuccessView];
#warning Eventually redirect them to whatever tab & page user was on
                    [self.tabBarController setSelectedIndex:0];
                    [self.navigationController popToRootViewControllerAnimated:NO];//Start camera on first screen when user comes back
                }];
            });
        } failureHandler:^(id error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backButton.userInteractionEnabled = YES;
                self.submitButton.userInteractionEnabled = YES;
                [SVProgressHUD showErrorWithStatus:@"Upload failed. Please try again!"];
            });
        }];
    }
}

//Easiest way to account for the success image appearing anywhere after user is redirected back to their original tab/screen
- (void)showSuccessView{
    CGRect windowFrame = self.view.window.frame;
    
    UIView *containerView = [[UIView alloc]initWithFrame:windowFrame];
    containerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    containerView.alpha = 0.0;
    [self.view.window addSubview:containerView];
    
    UIView *successView = [[UIView alloc]initWithFrame:CGRectMake(windowFrame.size.width/2 - self.view.frame.size.width * 0.35, windowFrame.size.height/2 - self.view.frame.size.height * 0.11, self.view.frame.size.width * 0.7, self.view.frame.size.height * 0.22)];
    successView.backgroundColor = APPLICATION_BLUE_COLOR;
    successView.layer.cornerRadius = 8.0;
    successView.clipsToBounds = YES;
    [containerView addSubview:successView];
    
    UILabel *successTitle = [[UILabel alloc]initWithFrame:CGRectMake(successView.frame.size.width/2 - successView.frame.size.width * 0.35, successView.frame.size.height * 0.35 - successView.frame.size.height * 0.1, successView.frame.size.width * 0.7, successView.frame.size.height * 0.2)];
    successTitle.backgroundColor = [UIColor clearColor];
    successTitle.font = [UIFont nun_boldFontWithSize:20.0];
    successTitle.textAlignment = NSTextAlignmentCenter;
    successTitle.numberOfLines = 1;
    [successTitle setText:@"😋😋😋😋"];
    [successView addSubview:successTitle];
    
    UILabel *successLabel = [[UILabel alloc]initWithFrame:CGRectMake(successView.frame.size.width/2 - successView.frame.size.width * 0.45, CGRectGetMaxY(successTitle.frame), successView.frame.size.width * 0.9, successView.frame.size.height * 0.4)];
    successLabel.backgroundColor = [UIColor clearColor];
    successLabel.textColor = [UIColor whiteColor];
    successLabel.font = [UIFont nun_boldFontWithSize:20.0];
    successLabel.textAlignment = NSTextAlignmentCenter;
    successLabel.numberOfLines = 2;
    [successLabel setText:@"Sweet Dish!\n-Foodhead Community"];
    [successView addSubview:successLabel];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        containerView.alpha = 1.0;
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:2.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [UIView animateWithDuration:0.25 animations:^{
            containerView.alpha = 0.0;
        }completion:^(BOOL finished) {
            [containerView removeFromSuperview];
        }];
    }];
}

- (void)exitSearch{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)dismissKeyboard{
    [self.searchView dismissKeyboard];
}

#pragma mark - BRWSearchViewDelegate

- (void)didSelectResult:(TPLRestaurant *)result{
    if (result) {
        self.currentReview.restaurant_id = result.foursqId;
        self.submitButton.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.submitButton.alpha = 1.0;
        }];
    }else{
        self.currentReview.restaurant_id = nil;
        self.submitButton.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.submitButton.alpha = 0.0;
        }];
    }
}

@end
