//
//  CameraFilterScrollView.h
//  FoodWise
//
//  Created by Brian Wong on 2/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GPUImage.h"
#import "CameraScrollFilter.h"

@protocol CameraFilterScrollDelegate <NSObject>

@required

- (void)didChangeFilter:(CameraScrollFilter *)currentFilter;

@end

@interface CameraFilterScrollView : UIView

@property (nonatomic, strong) CameraScrollFilter *currentFilter;
@property (nonatomic, weak) id<CameraFilterScrollDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andStillCamera:(GPUImageStillCamera *)stillCamera;

- (void)setupFilters;
- (void)clearFilterData;

@end
