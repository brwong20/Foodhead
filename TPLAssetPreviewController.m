//
//  TPLAssetPreviewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/5/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLAssetPreviewController.h"
#import "TPLFilterScrollView.h"

@interface TPLAssetPreviewController ()

@property (nonatomic, strong) UIImageView *assetImageView;

//UI Controls
@property (nonatomic, strong) UIButton *exitButton;

//Filters
@property (nonatomic, strong) TPLFilterScrollView *filterView;

@end

@implementation TPLAssetPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    [self setupFilters];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)setupUI{
    self.assetImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.assetImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.assetImageView setImage:self.selectedImage];
    [self.view addSubview:self.assetImageView];
    
    self.exitButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 50, 50, 50)];
    self.exitButton.backgroundColor = [UIColor clearColor];
    [self.exitButton setImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [self.exitButton addTarget:self action:@selector(exitPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitButton];
}

- (void)setupFilters{
    self.filterView = [[TPLFilterScrollView alloc]initWithFrame:self.view.frame];
    [self.view insertSubview:self.filterView belowSubview:self.exitButton];
}

- (void)exitPreview{
    [self.navigationController popViewControllerAnimated:NO];
}


@end
