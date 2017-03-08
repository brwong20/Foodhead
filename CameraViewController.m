//
//  CameraViewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/21/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "CameraViewController.h"
#import "TPLAssetPreviewController.h"
#import "CameraFilterScrollView.h"

#import "GPUImage.h"

@interface CameraViewController ()<CameraFilterScrollDelegate>

@property (nonatomic, strong) UIView *screenView;

@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) CameraFilterScrollView *filterScroll;

//Camera Controls
@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) UIButton *albumButton;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupCamera];
    [self setupCameraControls];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (self.stillCamera) {
        [self.stillCamera startCameraCapture];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.stillCamera stopCameraCapture];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)setupCamera{
    CGRect mainScreenFrame = [[UIScreen mainScreen]bounds];
    
    //self.screenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainScreenFrame.size.width, mainScreenFrame.size.height)];
    
    self.stillCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.stillCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    self.filterScroll = [[CameraFilterScrollView alloc]initWithFrame:mainScreenFrame andStillCamera:self.stillCamera];
    //[self.filterScroll setMultipleTouchEnabled:YES];
    //[self.filterScroll setExclusiveTouch:NO];
    
    [self.view addSubview:self.filterScroll];
    [self.filterScroll setupFilters];
    
    [self.stillCamera startCameraCapture];
}

- (void)setupCameraControls{
    self.exitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.08 - self.view.frame.size.width * 0.075, self.view.frame.size.height * 0.93 - self.view.frame.size.width * 0.075, self.view.frame.size.width * 0.15, self.view.frame.size.width * 0.15)];
    self.exitButton.backgroundColor = [UIColor clearColor];
    [self.exitButton setImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [self.exitButton addTarget:self action:@selector(exitCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitButton];
    
    self.albumButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.92 - self.view.frame.size.width * 0.075, CGRectGetMidY(self.exitButton.frame) - self.view.frame.size.width * 0.06, self.view.frame.size.width * 0.12, self.view.frame.size.width * 0.12)];
    self.albumButton.backgroundColor = [UIColor whiteColor];
    self.albumButton.layer.cornerRadius = self.albumButton.frame.size.height/2;
    [self.view addSubview:self.albumButton];
    
    self.captureButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.15, CGRectGetMidY(self.exitButton.frame) - self.view.frame.size.width * 0.15, self.view.frame.size.width * 0.3, self.view.frame.size.width * 0.3)];
    self.captureButton.backgroundColor = [UIColor clearColor];
    [self.captureButton setImage:[UIImage imageNamed:@"capture"]forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(capturePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.captureButton];
    
    //Center these two in between exit/capture and capture/album
    
    self.flashButton = [[UIButton alloc]initWithFrame:CGRectMake((CGRectGetMinX(self.exitButton.frame) + CGRectGetMinX(self.captureButton.frame))/2, CGRectGetMinY(self.exitButton.frame), self.view.frame.size.width * 0.15, self.view.frame.size.width * 0.15)];
    self.flashButton.backgroundColor = [UIColor clearColor];
    [self.flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    [self.flashButton addTarget:self action:@selector(toggleFlash) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    
    self.flipButton = [[UIButton alloc]initWithFrame:CGRectMake((CGRectGetMinX(self.captureButton.frame) + CGRectGetMaxX(self.albumButton.frame))/2, CGRectGetMinY(self.flashButton.frame), self.view.frame.size.width * 0.15, self.view.frame.size.width * 0.15)];
    self.flipButton.backgroundColor = [UIColor clearColor];
    [self.flipButton setImage:[UIImage imageNamed:@"flip_camera"] forState:UIControlStateNormal];
    [self.flipButton addTarget:self action:@selector(flipCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flipButton];
}

- (void)exitCamera{
    [self.stillCamera stopCameraCapture];
    [self.filterScroll clearFilterData];
    [self.navigationController popViewControllerAnimated:NO];
}


//Consider retrieving current filter through the use of a delegate method
- (void)capturePhoto{
    GPUImageFilter *currentFilter = self.filterScroll.currentFilter.gpuFilter ? self.filterScroll.currentFilter.gpuFilter : self.filterScroll.currentFilter.lookupFilter;
    [self.stillCamera capturePhotoAsImageProcessedUpToFilter:currentFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TPLAssetPreviewController *assetVC = [[TPLAssetPreviewController alloc]init];
            assetVC.selectedImage = processedImage;
            [self.navigationController pushViewController:assetVC animated:NO];
        });
    }];
}

- (void)toggleFlash{
    if ([[self.stillCamera inputCamera] isTorchAvailable]) {
        //NSError *error = nil;
    }
    
}

- (void)flipCamera{
    [self.stillCamera rotateCamera];
}

@end
