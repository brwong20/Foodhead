//
//  TabCameraViewController.m
//  Foodhead
//
//  Created by Brian Wong on 3/11/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TabCameraViewController.h"
#import "TPLCameraPreviewView.h"
#import "TPLCamPhotoCaptureDelegate.h"
#import "TPLRestaurant.h"
#import "TPLAssetPreviewController.h"
#import "FoodWiseDefines.h"
#import "LocationManager.h"
#import "RestaurantReview.h"
#import "UserProfileViewController.h"
#import "ChartsViewController.h"
#import "AlbumViewController.h"
#import "FoodheadAnalytics.h"
#import "LayoutBounds.h"

@import AVFoundation;
@import Photos;

static void * SessionRunningContext = &SessionRunningContext;

typedef NS_ENUM( NSInteger, AVCamSetupResult ) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

typedef NS_ENUM( NSInteger, AVCamCaptureMode ) {
    AVCamCaptureModePhoto = 0,
    AVCamCaptureModeMovie = 1
};

typedef NS_ENUM( NSInteger, AVCamLivePhotoMode ) {
    AVCamLivePhotoModeOn,
    AVCamLivePhotoModeOff
};

//Categories to keep track of how many capture devices a user has
@interface AVCaptureDeviceDiscoverySession (Utilities)

- (NSInteger)uniqueDevicePositionsCount;

@end

@implementation AVCaptureDeviceDiscoverySession (Utilities)

- (NSInteger)uniqueDevicePositionsCount
{
    NSMutableArray<NSNumber *> *uniqueDevicePositions = [NSMutableArray array];
    
    for ( AVCaptureDevice *device in self.devices ) {
        if ( ! [uniqueDevicePositions containsObject:@(device.position)] ) {
            [uniqueDevicePositions addObject:@(device.position)];
        }
    }
    
    return uniqueDevicePositions.count;
}

@end

@interface TabCameraViewController () <AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate>

//Session management
@property (nonatomic, strong) TPLCameraPreviewView *previewView;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, assign) BOOL sessionRunning;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) UILabel *cameraUnavailableLabel;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;

//Camera Controls
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *albumButton;
@property (nonatomic, strong) UIButton *orientationButton;

//Orientation
@property (nonatomic) AVCaptureDeviceDiscoverySession *videoDeviceDiscoverySession;

//Gesture Recognizers
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchToZoom;
@property (nonatomic, strong) UITapGestureRecognizer *tapToFocus;
@property (nonatomic, strong) UIImageView *focusView;

//Photo properties
@property (nonatomic) AVCamLivePhotoMode livePhotoMode;
@property (nonatomic, strong) UILabel *capturingLivePhotoLabel;

@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic) AVCapturePhotoOutput *photoOutput;
@property (nonatomic) NSMutableDictionary<NSNumber *, TPLCamPhotoCaptureDelegate*> *inProgressPhotoCaptureDelegates;
@property (nonatomic) NSInteger inProgressLivePhotoCapturesCount;

//Video recording
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *resumeButton;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

//Asset Preview
@property (nonatomic, strong) UIImage *selectedPhoto;
@property (nonatomic, strong) TPLAssetPreviewController *assetPreviewController;

//Tooltip
@property (nonatomic, strong) UIImageView *camTooltip;

@end

@implementation TabCameraViewController

#define MIN_ZOOM 1
#define MAX_ZOOM 4

dispatch_queue_t sessionQueue;

static CGFloat previousZoom;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCameraControls];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //Only enable UI when session is running
    self.captureButton.enabled = NO;
    self.flashButton.enabled = NO;
    self.orientationButton.enabled = NO;
    self.cancelButton.enabled = NO;
    
    self.captureSession = [[AVCaptureSession alloc]init];
    
    //For iPhone 7
    NSArray<AVCaptureDeviceType> *deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInDuoCamera];
    self.videoDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    
    self.previewView.session = self.captureSession;
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.setupResult = AVCamSetupResultSuccess;
    
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
            //Authorized, continue with sessionQueue
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            dispatch_suspend(self.sessionQueue);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    self.setupResult = AVCamSetupResultCameraNotAuthorized;
                }
                dispatch_resume(self.sessionQueue);
            }];
            break;
        }
        case AVAuthorizationStatusRestricted:
            
        default:
            self.setupResult = AVCamSetupResultCameraNotAuthorized;
            break;
    }
    
    //[self checkAlbumAuth];
    
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
    
    dispatch_async(self.sessionQueue, ^{
        switch (self.setupResult) {
            case AVCamSetupResultSuccess:{
                [self addObservers];
                [self.captureSession startRunning];
                self.sessionRunning = self.captureSession.running;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showCameraTooltip];
                });
                break;
            }
            case AVCamSetupResultCameraNotAuthorized:{
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSString *message = @"Foodhead doesn't have permission to use the camera, please change your privacy settings!";
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Camera Permission" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    // Provide quick access to Settings.
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                    }];
                    [alertController addAction:settingsAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;
                
            }
            case AVCamSetupResultSessionConfigurationFailed:
            {
                NSLog(@"Camera configuration failed");
                break;
            }
            default:
                break;
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:YES];
    //[self loadLastPhoto];
}


//Only stop the camera from running when the user quits the app
- (void)dealloc{
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult == AVCamSetupResultSuccess ) {
            [self.captureSession stopRunning];
            [self removeObservers];
        }
    });
}

- (void)configureSession{
    if (self.setupResult != AVCamSetupResultSuccess) {
        return;
    }

    NSError *error = nil;
    [self.captureSession beginConfiguration];
    
    /*
     We do not create an AVCaptureMovieFileOutput when setting up the session because the
     AVCaptureMovieFileOutput does not support movie recording with AVCaptureSessionPresetPhoto.
     */
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    self.flashMode = AVCaptureFlashModeOff;//Default flash
    
    // Choose the back dual camera if available, otherwise default to a wide angle camera.
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDuoCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    if ( ! videoDevice ) {
        // If the back dual camera is not available, default to the back wide angle camera.
        videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        
        // In some cases where users break their phones, the back wide angle camera is not available. In this case, we should default to the front wide angle camera.
        if ( ! videoDevice ) {
            videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }
    }
    self.captureDevice = videoDevice;
    
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if ( ! videoDeviceInput ) {
        NSLog( @"Could not create video device input: %@", error );
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    if ( [self.captureSession canAddInput:videoDeviceInput] ) {
        [self.captureSession addInput:videoDeviceInput];
        self.videoDeviceInput = videoDeviceInput;
        
        dispatch_async( dispatch_get_main_queue(), ^{
            /*
             Why are we dispatching this to the main queue?
             Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView
             can only be manipulated on the main thread.
             Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
             on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
             
             Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
             handled by -[AVCamCameraViewController viewWillTransitionToSize:withTransitionCoordinator:].
             */
            UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
            if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
            }
            
            self.previewView.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation;
        } );
    }
    else {
        NSLog( @"Could not add video device input to the session" );
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    
    // Add audio input.
//    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
//    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
//    if ( ! audioDeviceInput ) {
//        NSLog( @"Could not create audio device input: %@", error );
//    }
//    if ( [self.captureSession canAddInput:audioDeviceInput] ) {
//        [self.captureSession addInput:audioDeviceInput];
//    }
//    else {
//        NSLog( @"Could not add audio device input to the session" );
//    }
    
    // Add photo output.
    AVCapturePhotoOutput *photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ( [self.captureSession canAddOutput:photoOutput] ) {
        [self.captureSession addOutput:photoOutput];
        self.photoOutput = photoOutput;
        
        self.photoOutput.highResolutionCaptureEnabled = YES;
        self.photoOutput.livePhotoCaptureEnabled = self.photoOutput.livePhotoCaptureSupported;
        //self.livePhotoMode = self.photoOutput.livePhotoCaptureSupported ? AVCamLivePhotoModeOn : AVCamLivePhotoModeOff;
        
        self.inProgressPhotoCaptureDelegates = [NSMutableDictionary dictionary];
        //self.inProgressLivePhotoCapturesCount = 0;
    }
    else {
        NSLog( @"Could not add photo output to the session" );
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    
    //self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    [self.captureSession commitConfiguration];
}

- (void)setupCameraControls
{
    CGRect bounds = self.view.bounds;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.previewView = [[TPLCameraPreviewView alloc]init];
    self.previewView.bounds = bounds;
    self.previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewView.videoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    [self.view addSubview:self.previewView];
    
    self.captureButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.height * 0.06, self.view.frame.size.height * 0.86, self.view.frame.size.height * 0.14, self.view.frame.size.height * 0.14)];
    self.captureButton.backgroundColor = [UIColor clearColor];
    self.captureButton.contentMode = UIViewContentModeCenter;
    [self.captureButton setImage:[UIImage imageNamed:@"camera_take_btn"] forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.captureButton];
    
    self.flashButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1)];
    self.flashButton.center = CGPointMake(self.view.frame.size.width - self.view.frame.size.height * 0.05, CGRectGetMidY(self.captureButton.frame));
    self.flashButton.backgroundColor = [UIColor clearColor];
    [self.flashButton setImage:[[UIImage imageNamed:@"camera_flash_off"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.flashButton addTarget:self action:@selector(toggleFlashMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    
    self.cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1)];
    self.cancelButton.center = CGPointMake(self.view.frame.size.height * 0.05, CGRectGetMidY(self.captureButton.frame));
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setImage:[UIImage imageNamed:@"camera_exit_btn"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(exitCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
    self.orientationButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height * 0.08, self.view.frame.size.height * 0.08)];
    self.orientationButton.center = CGPointMake(CGRectGetMidX(self.cancelButton.frame) - self.view.frame.size.height * 0.01, self.view.frame.size.height * 0.07);
    self.orientationButton.backgroundColor = [UIColor clearColor];
    [self.orientationButton setImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
    [self.orientationButton addTarget:self action:@selector(changeOrientation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.orientationButton];
    
//    self.albumButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height * 0.06, self.view.frame.size.height * 0.06)];
//    self.albumButton.center = CGPointMake(CGRectGetMaxX(self.orientationButton.frame) + self.view.frame.size.width * 0.07, CGRectGetMidY(self.captureButton.frame));
//    self.albumButton.backgroundColor = [UIColor whiteColor];
//    self.albumButton.layer.cornerRadius = self.albumButton.frame.size.height/2;
//    self.albumButton.clipsToBounds = YES;
//    [self.albumButton addTarget:self action:@selector(openAlbum) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.albumButton];
    
    self.pinchToZoom = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchToZoomRecognizer:)];
    [self.view addGestureRecognizer:self.pinchToZoom];
    
//    self.focusView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1)];
//    self.focusView.backgroundColor = [UIColor clearColor];
//    self.focusView.contentMode = UIViewContentModeScaleAspectFit;
//    self.focusView.alpha = 0.0;
//    [self.focusView setImage:[UIImage imageNamed:@"auto_focus"]];
//    [self.view addSubview:self.focusView];
    
    self.tapToFocus = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusAndExposeTap:)];
    [self.view addGestureRecognizer:self.tapToFocus];    
}

- (void)showCameraTooltip{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:CAMERA_CAPTURE_TOOLTIP]) {
        self.camTooltip = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.captureButton.frame) - self.view.frame.size.width * 0.4, CGRectGetMinY(self.captureButton.frame) - self.view.frame.size.height * 0.45, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.5)];
        self.camTooltip.backgroundColor = [UIColor clearColor];
        self.camTooltip.contentMode = UIViewContentModeScaleAspectFit;
        [self.camTooltip setImage:[UIImage imageNamed:@"tooltip_camera"]];
        [self.view addSubview:self.camTooltip];
        
        UITapGestureRecognizer *dismissTooltip = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissCameraTip)];
        dismissTooltip.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:dismissTooltip];
    }
}

- (void)dismissCameraTip{
    if ([self.camTooltip superview]) {
        [self.camTooltip removeFromSuperview];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:CAMERA_CAPTURE_TOOLTIP];
    }
}

#pragma mark - Camera orientation

- (void)changeOrientation:(id)sender
{
    self.captureButton.enabled = NO;
    self.flashButton.enabled = NO;
    self.cancelButton.enabled = NO;
    
    dispatch_async( self.sessionQueue, ^{
        AVCaptureDevice *currentVideoDevice = self.videoDeviceInput.device;
        AVCaptureDevicePosition currentPosition = currentVideoDevice.position;
        
        AVCaptureDevicePosition preferredPosition;
        AVCaptureDeviceType preferredDeviceType;
        
        switch ( currentPosition )
        {
            case AVCaptureDevicePositionUnspecified:
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                preferredDeviceType = AVCaptureDeviceTypeBuiltInDuoCamera;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                preferredDeviceType = AVCaptureDeviceTypeBuiltInWideAngleCamera;
                break;
        }
        
        NSArray<AVCaptureDevice *> *devices = self.videoDeviceDiscoverySession.devices;
        AVCaptureDevice *newVideoDevice = nil;
        
        // First, look for a device with both the preferred position and device type.
        for ( AVCaptureDevice *device in devices ) {
            if ( device.position == preferredPosition && [device.deviceType isEqualToString:preferredDeviceType] ) {
                newVideoDevice = device;
                break;
            }
        }
        
        // Otherwise, look for a device with only the preferred position.
        if ( ! newVideoDevice ) {
            for ( AVCaptureDevice *device in devices ) {
                if ( device.position == preferredPosition ) {
                    newVideoDevice = device;
                    break;
                }
            }
        }
        
        if ( newVideoDevice ) {
            AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newVideoDevice error:NULL];
            
            [self.captureSession beginConfiguration];
            
            // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
            [self.captureSession removeInput:self.videoDeviceInput];
            
            
            if ( [self.captureSession canAddInput:videoDeviceInput] ) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:newVideoDevice];
                
                [self.captureSession addInput:videoDeviceInput];
                self.videoDeviceInput = videoDeviceInput;
            }
            else {
                [self.captureSession addInput:self.videoDeviceInput];
            }
            
            AVCaptureConnection *movieFileOutputConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ( movieFileOutputConnection.isVideoStabilizationSupported ) {
                movieFileOutputConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            
            /*
             Set Live Photo capture enabled if it is supported. When changing cameras, the
             `livePhotoCaptureEnabled` property of the AVCapturePhotoOutput gets set to NO when
             a video device is disconnected from the session. After the new video device is
             added to the session, re-enable Live Photo capture on the AVCapturePhotoOutput if it is supported.
             */
            self.photoOutput.livePhotoCaptureEnabled = self.photoOutput.livePhotoCaptureSupported;
            
            //All devices under 6s don't have front flash so just hide for now and disable flash
            if(!newVideoDevice.flashAvailable){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.flashButton setEnabled:NO];
                    [self.flashButton setHidden:YES];
                    self.flashMode = AVCaptureFlashModeOff;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.flashButton setEnabled:YES];
                    [self.flashButton setHidden:NO];
                    [self setupFlashButtonForMode:self.flashMode];
                });
            }
            
            [self.captureSession commitConfiguration];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            self.captureButton.enabled = YES;
            self.orientationButton.enabled = YES;
            self.cancelButton.enabled = YES;
            self.flashButton.enabled = YES;
        } );
    } );
}

#pragma mark - Focus, Zoom, Flash

- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint gesturePt = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint devicePoint = [self.previewView.videoPreviewLayer captureDevicePointOfInterestForPoint:gesturePt];
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect focusFrame = self.focusView.frame;
//        focusFrame.origin.x = gesturePt.x;
//        focusFrame.origin.y = gesturePt.y;
//        self.focusView.frame = focusFrame;
//        self.focusView.alpha = 1.0;
//    }completion:^(BOOL finished) {
//        self.focusView.alpha = 0.0;
//    }];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async( self.sessionQueue, ^{
        AVCaptureDevice *device = self.videoDeviceInput.device;
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            /*
             Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
             Call set(Focus/Exposure)Mode() to apply the new point of interest.
             */
            if ( device.isFocusPointOfInterestSupported && [device isFocusModeSupported:focusMode] ) {
                device.focusPointOfInterest = point;
                device.focusMode = focusMode;
            }
            
            if ( device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode] ) {
                device.exposurePointOfInterest = point;
                device.exposureMode = exposureMode;
            }
            
            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    } );
}

-(void) handlePinchToZoomRecognizer:(UIPinchGestureRecognizer*)gestureRecognizer {
    //If we are just starting the guesture, then lets reset
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        previousZoom = (gestureRecognizer.scale - 1);
    }
    
    //Guesture should be rounded and zero based
    CGFloat gestureScale =  (gestureRecognizer.scale - 1);
    float currentZoomScale = self.captureDevice.videoZoomFactor;
    float deltaZoom = 0;
    
    //now we need to get the delta
    deltaZoom = gestureScale - previousZoom;
    previousZoom = gestureScale;
    
    if (currentZoomScale + deltaZoom > MIN_ZOOM && currentZoomScale + deltaZoom < MAX_ZOOM)
    {
        [self setZoomScale:currentZoomScale + deltaZoom];
    }
    else if (currentZoomScale + gestureScale < MIN_ZOOM)
    {
        [self setZoomScale:MIN_ZOOM];
    }
    else if (currentZoomScale + gestureScale > MAX_ZOOM)
    {
        [self setZoomScale:MAX_ZOOM];
    }
}

- (void)setZoomScale:(CGFloat)zoomScale
{
    if ([self.captureDevice respondsToSelector:@selector(setVideoZoomFactor:)]
        && self.captureDevice.activeFormat.videoMaxZoomFactor >= zoomScale
        && zoomScale > 1) {
        if ([self.captureDevice lockForConfiguration:nil]) {
            [self.captureDevice setVideoZoomFactor:zoomScale];
            [self.captureDevice unlockForConfiguration];
        }
    }
}

- (void)toggleFlashMode
{
    AVCaptureDevice *device = self.captureDevice;
    if (device.isFlashAvailable) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            switch (self.flashMode) {
                case AVCaptureFlashModeOff: {
                    [FoodheadAnalytics logEvent:CAMERA_FLASH_ENABLED];
                    self.flashMode = AVCaptureFlashModeOn;
                    [self setupFlashButtonForMode:AVCaptureFlashModeOn];
                    break;
                }
                case AVCaptureFlashModeOn: {
                    self.flashMode = AVCaptureFlashModeOff;
                    [self setupFlashButtonForMode:AVCaptureFlashModeOff];
                    break;
                }
                case AVCaptureFlashModeAuto: {
                    //                    self.flashMode = AVCaptureFlashModeOn;
                    //                    [self setupFlashButtonForMode:AVCaptureFlashModeOn];
                    break;
                }
            }
            [device unlockForConfiguration];
        } else {
            NSLog(@"Error toggling flash : %@", error);
        }
    }
}

- (void)setupFlashButtonForMode:(AVCaptureFlashMode)flashMode
{
    switch (flashMode) {
        case AVCaptureFlashModeOn:
            [self.flashButton setImage:[UIImage imageNamed:@"camera_flash_enable"] forState:UIControlStateNormal];
            break;
        case AVCaptureFlashModeOff:
            [self.flashButton setImage:[UIImage imageNamed:@"camera_flash_off"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}


#pragma mark Capturing Photos

- (void)capturePhoto:(id)sender
{
    /*
     Retrieve the video preview layer's video orientation on the main queue before
     entering the session queue. We do this to ensure UI elements are accessed on
     the main thread and session configuration is done on the session queue.
     */
    AVCaptureVideoOrientation videoPreviewLayerVideoOrientation = self.previewView.videoPreviewLayer.connection.videoOrientation;
    [FoodheadAnalytics logEvent:CAMERA_CAPTURE];
    dispatch_async(self.sessionQueue, ^{
        
        [self dismissCameraTip];
        
        // Update the photo output's connection to match the video orientation of the video preview layer.
        AVCaptureConnection *photoOutputConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
        photoOutputConnection.videoOrientation = videoPreviewLayerVideoOrientation;
        
        // Capture a JPEG photo with flash set to auto and high resolution photo enabled.
        AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
        photoSettings.flashMode = self.flashMode;
        photoSettings.highResolutionPhotoEnabled = YES;
        if ( photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0 ) {
            photoSettings.previewPhotoFormat = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : photoSettings.availablePreviewPhotoPixelFormatTypes.firstObject };
        }
        
        // Use a separate object for the photo capture delegate to isolate each capture life cycle.
        TPLCamPhotoCaptureDelegate *photoCaptureDelegate = [[TPLCamPhotoCaptureDelegate alloc] initWithRequestedPhotoSettings:photoSettings willCapturePhotoAnimation:^{//Photo capture animation
        } capturingLivePhoto:nil
        completed:^(TPLCamPhotoCaptureDelegate *photoCaptureDelegate ) {
            // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
            dispatch_async( self.sessionQueue, ^{
                self.inProgressPhotoCaptureDelegates[@(photoCaptureDelegate.requestedPhotoSettings.uniqueID)] = nil;
            } );
        } withPhotoData:^(NSData *photoData) {
            //Once photo data is passed back, present preview screen
            if (photoData) {
                if (self.videoDeviceInput.device.position == AVCaptureDevicePositionFront) {
                    UIImage *source = [UIImage imageWithData:photoData];
                    
                    //There is something seriouslly wrong with the way thay these images are processed
                    //Sometime one method works other time other methods work.
                    //Seem to have narrowed it down to these
                    switch (source.imageOrientation) {
                        case UIImageOrientationDown:
                            photoData = UIImageJPEGRepresentation([UIImage imageWithCGImage:source.CGImage
                                                                                      scale:source.scale
                                                                                orientation:UIImageOrientationDownMirrored], 1);
                            break;
                        case UIImageOrientationUp:
                            photoData = UIImageJPEGRepresentation([UIImage imageWithCGImage:source.CGImage
                                                                                      scale:source.scale
                                                                                orientation:UIImageOrientationUpMirrored], 1);
                            break;
                        case UIImageOrientationLeft:
                        case UIImageOrientationRight:
                        default:
                        {
                            CGSize imageSize = source.size;
                            CGFloat imageWidth = imageSize.width;
                            CGFloat imageHeight = imageSize.height;
                            UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1.0);
                            CGContextRef ctx = UIGraphicsGetCurrentContext();
                            CGContextRotateCTM(ctx, M_PI/2);
                            CGContextTranslateCTM(ctx, 0, -imageWidth);
                            CGContextScaleCTM(ctx, imageHeight/imageWidth, imageWidth/imageHeight);
                            CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, imageWidth, imageHeight), source.CGImage);
                            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            photoData = UIImageJPEGRepresentation(newImage, 1);
                        }
                            break;
                    }
                }
                UIImage *capturedImg = [UIImage imageWithData:photoData];
                self.selectedPhoto = capturedImg;
                TPLAssetPreviewController *assetVC = [[TPLAssetPreviewController alloc]init];
                RestaurantReview *newReview = [[RestaurantReview alloc]init];
                newReview.image = self.selectedPhoto;
                newReview.reviewLocation = [LocationManager sharedLocationInstance].currentLocation;
                assetVC.currentReview = newReview;
            
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:assetVC animated:NO];
            }
        }];
        
        /*
         The Photo Output keeps a weak reference to the photo capture delegate so
         we store it in an array to maintain a strong reference to this object
         until the capture is completed.
         */
        self.inProgressPhotoCaptureDelegates[@(photoCaptureDelegate.requestedPhotoSettings.uniqueID)] = photoCaptureDelegate;
        [self.photoOutput capturePhotoWithSettings:photoSettings delegate:photoCaptureDelegate];
    } );
}

/*
- (void)toggleLivePhotoMode:(UIButton *)livePhotoModeButton
{
    dispatch_async( self.sessionQueue, ^{
        self.livePhotoMode = ( self.livePhotoMode == AVCamLivePhotoModeOn ) ? AVCamLivePhotoModeOff : AVCamLivePhotoModeOn;
        AVCamLivePhotoMode livePhotoMode = self.livePhotoMode;
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if ( livePhotoMode == AVCamLivePhotoModeOn ) {
                //[self.livePhotoModeButton setTitle:NSLocalizedString( @"Live Photo Mode: On", @"Live photo mode button on title" ) forState:UIControlStateNormal];
            }
            else {
                //[self.livePhotoModeButton setTitle:NSLocalizedString( @"Live Photo Mode: Off", @"Live photo mode button off title" ) forState:UIControlStateNormal];
            }
        } );
    } );
}
*/


#pragma mark KVO and Notifications

- (void)addObservers
{
    [self.captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.captureSession];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.captureSession removeObserver:self forKeyPath:@"running" context:SessionRunningContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == SessionRunningContext ) {
        BOOL isSessionRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // Only enable the ability to change camera if the device has more than one camera.
            self.orientationButton.enabled = isSessionRunning && ( self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1 );
            //self.recordButton.enabled = isSessionRunning && ( self.captureModeControl.selectedSegmentIndex == AVCamCaptureModeMovie );
            self.flashButton.enabled = isSessionRunning;
            self.cancelButton.enabled = isSessionRunning;
            self.captureButton.enabled = isSessionRunning;
            //self.captureModeControl.enabled = isSessionRunning;
            //self.livePhotoModeButton.enabled = isSessionRunning && livePhotoCaptureEnabled;
            //self.livePhotoModeButton.hidden = ! ( isSessionRunning && livePhotoCaptureSupported );
        } );
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//Auto-focus
- (void)subjectAreaDidChange:(NSNotification *)notification
{
    //CGPoint devicePoint = CGPointMake(0.5, 0.5);
    //[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)sessionRuntimeError:(NSNotification *)notification
{
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog( @"Capture session runtime error: %@", error );
    
    /*
     Automatically try to restart the session running if media services were
     reset and the last start running succeeded. Otherwise, enable the user
     to try to resume the session running.
     */
    if ( error.code == AVErrorMediaServicesWereReset ) {
        dispatch_async( self.sessionQueue, ^{
            if ( self.sessionRunning ) {
                [self.captureSession startRunning];
                self.sessionRunning = self.captureSession.isRunning;
            }
            else {
                dispatch_async( dispatch_get_main_queue(), ^{
                    self.resumeButton.hidden = NO;
                } );
            }
        } );
    }
    else {
        self.resumeButton.hidden = NO;
    }
}

- (void)sessionWasInterrupted:(NSNotification *)notification
{
    /*
     In some scenarios we want to enable the user to resume the session running.
     For example, if music playback is initiated via control center while
     using AVCam, then the user can let AVCam resume
     the session running, which will stop music playback. Note that stopping
     music playback in control center will not automatically resume the session
     running. Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
     */
    BOOL showResumeButton = NO;
    
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog( @"Capture session was interrupted with reason %ld", (long)reason );
    
    if ( reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
        reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient ) {
        showResumeButton = YES;
    }
    else if ( reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps ) {
        // Simply fade-in a label to inform the user that the camera is unavailable.
        self.cameraUnavailableLabel.alpha = 0.0;
        self.cameraUnavailableLabel.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.cameraUnavailableLabel.alpha = 1.0;
        }];
    }
    
    if ( showResumeButton ) {
        // Simply fade-in a button to enable the user to try to resume the session running.
        self.resumeButton.alpha = 0.0;
        self.resumeButton.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.resumeButton.alpha = 1.0;
        }];
    }
}

- (void)sessionInterruptionEnded:(NSNotification *)notification
{
    NSLog( @"Capture session interruption ended" );
    if ( ! self.resumeButton.hidden ) {
        [UIView animateWithDuration:0.25 animations:^{
            self.resumeButton.alpha = 0.0;
        } completion:^( BOOL finished ) {
            self.resumeButton.hidden = YES;
        }];
    }
    if ( ! self.cameraUnavailableLabel.hidden ) {
        [UIView animateWithDuration:0.25 animations:^{
            self.cameraUnavailableLabel.alpha = 0.0;
        } completion:^( BOOL finished ) {
            self.cameraUnavailableLabel.hidden = YES;
        }];
    }
}

#pragma mark - UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    //Have to make sure user comes in first then set or just not let them take photo, but animate tab bar item instead
//    UINavigationController *nav = (UINavigationController *)viewController;
//    UIViewController *root = [[nav viewControllers]firstObject];
//    
    //If we're currently in the camera, take a photo using the tab bar item, otherwise assign the tabcontroller's delegate to the new controller presented.
//    if ([root isKindOfClass:[TabCameraViewController class]]) {
//        if (self.setupResult == AVCamSetupResultSuccess) {
//            [self capturePhoto:nil];
//        }
//    if([root isKindOfClass:[UserProfileViewController class]]){
//        UserProfileViewController *profileVC = (UserProfileViewController *)root;
//        profileVC.tabBarController.delegate = profileVC;
//    }else if ([root isKindOfClass:[ChartsViewController class]]){
//        ChartsViewController *chartsVC = (ChartsViewController *)root;
//        chartsVC.tabBarController.delegate = chartsVC;
//    }
}

#pragma mark - Helper Methods

- (void)exitCamera{
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers firstObject];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)checkAlbumAuth{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusAuthorized) {
        [self loadLastPhoto];
    }else{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    [self loadLastPhoto];
                    break;
                case PHAuthorizationStatusRestricted:
                    break;
                case PHAuthorizationStatusDenied:
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)loadLastPhoto{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    PHAsset *lastAsset = [fetchResult lastObject];
    [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                               targetSize:CGSizeMake(self.albumButton.frame.size.width * 4, self.albumButton.frame.size.width * 4)
                                              contentMode:PHImageContentModeAspectFit
                                                  options:PHImageRequestOptionsVersionCurrent
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self.albumButton setImage:result forState:UIControlStateNormal];
                                                });
                                            }];
}

- (void)openAlbum{
    AlbumViewController *albumVC = [[AlbumViewController alloc]init];
    [self presentViewController:albumVC animated:YES completion:nil];
}


#pragma mark UI Convenience methods

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (BOOL)hidesBottomBarWhenPushed{
    return YES;
}

@end
