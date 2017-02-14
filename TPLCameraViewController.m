//
//  TPLCameraViewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/3/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

@import AVFoundation;
@import Photos;

#import "TPLCameraViewController.h"
#import "TPLCameraPreviewView.h"
#import "TPLCamPhotoCaptureDelegate.h"
#import "TPLRestaurant.h"
#import "TPLAssetPreviewController.h"

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

@interface TPLCameraViewController () <AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate>

//Session management
@property (nonatomic, strong) TPLCameraPreviewView *previewView;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, assign) BOOL sessionRunning;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;

//UI
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *cameraUnavailableLabel;

//Orientation
@property (nonatomic, strong) UIButton *orientationButton;
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

@end

@implementation TPLCameraViewController

#define MIN_ZOOM 1
#define MAX_ZOOM 3

dispatch_queue_t sessionQueue;

static CGFloat previousZoom;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCameraControls];
    
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
    
    
    //Check camera authorization
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
            //Authorized
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
    
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    dispatch_async(self.sessionQueue, ^{
        switch (self.setupResult) {
            case AVCamSetupResultSuccess:{
                [self addObservers];
                [self.captureSession startRunning];
                self.sessionRunning = self.captureSession.running;
                break;
            }
            case AVCamSetupResultCameraNotAuthorized:{
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString( @"AVCam doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    // Provide quick access to Settings.
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                    }];
                    [alertController addAction:settingsAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;

            }
            case AVCamSetupResultSessionConfigurationFailed:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString( @"Unable to capture media", @"Alert message when something goes wrong during capture session configuration" );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;
            }
            default:
                break;
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult == AVCamSetupResultSuccess ) {
            [self.captureSession stopRunning];
            [self removeObservers];
        }
    } );
    
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    
//    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
//        self.previewView.videoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
//    }
//}


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
    
    // Add video input.
    
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
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if ( ! audioDeviceInput ) {
        NSLog( @"Could not create audio device input: %@", error );
    }
    if ( [self.captureSession canAddInput:audioDeviceInput] ) {
        [self.captureSession addInput:audioDeviceInput];
    }
    else {
        NSLog( @"Could not add audio device input to the session" );
    }
    
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
    
    self.previewView = [[TPLCameraPreviewView alloc]init];
    self.previewView.bounds = bounds;
    self.previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewView.videoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    [self.view addSubview:self.previewView];
    
    self.captureButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.height * 0.075, self.view.frame.size.height * 0.85, self.view.frame.size.height * 0.15, self.view.frame.size.height * 0.15)];
    self.captureButton.backgroundColor = [UIColor clearColor];
    [self.captureButton setImage:[UIImage imageNamed:@"capture"] forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.captureButton];
    
    self.flashButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.captureButton.frame), CGRectGetMaxY(self.captureButton.frame) - self.view.frame.size.height * 0.12, self.view.frame.size.height * 0.12, self.view.frame.size.height * 0.12)];
    self.flashButton.backgroundColor = [UIColor clearColor];
    [self.flashButton setImage:[[UIImage imageNamed:@"flash_auto"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.flashButton addTarget:self action:@selector(toggleFlashMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    
    self.orientationButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.captureButton.frame) - self.view.frame.size.height * 0.12, CGRectGetMaxY(self.captureButton.frame) - self.view.frame.size.height * 0.12, self.view.frame.size.height * 0.12, self.view.frame.size.height * 0.12)];
    self.orientationButton.backgroundColor = [UIColor clearColor];
    [self.orientationButton setImage:[UIImage imageNamed:@"flip_camera"] forState:UIControlStateNormal];
    [self.orientationButton addTarget:self action:@selector(changeOrientation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.orientationButton];
    
    self.cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.orientationButton.frame) - self.view.frame.size.height * 0.09, CGRectGetMaxY(self.captureButton.frame) - self.view.frame.size.height * 0.11, self.view.frame.size.height * 0.12, self.view.frame.size.height * 0.12)];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(exitCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
    self.pinchToZoom = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchToZoomRecognizer:)];
    [self.view addGestureRecognizer:self.pinchToZoom];
    
    self.focusView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1)];
    self.focusView.backgroundColor = [UIColor clearColor];
    self.focusView.contentMode = UIViewContentModeScaleAspectFit;
    self.focusView.alpha = 0.0;
    [self.focusView setImage:[UIImage imageNamed:@"auto_focus"]];
    [self.view addSubview:self.focusView];
    
    self.tapToFocus = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusAndExposeTap:)];
    [self.view addGestureRecognizer:self.tapToFocus];

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

#pragma mark - Focus and Zoom methods

- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [self.previewView.videoPreviewLayer captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
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

#pragma mark Capturing Photos

- (void)capturePhoto:(id)sender
{
    /*
     Retrieve the video preview layer's video orientation on the main queue before
     entering the session queue. We do this to ensure UI elements are accessed on
     the main thread and session configuration is done on the session queue.
     */
    AVCaptureVideoOrientation videoPreviewLayerVideoOrientation = self.previewView.videoPreviewLayer.connection.videoOrientation;
    
    dispatch_async( self.sessionQueue, ^{
        
        // Update the photo output's connection to match the video orientation of the video preview layer.
        AVCaptureConnection *photoOutputConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
        photoOutputConnection.videoOrientation = videoPreviewLayerVideoOrientation;
        
        // Capture a JPEG photo with flash set to auto and high resolution photo enabled.
        AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
        photoSettings.flashMode = AVCaptureFlashModeOff;
        photoSettings.highResolutionPhotoEnabled = YES;
        if ( photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0 ) {
            photoSettings.previewPhotoFormat = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : photoSettings.availablePreviewPhotoPixelFormatTypes.firstObject };
        }
//        if ( self.livePhotoMode == AVCamLivePhotoModeOn && self.photoOutput.livePhotoCaptureSupported ) { // Live Photo capture is not supported in movie mode.
//            NSString *livePhotoMovieFileName = [NSUUID UUID].UUIDString;
//            NSString *livePhotoMovieFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[livePhotoMovieFileName stringByAppendingPathExtension:@"mov"]];
//            photoSettings.livePhotoMovieFileURL = [NSURL fileURLWithPath:livePhotoMovieFilePath];
//        }
        
        // Use a separate object for the photo capture delegate to isolate each capture life cycle.
        TPLCamPhotoCaptureDelegate *photoCaptureDelegate = [[TPLCamPhotoCaptureDelegate alloc] initWithRequestedPhotoSettings:photoSettings willCapturePhotoAnimation:^{
//            dispatch_async( dispatch_get_main_queue(), ^{
//                self.previewView.videoPreviewLayer.opacity = 0.0;
//                [UIView animateWithDuration:0.25 animations:^{
//                    self.previewView.videoPreviewLayer.opacity = 1.0;
//                }];
//            } );
        } capturingLivePhoto:^( BOOL capturing ) {
            /*
             Because Live Photo captures can overlap, we need to keep track of the
             number of in progress Live Photo captures to ensure that the
             Live Photo label stays visible during these captures.
             */
            dispatch_async( self.sessionQueue, ^{
                if ( capturing ) {
                    self.inProgressLivePhotoCapturesCount++;
                }
                else {
                    self.inProgressLivePhotoCapturesCount--;
                }
                
                NSInteger inProgressLivePhotoCapturesCount = self.inProgressLivePhotoCapturesCount;
                dispatch_async( dispatch_get_main_queue(), ^{
                    if ( inProgressLivePhotoCapturesCount > 0 ) {
                        self.capturingLivePhotoLabel.hidden = NO;
                    }
                    else if ( inProgressLivePhotoCapturesCount == 0 ) {
                        self.capturingLivePhotoLabel.hidden = YES;
                    }
                    else {
                        NSLog( @"Error: In progress live photo capture count is less than 0" );
                    }
                } );
            } );
        } completed:^(TPLCamPhotoCaptureDelegate *photoCaptureDelegate ) {
            // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
            dispatch_async( self.sessionQueue, ^{
                self.inProgressPhotoCaptureDelegates[@(photoCaptureDelegate.requestedPhotoSettings.uniqueID)] = nil;
            } );
        } withPhotoData:^(NSData *photoData) {
            //Once photo data is passed back, present preview screen
            if (photoData) {
                self.selectedPhoto = [UIImage imageWithData:photoData];
                TPLAssetPreviewController *assetVC = [[TPLAssetPreviewController alloc]init];
                assetVC.selectedImage = self.selectedPhoto;
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


#pragma mark KVO and Notifications

- (void)addObservers
{
    [self.captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.captureSession];
    
    /*
     A session can only run when the app is full screen. It will be interrupted
     in a multi-app layout, introduced in iOS 9, see also the documentation of
     AVCaptureSessionInterruptionReason. Add observers to handle these session
     interruptions and show a preview is paused message. See the documentation
     of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
     */
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
        BOOL livePhotoCaptureSupported = self.photoOutput.livePhotoCaptureSupported;
        BOOL livePhotoCaptureEnabled = self.photoOutput.livePhotoCaptureEnabled;
        
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

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake( 0.5, 0.5 );
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
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



#pragma mark UI Convenience methods

- (void)exitCamera
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

