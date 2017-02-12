//
//  TPLCamPhotoCaptureDelegate.h
//  FoodWise
//
//  Created by Brian Wong on 2/3/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

@import AVFoundation;

@interface TPLCamPhotoCaptureDelegate : NSObject<AVCapturePhotoCaptureDelegate>

//Instead of using another delegate, will conform to Apple's structure here and use a completion handler to retrieve photo data
- (instancetype)initWithRequestedPhotoSettings:(AVCapturePhotoSettings *)requestedPhotoSettings willCapturePhotoAnimation:(void (^)())willCapturePhotoAnimation capturingLivePhoto:(void (^)( BOOL capturing ))capturingLivePhoto completed:(void (^)(TPLCamPhotoCaptureDelegate *photoCaptureDelegate ))completed withPhotoData:(void(^)(NSData *photoData))photoData;

@property (nonatomic, readonly) AVCapturePhotoSettings *requestedPhotoSettings;


@end
