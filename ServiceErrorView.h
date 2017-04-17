//
//  ServiceErrorView.h
//  Foodhead
//
//  Created by Brian Wong on 3/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodWiseDefines.h"

@protocol ServiceErrorViewDelegate <NSObject>

- (void)serviceErrorViewToggledRefresh;

@end

@interface ServiceErrorView : UIView

@property (nonatomic, assign) ServiceErrorType errorType;
@property (nonatomic, weak) id<ServiceErrorViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)rect andErrorType:(ServiceErrorType)errorType;

- (void)stopRefreshing;

@end
