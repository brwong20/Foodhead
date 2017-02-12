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
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, assign) CLAuthorizationStatus authorizedStatus;

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
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.authorizedStatus = [CLLocationManager authorizationStatus];
        self.locationManager.delegate = self;
    }
    
    return self;
}

//Only request when app is in use for now since we only need the current location when opening the map. This also saves battery life!
- (void)requestLocationAuthorization
{
    
#warning Be careful with checking if request is denied - should NEVER come before we request for first time!
    switch (self.authorizedStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            if([self.locationDelegate respondsToSelector:@selector(locationPermissionDenied)]){
                [self.locationDelegate locationPermissionDenied];
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
    NSLog(@"///Location updates started///");
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation{
    NSLog(@"///Location updates stopped///");
    [self.locationManager stopUpdatingLocation];
    
    /*
     For some reason, did update location is called multiple times which uneccesserily re-updates our restaurants. This fixes that problem by only retrieving the location ONCE with the location manager. We can retrieve the user's current location in the future (if we need to) by simply resetting the delegate!
     */
    self.locationManager.delegate = nil;
}

- (CLLocationCoordinate2D)getCurrentLocation{
    return self.currentLocation;
}

#pragma mark - CLLocationDelegate methods

//Delegate method called when the location manager is initialized AND/OR user authorizes location
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    self.authorizedStatus = status;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            if([self.locationDelegate respondsToSelector:@selector(locationPermissionDenied)]){
                [self.locationDelegate locationPermissionDenied];
            }
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            if([self.locationDelegate respondsToSelector:@selector(locationPermissionDenied)]){
                [self.locationDelegate locationPermissionDenied];
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            [self startUpdatingLocation];
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
