//
//  Timer.h
//  Foodhead
//
//  Created by Brian Wong on 5/31/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Timer : NSObject

+ (Timer *)sharedInstance;

- (void)startTrackingHomeTime;
- (void)startTrackingBrowseTime;
- (void)stopTrackingHomeTime;
- (void)stopTrackingBrowseTime;

@end
