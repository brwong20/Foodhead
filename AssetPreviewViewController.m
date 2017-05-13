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
    
    //Load the lower res image first while waiting for full res to load. Set the frame to match the image as well so it's not fullscreen in case user cancels loading.
    [self.imageView setImage:self.placeHolderImg];
    [self resizeImageFrame];
    
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
    [self.imageView setPin_updateWithProgress:YES];
    [self.imageView pin_setImageFromURL:self.currentImgURL completion:^(PINRemoteImageManagerResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resizeImageFrame];
        });
    }];
}

//Resize frame based on image's aspect ratio (for animation purposes)
- (void)resizeImageFrame{
    float widthRatio = _imageView.bounds.size.width / _imageView.image.size.width;
    float heightRatio = _imageView.bounds.size.height / _imageView.image.size.height;
    float scale = MIN(widthRatio, heightRatio);
    float imageWidth = scale * _imageView.image.size.width;
    float imageHeight = scale * _imageView.image.size.height;
    
    self.imageView.frame = CGRectMake(APPLICATION_FRAME.size.width/2 - imageWidth/2, APPLICATION_FRAME.size.height/2 - imageHeight/2, imageWidth, imageHeight);
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}

@end
