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

#import "GPUImage.h"

@interface TPLAssetPreviewController ()

@property (nonatomic, strong) UIImageView *assetImageView;

//UI Controls
@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, strong) UIButton *filterButton;

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

}

- (void)setupUI{
    self.assetImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.assetImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.assetImageView setImage:self.selectedImage];
    [self.view addSubview:self.assetImageView];
    
    self.filterButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2.0 - 20.0, self.view.frame.size.height * 0.9, 40.0, 40.0)];
    self.filterButton.backgroundColor = [UIColor clearColor];
    [self.filterButton setImage:[UIImage imageNamed:@"gallery-save"] forState:UIControlStateNormal];
    [self.filterButton addTarget:self action:@selector(applyFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.filterButton];
    
    self.exitButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 15, 50, 50)];
    self.exitButton.backgroundColor = [UIColor clearColor];
    [self.exitButton setImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [self.exitButton addTarget:self action:@selector(exitPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.exitButton belowSubview:self.filterButton];
    
    BRWSearchView *searchView = [[BRWSearchView alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - self.view.frame.size.width * 0.4, self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.8, 50.0)];
    searchView.resultCellHeight = 44.0;
    [self.view addSubview:searchView];
}

- (void)exitPreview{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)setupFilters{
    self.filterView = [[TPLFilterScrollView alloc]initWithFrame:self.view.frame andImage:self.selectedImage];
    [self.view insertSubview:self.filterView belowSubview:self.exitButton];
}

//Should be a method of filter scrollview or TPLFilter and apply filter to image based on enum.
- (void)applyFilter{
    
    GPUImagePicture *original = [[GPUImagePicture alloc]initWithImage:self.selectedImage];
    UIImage *swtFilterImg = [self filterImage:original withLookUpImgName:@"yum4"];
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
    
    return [lookupFilter imageFromCurrentFramebufferWithOrientation:self.selectedImage.imageOrientation];
}


@end
