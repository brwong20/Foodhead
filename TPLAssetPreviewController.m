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

#import "GPUImage.h"

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

@end

@implementation TPLAssetPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tabBarController.tabBar setHidden:YES];
    
    [self setupUI];
}

- (void)setupUI{
    self.assetImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.assetImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.assetImageView setImage:self.currentReview.image];
    [self.view addSubview:self.assetImageView];
    
    //Custom rating filters
    self.filterView = [[TPLFilterScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.94)  andImage:self.currentReview.image];
    [self.filterView loadFilters];
    self.filterView.scrollDelegate = self;
    [self.view addSubview:self.filterView];
    
    self.saveButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.height * 0.03, CGRectGetMaxY(self.filterView.frame), self.view.frame.size.height * 0.06, self.view.frame.size.height * 0.06)];
    self.saveButton.backgroundColor = [UIColor clearColor];
    [self.saveButton setImage:[UIImage imageNamed:@"save_shot_btn"] forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    
    self.submitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.9 - self.view.frame.size.height * 0.03, CGRectGetMaxY(self.filterView.frame), self.view.frame.size.height * 0.06, self.view.frame.size.height * 0.06)];
    self.submitButton.backgroundColor = [UIColor clearColor];
    [self.submitButton setImage:[UIImage imageNamed:@"next_step_btn"] forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(submitReview) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.submitButton aboveSubview:self.filterView];
    
    self.exitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.1 - self.view.frame.size.height * 0.03, CGRectGetMaxY(self.filterView.frame), self.view.frame.size.height * 0.06, self.view.frame.size.height * 0.06)];
    self.exitButton.backgroundColor = [UIColor clearColor];
    [self.exitButton setImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [self.exitButton addTarget:self action:@selector(exitPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.exitButton aboveSubview:self.filterView];

}

- (void)exitPreview{
    [UIView animateWithDuration:0.2 animations:^{
        AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        appDel.tabBarController.tabBar.alpha = 1.0;
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (void)submitReview{
    RestaurantSearchViewController *searchVC = [[RestaurantSearchViewController alloc]init];
    searchVC.currentReview = self.currentReview;
    [self.navigationController pushViewController:searchVC animated:NO];
}


//Should be a method of filter scrollview or TPLFilter and apply filter to image based on enum.

- (void)saveImage{
    UIImageWriteToSavedPhotosAlbum(self.currentReview.image, nil, nil, nil);
}

/*
- (void)applyFilter{
    GPUImagePicture *original = [[GPUImagePicture alloc]initWithImage:self.currentReview.image];
    UIImage *swtFilterImg = [self filterImage:original withLookUpImgName:@"yummer4"];
    [self.assetImageView setImage:swtFilterImg];
}

- (UIImage *)filterImage:(GPUImagePicture *)originalImage withLookUpImgName:(NSString *)lutName
{
    GPUImagePicture *lookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:lutName]];
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    //lookupFilter.intensity = 1.0;
    
    [originalImage addTarget:lookupFilter];
    [lookupImageSource addTarget:lookupFilter];
    
    [lookupFilter useNextFrameForImageCapture];
    [originalImage processImage];
    [lookupImageSource processImage];
    
    return [lookupFilter imageFromCurrentFramebufferWithOrientation:self.currentReview.image.imageOrientation];
}
*/

#pragma mark ScrollViewDelegate methods

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


@end
