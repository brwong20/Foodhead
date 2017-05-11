//
//  AssetPreviewViewController.m
//  Joyspace
//
//  Created by Amir Hizkiya on 6/5/15.
//  Copyright (c) 2015 Taplet Inc. All rights reserved.
//

#import "AssetPreviewViewController.h"
#import "FoodWiseDefines.h"
#import "UIDeviceHardware.h"

#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

@interface AssetPreviewViewController()


@end

@implementation AssetPreviewViewController


-(instancetype)initWithIndex:(NSUInteger)index andAsset:(PHAsset*)asset
{
    self = [super init];
    if (self) {
        _pageindex = index;
        _currentAsset = asset;
        
        // DLog(@"inited with page and asset");
    }
    return self;
}

-(instancetype)initWithIndex:(NSUInteger)index andImageURL:(NSURL *)imgURL withPlaceHolder:(UIImage *)placeholder{
    self = [super init];
    if (self) {
        _pageindex = index;
        _currentImgURL = imgURL;
        _placeHolderImg = placeholder;
        
        // DLog(@"inited with page and asset");
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, APPLICATION_FRAME.size.width, APPLICATION_FRAME.size.height)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    self.imageView.backgroundColor = [UIColor clearColor];
    
    //First lets setup the imageview
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView setClipsToBounds:YES];
    
    [self.view addSubview:self.imageView];
    
#warning USE THIS LOGIC TO GET SMALLER URLS FOR SMALLER DEVICES
    
//    CGFloat appFrameWidth;
//    CGFloat appFrameHeight;
//
//    
    //If we are a 4s then we load a smaller version if the image for resource constraintes
    //else we load an image slightly bigger then the screen for quality
//    if ([UIDeviceHardware isDeviceiPhone4s]) {
//        appFrameWidth = APPLICATION_FRAME.size.width*0.75;
//        appFrameHeight = APPLICATION_FRAME.size.height*0.75;
//    }
//    else
//    {
//        appFrameWidth = APPLICATION_FRAME.size.width*1.5;
//        appFrameHeight = APPLICATION_FRAME.size.height*1.5;
//    }
//    
//    
//    CGSize previewSize;
//    if (appFrameWidth > appFrameHeight){
//        previewSize = CGSizeMake(appFrameWidth , appFrameWidth);
//    } else {
//        previewSize = CGSizeMake(appFrameHeight , appFrameHeight);
//    }
    
    if (self.currentImgURL) {
        [self loadImageFromURL];
    }
}


- (void)loadImageFromURL{
    [self.imageView setImage:self.placeHolderImg];//Load lower res image first while waiting for higher one to download
    
    [self.imageView setPin_updateWithProgress:YES];
    [self.imageView pin_setImageFromURL:self.currentImgURL completion:^(PINRemoteImageManagerResult * _Nonnull result) {
        
        //Resize frame based on downloaded image's aspect ratio
        float widthRatio = _imageView.bounds.size.width / _imageView.image.size.width;
        float heightRatio = _imageView.bounds.size.height / _imageView.image.size.height;
        float scale = MIN(widthRatio, heightRatio);
        float imageWidth = scale * _imageView.image.size.width;
        float imageHeight = scale * _imageView.image.size.height;
        
        self.imageView.frame = CGRectMake(APPLICATION_FRAME.size.width/2 - imageWidth/2, APPLICATION_FRAME.size.height/2 - imageHeight/2, imageWidth, imageHeight);
    }];
}

-(void)displayImage:(UIImage*)assetImage
{
    //Remove stale imageView if needed
//    if (_imageView && self.imageView.window) {
//        [self.imageView removeFromSuperview];
//    }
    
    //Setup frame for Orientation and aspect ration
    //CGRect imageFrame = AVMakeRectWithAspectRatioInsideRect(assetImage.size, APPLICATION_FRAME);
    
//    if (assetImage.size.width > assetImage.size.height) {
//        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        self.imageView.frame = CGRectMake(0, 0, CGRectGetHeight(APPLICATION_FRAME), CGRectGetWidth(APPLICATION_FRAME));
//        self.view.frame = CGRectMake(0, 0, CGRectGetHeight(APPLICATION_FRAME), CGRectGetWidth(APPLICATION_FRAME));
//        
//        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
//        self.view.center = CGPointMake(CGRectGetWidth(APPLICATION_FRAME)/2, CGRectGetHeight(APPLICATION_FRAME)/2);
//        [self.imageView setCenter:CGPointMake(CGRectGetHeight(APPLICATION_FRAME)/2, CGRectGetWidth(APPLICATION_FRAME)/2)];
//    }
//    else
//    {
//        [self.imageView setCenter:CGPointMake(CGRectGetMidX(APPLICATION_FRAME), CGRectGetMidY(APPLICATION_FRAME))];
//    }
    
    [self.imageView setCenter:CGPointMake(CGRectGetMidX(APPLICATION_FRAME), CGRectGetMidY(APPLICATION_FRAME))];
    
    [self.imageView setImage:assetImage];
    
    //Tag cannot be Zero!!!
    [self.imageView setTag:[self.currentAsset hash]];
    
    //[self.view addSubview:self.imageView];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}

@end
