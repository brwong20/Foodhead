//
//  AssetPreviewViewController.m
//  Joyspace
//
//  Created by Amir Hizkiya on 6/5/15.
//  Copyright (c) 2015 Taplet Inc. All rights reserved.
//

#import "AssetPreviewViewController.h"
#import "UIDeviceHardware.h"

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

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    _imageView = [[UIImageView alloc] initWithFrame:ASSET_FRAME];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    //First lets setup the imageview
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView setClipsToBounds:YES];
    
    
    CGFloat appFrameWidth;
    CGFloat appFrameHeight;
    
    //If we are a 4s then we load a smaller version if the image for resource constraintes
    //else we load an image slightly bigger then the screen for quality
    if ([UIDeviceHardware isDeviceiPhone4s]) {
        appFrameWidth = APPLICATION_FRAME.size.width*0.75;
        appFrameHeight = APPLICATION_FRAME.size.height*0.75;
    }
    else
    {
        appFrameWidth = APPLICATION_FRAME.size.width*1.5;
        appFrameHeight = APPLICATION_FRAME.size.height*1.5;
    }
    
    
    CGSize previewSize;
    if (appFrameWidth > appFrameHeight){
        previewSize = CGSizeMake(appFrameWidth , appFrameWidth);
    } else {
        previewSize = CGSizeMake(appFrameHeight , appFrameHeight);
    }
    
    //Set up the option
    PHImageRequestOptions *options = [self getOptionsForClass];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;
    if (self.currentAsset != nil) {
        [[PHImageManager defaultManager] requestImageForAsset:self.currentAsset targetSize:previewSize
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:options
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
//                                                    if (result) {
                                                        [self performSelectorOnMainThread:@selector(displayImage:) withObject:result waitUntilDone:NO];
                                                        
//                                                    }
                                                }];
    }
}

-(PHImageRequestOptions*)getOptionsForClass
{
    PHImageRequestOptions *options =[[PHImageRequestOptions alloc] init];
    
    //If we are dealing with a video its complicated to load async
    if (self.currentAsset.mediaType == PHAssetMediaTypeVideo) {
        options.synchronous = YES;
    } else {
        options.synchronous = NO;
    }
    
    return options;
}

-(void)displayImage:(UIImage*)assetImage
{
    //Remove stale imageView if needed
    if (_imageView && self.imageView.window) {
        [self.imageView removeFromSuperview];
    }
    
    //Setup frame for Orientation and aspect ration
    //CGRect imageFrame = AVMakeRectWithAspectRatioInsideRect(assetImage.size, APPLICATION_FRAME);
    
    //Allocate new imageview and setup
    if (self.currentAsset.mediaType == PHAssetMediaTypeVideo) {
        if (assetImage.size.height > assetImage.size.width * 1.25) {
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
            self.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
        }
        else{
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.videoGravity = AVLayerVideoGravityResizeAspect;
        }
    }

    if (assetImage.size.width > assetImage.size.height) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.frame = CGRectMake(0, 0, CGRectGetHeight(APPLICATION_FRAME), CGRectGetWidth(APPLICATION_FRAME));
        self.view.frame = CGRectMake(0, 0, CGRectGetHeight(APPLICATION_FRAME), CGRectGetWidth(APPLICATION_FRAME));
        
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.view.center = CGPointMake(CGRectGetWidth(APPLICATION_FRAME)/2, CGRectGetHeight(APPLICATION_FRAME)/2);
        [self.imageView setCenter:CGPointMake(CGRectGetHeight(APPLICATION_FRAME)/2, CGRectGetWidth(APPLICATION_FRAME)/2)];
    }
    else
    {
        [self.imageView setCenter:CGPointMake(CGRectGetMidX(APPLICATION_FRAME), CGRectGetMidY(APPLICATION_FRAME))];
    }
    
    [self.imageView setImage:assetImage];
    
    
    //Tag cannot be Zero!!!
    [self.imageView setTag:[self.currentAsset hash]];
    
    [self.view addSubview:self.imageView];
    
    if (self.currentAsset.mediaType == PHAssetMediaTypeVideo) {
        //Start the video
        [[PHImageManager defaultManager] requestAVAssetForVideo:self.currentAsset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.playerLayer) {
                    
                    //CGSize videoTrackSize = CGSizeZero;
                    if ([avAsset isKindOfClass:[AVURLAsset class]]) {
                        self.videoURL = [(AVURLAsset*)avAsset URL];
                        //NSArray *tracks = [(AVURLAsset*)avAsset tracksWithMediaType:AVMediaTypeVideo];
                        //videoTrackSize = [(AVAssetTrack*)[tracks objectAtIndex:0] naturalSize];
                    }
                    
                    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
                    playerItem.audioMix = audioMix;
                    self.videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
                    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
                    self.playerLayer.videoGravity = self.videoGravity;
                
                    float playDelay = 0.3f;
                    if ([UIDeviceHardware isDeviceiPhone4s])
                    {
                        playDelay = 0.5f;
                    }
                    
//                    for (AVMetadataItem * meta in avAsset.metadata) {
//                        DLog(@"%@",meta);
//                    }

                    //Give the video time to load
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(playDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        CALayer *layer = self.view.layer;
                        [layer addSublayer:self.playerLayer];
                        [self.playerLayer setFrame:ASSET_FRAME];
                        
                        
                        if (assetImage.size.width > assetImage.size.height) {
                            //self.playerLayer.videoGravity = UIViewContentModeScaleAspectFit;
                            self.playerLayer.frame = CGRectMake(0, 0, CGRectGetHeight(APPLICATION_FRAME), CGRectGetWidth(APPLICATION_FRAME));
                            //self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                        }
                        
                        [self.videoPlayer play];
                    });
                    
                }
            });
        }];
    }
    
}

-(void)dealloc
{
//    if(self.videoPlayer)
//        [self.videoPlayer removeObserver:self forKeyPath:@"status"];
    
}

-(NSObject*)getAssetObjectToShare
{
    NSObject* objectToReturn;
    
    if (_currentAsset.mediaType == PHAssetMediaTypeVideo) {
        objectToReturn = self.videoURL;
    }
    else if (_currentAsset.mediaType == PHAssetMediaTypeImage) {
        objectToReturn = self.imageView.image;
    }
    
    return objectToReturn;
}

+ (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}

-(void)updateViewsForRotation
{
    //Setup frame for Orientation and aspect ration
    CGRect imageFrame = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size, APPLICATION_FRAME);
    
    //Allocate new imageview and setup
    self.imageView.frame =  imageFrame;
    [self.imageView setCenter:CGPointMake(CGRectGetMidX(APPLICATION_FRAME), CGRectGetMidY(APPLICATION_FRAME))];
    
    //Only if its a video we have a player layer
    if (self.playerLayer && self.playerLayer.superlayer) {
        self.playerLayer.frame = APPLICATION_FRAME;
    }
}

#pragma mark KVO methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.videoPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.videoPlayer.status == AVPlayerStatusReadyToPlay) {
            
            float playDelay = 0.1f;
            
            if ([UIDeviceHardware isDeviceiPhone4s])
            {
                playDelay = 0.3f;
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(playDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CALayer *layer = self.view.layer;
                [layer addSublayer:self.playerLayer];
                [self.playerLayer setFrame:ASSET_FRAME];
                
                [self.videoPlayer play];
            });
            
        } else if (self.videoPlayer.status == AVPlayerStatusFailed) {
            DLog(@"AVPlayerStatusFailed");
        }
    }
}

#pragma mark Operating System delegate methods
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Code here will execute before the rotation begins.
    
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        //if (self.view.frame.origin.x == 0) {
        [self updateViewsForRotation];
        //}
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Code here will execute after the rotation has finished.
        
    }];
}

@end
