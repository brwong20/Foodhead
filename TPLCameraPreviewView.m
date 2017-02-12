//
//  TPLCameraPreviewView.m
//  FoodWise
//
//  Created by Brian Wong on 2/3/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

@import AVFoundation;

#import "TPLCameraPreviewView.h"

@implementation TPLCameraPreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *)session
{
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.videoPreviewLayer.session = session;
}

@end
