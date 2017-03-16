//
//  RestaurantSearchViewController.m
//  Foodhead
//
//  Created by Brian Wong on 3/9/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RestaurantSearchViewController.h"

#import "TPLRestaurantManager.h"
#import "BRWSearchView.h"

@interface RestaurantSearchViewController () <BRWSearchViewDelegate>

@property (nonatomic, strong) TPLRestaurantManager *restaurantMngr;

@property (nonatomic, strong) BRWSearchView *searchView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation RestaurantSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.backgroundColor = [UIColor whiteColor];
    [self.imgView setImage:self.currentReview.image];
    [self.view addSubview:self.imgView];
    
    self.searchView = [[BRWSearchView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.4, self.view.frame.size.height * 0.05, self.view.frame.size.width * 0.8, 50.0)];
    self.searchView.delegate = self;
    self.searchView.currentReview = self.currentReview;
    [self.view addSubview:self.searchView];
    
    self.submitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.9, 40.0, 40.0)];
    self.submitButton.backgroundColor = [UIColor clearColor];
    [self.submitButton setImage:[UIImage imageNamed:@"next_step_btn"] forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(submitReview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
    
    self.backButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.1, CGRectGetMidY(self.submitButton.frame) - 20.0, 40.0, 40.0)];
    self.backButton.backgroundColor = [UIColor clearColor];
    [self.backButton setImage:[UIImage imageNamed:@"prev_step_btn"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(exitSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    UITapGestureRecognizer *dismiss = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    dismiss.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismiss];
}

- (void)submitReview{
    if (self.currentReview.restaurant_id) {
        TPLRestaurantManager *restaurantManager = [[TPLRestaurantManager alloc]init];
        NSData *imgData = UIImageJPEGRepresentation(self.currentReview.image, 1.0);
        [restaurantManager submitReviewForRestaurant:self.currentReview.restaurant_id overallRating:[self.currentReview.overall stringValue] healthScore:@"10" price:[self.currentReview.price stringValue] photo:imgData completionHandler:^(id success) {
            
            //Show spinner
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:NO];
            });
            
        } failureHandler:^(id error) {
            
        }];
    }else{
        //Warn user to select restaurant
    }
}

- (void)exitSearch{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)dismissKeyboard{
    [self.searchView dismissKeyboard];
}

#pragma mark - BRWSearchViewDelegate

- (void)didSelectResult:(TPLRestaurant *)result{
    self.currentReview.restaurant_id = [result.restaurantId stringValue];
}

@end
