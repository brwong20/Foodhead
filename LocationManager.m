//
//  LocationManager.m
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation LocationManager

//Use a singleton since location retrieval will be the same throughout the app
+ (LocationManager *)sharedLocationInstance
{
    
    static LocationManager *locationInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationInstance = [[self alloc]init];
    });
    
    return locationInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc]init];
        //self.locationManager.distanceFilter = 1000.0;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.authorizedStatus = [CLLocationManager authorizationStatus];
        self.locationManager.delegate = self;
    }
    return self;
}

//Only request when app is in use for now since we only need the current location when opening the map. This also saves battery life!
- (void)checkLocationAuthorization
{
    self.authorizedStatus = [CLLocationManager authorizationStatus];
    switch (self.authorizedStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            if([self.locationDelegate respondsToSelector:@selector(locationWasAuthorizedWithStatus:)]){
                [self.locationDelegate locationWasAuthorizedWithStatus:kCLAuthorizationStatusDenied];
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            break;
        }
    }
}


//These modularized location updates allow us to get the current location again if need be.
- (void)startUpdatingLocation
{
    DLog(@"///Location updates started///");
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation{
    DLog(@"///Location updates stopped///");
    [self.locationManager stopUpdatingLocation];
    
    /*
     For some reason, did update location is called multiple times which uneccesserily re-updates our restaurants. This fixes that problem by only retrieving the location ONCE with the location manager. We can retrieve the user's current location in the future (if we need to) by simply resetting the delegate!
     */
    self.locationManager.delegate = nil;
}

- (void)retrieveCurrentLocation{
    self.locationManager.delegate = self;
    [self startUpdatingLocation];
}

#pragma mark - CLLocationDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    self.authorizedStatus = status;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            if([self.locationDelegate respondsToSelector:@selector(locationWasAuthorizedWithStatus:)]){
                [self.locationDelegate locationWasAuthorizedWithStatus:kCLAuthorizationStatusDenied];
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            if ([self.locationDelegate respondsToSelector:@selector(locationWasAuthorizedWithStatus:)]) {
                [self.locationDelegate locationWasAuthorizedWithStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
            }
            break;
        }
    }
}

//For our current map: We only need the location ONCE to show the user where he/she is so we can stop updating right after we find this point.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    self.currentLocation = [locations lastObject].coordinate;
    if([self.locationDelegate respondsToSelector:@selector(didGetCurrentLocation:)]){
        [self.locationDelegate didGetCurrentLocation:self.currentLocation];
    }
    [self stopUpdatingLocation];
}

@end
