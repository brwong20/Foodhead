//
//  CameraScrollFilter.m
//  FoodWise
//
//  Created by Brian Wong on 2/27/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "CameraScrollFilter.h"

@interface CameraScrollFilter ()

@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImagePicture *lookupPic;

@end

@implementation CameraScrollFilter

- (instancetype)initWithFrame:(CGRect)frame withCamera:(GPUImageStillCamera *)stillCam andGPUFilter:(GPUImageFilter *)filter{
    self = [super initWithFrame:frame];
    if (self) {
        self.gpuFilter = filter;
        self.stillCamera = stillCam;
        [self setupGPUFilter];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withCamera:(GPUImageStillCamera *)stillCam andLookupImage:(UIImage *)lookup{
    self = [super initWithFrame:frame];
    if (self) {
        self.lookupPic = [[GPUImagePicture alloc]initWithImage:lookup];
        self.stillCamera = stillCam;
        [self setupLookupFilter];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withCamera:(GPUImageStillCamera *)stillCam andLookupFilter:(id)filter{
    self = [super initWithFrame:frame];
    if (self) {
        self.stillCamera = stillCam;
        [self setupLookup:filter];
    }
    return self;
}

- (void)setupGPUFilter{
    self.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    [self.gpuFilter addTarget:self];
    [self.stillCamera addTarget:self];
}

- (void)setupLookupFilter{
    self.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    @autoreleasepool {
        GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
        lookupFilter.intensity = 1.0;

        [self.stillCamera addTarget:lookupFilter atTextureLocation:0];
        [self.lookupPic addTarget:lookupFilter atTextureLocation:1];
        [self.lookupPic processImage];
        
        [lookupFilter addTarget:self];
        [lookupFilter useNextFrameForImageCapture];
        
        [lookupFilter forceProcessingAtSizeRespectingAspectRatio:self.sizeInPixels];
        
        self.lookupFilter = lookupFilter;
    }
}

- (void)setupLookup:(id)filter{
    
    GPUImageFilterGroup *filt = filter;
    
    self.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    [self.stillCamera addTarget:filter];
    [filter addTarget:self];
    [filter useNextFrameForImageCapture];
    
    [filt forceProcessingAtSizeRespectingAspectRatio:self.frame.size];
}

@end
