//
//  TPLCameraPreviewView.h
//  FoodWise
//
//  Created by Brian Wong on 2/3/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

@import UIKit;
@import AVFoundation;

@interface TPLCameraPreviewView : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) AVCaptureSession *session;


@end
