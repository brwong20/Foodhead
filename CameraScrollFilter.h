//
//  CameraScrollFilter.h
//  FoodWise
//
//  Created by Brian Wong on 2/27/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "GPUImage.h"

@interface CameraScrollFilter : GPUImageView

@property (nonatomic, strong) GPUImageFilter *gpuFilter;
@property (nonatomic, strong) GPUImageLookupFilter *lookupFilter;

- (instancetype)initWithFrame:(CGRect)frame withCamera:(GPUImageStillCamera *)stillCam andGPUFilter:(GPUImageFilter *)filter;
- (instancetype)initWithFrame:(CGRect)frame withCamera:(GPUImageStillCamera *)stillCam andLookupImage:(UIImage *)lookup;

@end
