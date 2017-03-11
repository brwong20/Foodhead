//
//  LocationManager.h
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;

@protocol LocationManagerDelegate <NSObject>

@optional
//Since it takes a bit of time to retrieve the current location, implement a delegate that will signal the delegate class when a location is available for use.
- (void)didGetCurrentLocation:(CLLocationCoordinate2D)coordinate;
- (void)locationPermissionDenied;

@end

@interface LocationManager : NSObject

@property (nonatomic, weak) id<LocationManagerDelegate>locationDelegate;

+ (LocationManager*) sharedLocationInstance;

- (void)checkLocationAuthorization;
- (CLLocationCoordinate2D)getCurrentLocation;

@end
