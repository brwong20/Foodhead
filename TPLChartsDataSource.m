//
//  TPLRestaurantStore.m
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartsDataSource.h"
#import "FoodWiseDefines.h"

@implementation TPLChartsDataSource
- (void)retrieveCategoriesForLocation:(CLLocationCoordinate2D)coordinate
                                completionHandler:(void (^)(id))completionHandler
                                   failureHandler:(void (^)(id))failureHandler{
    
    //self.categories = [@[@"4bf58dd8d48988d142941735", @"4bf58dd8d48988d113941735", @"4bf58dd8d48988d111941735", @"4bf58dd8d48988d10e941735"]mutableCopy];
}

/*
- (void)retrieveRestaurantsForCategories:(NSArray *)categories
                          withCoordinate:(CLLocationCoordinate2D)coordinate
                       completionHandler:(void (^)(NSArray *))completionHandler
                          failureHandler:(void (^)(id))failureHandler {
    NSArray *categoryNames = categories;
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    
    NSMutableArray *urlArray = [NSMutableArray array];
    for (NSString *category in categoryNames) {
        NSString *completeUrl = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/explore?client_id=%@&client_secret=%@&v=%@&ll=%@,%@&query=%@&venuePhotos=1&limit=3", FOURSQ_CLIENT_ID, FOURSQ_SECRET, @"20170125", lat, lng, category];
        [urlArray addObject:completeUrl];
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    __block int currentReq = 0;
    __block NSMutableArray *responseArray = [NSMutableArray array];
    
    for (NSString *urlString in urlArray)
    {
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            [responseArray addObject:json];
            
            //Pass to completion handler once all calls have finished
            ++currentReq;
            if (currentReq == urlArray.count) {
                completionHandler(responseArray);
            }
            
            if (error) {
                failureHandler(error);
            }
        }];
        
        [task resume];
    }
}
 */

- (void)retrieveRestaurantsForCategory:(NSString *)category
                          withCoordinate:(CLLocationCoordinate2D)coordinate
                       completionHandler:(void (^)(id))completionHandler
                          failureHandler:(void (^)(id))failureHandler {
    
    NSString *lat = [[NSNumber numberWithDouble:coordinate.latitude]stringValue];
    NSString *lng = [[NSNumber numberWithDouble:coordinate.longitude]stringValue];
    
    NSString *completeURL = [NSString string];
    if([category isEqualToString:@"Cheap"]){
        completeURL = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/explore?client_id=%@&client_secret=%@&v=%@&ll=%@,%@&price=1&venuePhotos=1&limit=10", FOURSQ_CLIENT_ID, FOURSQ_SECRET, @"20170125", lat, lng];
    }else{
        completeURL = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/explore?client_id=%@&client_secret=%@&v=%@&ll=%@,%@&query=%@&venuePhotos=1&limit=10", FOURSQ_CLIENT_ID, FOURSQ_SECRET, @"20170125", lat, lng, category];
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:completeURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

        //Pass to completion handler once all calls have finished
        if(json){
            completionHandler(json);
        }
        
        if (error) {
            failureHandler(error);
        }
    }];
    [task resume];
}


//Need to come up with efficient way of constructing array of urls as well as parsing 4SQ
@end
