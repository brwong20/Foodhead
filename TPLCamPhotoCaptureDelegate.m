
//
//  TPLCamPhotoCaptureDelegate.m
//  FoodWise
//
//  Created by Brian Wong on 2/3/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLCamPhotoCaptureDelegate.h"

@import Photos;

@interface TPLCamPhotoCaptureDelegate()

@property (nonatomic, readwrite) AVCapturePhotoSettings *requestedPhotoSettings;
@property (nonatomic) void (^willCapturePhotoAnimation)();
@property (nonatomic) void (^capturingLivePhoto)(BOOL capturing);
@property (nonatomic) void (^completed)(TPLCamPhotoCaptureDelegate *photoCaptureDelegate);
@property (nonatomic) void (^withPhotoData)(NSData *photoData);

@property (nonatomic) NSData *photoData;
@property (nonatomic) NSURL *livePhotoCompanionMovieURL;

@end

@implementation TPLCamPhotoCaptureDelegate

- (instancetype)initWithRequestedPhotoSettings:(AVCapturePhotoSettings *)requestedPhotoSettings willCapturePhotoAnimation:(void (^)())willCapturePhotoAnimation capturingLivePhoto:(void (^)(BOOL))capturingLivePhoto completed:(void (^)(TPLCamPhotoCaptureDelegate *))completed withPhotoData:(void (^)(NSData *))photoData
{
    self = [super init];
    if ( self ) {
        self.requestedPhotoSettings = requestedPhotoSettings;
        self.willCapturePhotoAnimation = willCapturePhotoAnimation;
        self.capturingLivePhoto = capturingLivePhoto;
        self.completed = completed;
        self.withPhotoData = photoData;
    }
    return self;
}

- (void)didFinish
{
    if ( [[NSFileManager defaultManager] fileExistsAtPath:self.livePhotoCompanionMovieURL.path] ) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.livePhotoCompanionMovieURL.path error:&error];
        
        if ( error ) {
            NSLog( @"Could not remove file at url: %@", self.livePhotoCompanionMovieURL.path );
        }
    }
    
    self.completed( self );
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput willBeginCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
    if ( ( resolvedSettings.livePhotoMovieDimensions.width > 0 ) && ( resolvedSettings.livePhotoMovieDimensions.height > 0 ) ) {
        self.capturingLivePhoto( YES );
    }
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput willCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
    self.willCapturePhotoAnimation();
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error
{
    if ( error != nil ) {
        NSLog( @"Error capturing photo: %@", error );
        return;
    }
    
    if (photoSampleBuffer) {
        self.photoData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        self.withPhotoData(self.photoData);
    }
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishRecordingLivePhotoMovieForEventualFileAtURL:(NSURL *)outputFileURL resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
    self.capturingLivePhoto(NO);
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingLivePhotoToMovieFileAtURL:(NSURL *)outputFileURL duration:(CMTime)duration photoDisplayTime:(CMTime)photoDisplayTime resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings error:(NSError *)error
{
    if ( error != nil ) {
        NSLog( @"Error processing live photo companion movie: %@", error );
        return;
    }
    
    self.livePhotoCompanionMovieURL = outputFileURL;
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings error:(NSError *)error
{
    if ( error != nil ) {
        NSLog( @"Error capturing photo: %@", error );
        [self didFinish];
        return;
    }
    
    if ( self.photoData == nil ) {
        NSLog( @"No photo data resource" );
        [self didFinish];
        return;
    }
    
    [self didFinish];
    
    //Album permission request and saving logic - prompt when user first wants to save img
//    [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
//        if ( status == PHAuthorizationStatusAuthorized ) {
//            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//                PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
//                [creationRequest addResourceWithType:PHAssetResourceTypePhoto data:self.photoData options:nil];
//                
//                if ( self.livePhotoCompanionMovieURL ) {
//                    PHAssetResourceCreationOptions *livePhotoCompanionMovieResourceOptions = [[PHAssetResourceCreationOptions alloc] init];
//                    livePhotoCompanionMovieResourceOptions.shouldMoveFile = YES;
//                    [creationRequest addResourceWithType:PHAssetResourceTypePairedVideo fileURL:self.livePhotoCompanionMovieURL options:livePhotoCompanionMovieResourceOptions];
//                }
//            } completionHandler:^( BOOL success, NSError * _Nullable error ) {
//                if ( ! success ) {
//                    NSLog( @"Error occurred while saving photo to photo library: %@", error );
//                }
//                
//                
//            }];
//        }
//        else {
//            NSLog( @"Not authorized to save photo" );
//            [self didFinish];
//        }
//    }];
}

@end
