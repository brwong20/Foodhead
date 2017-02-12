//
//  ChartsViewModel.m
//  FoodWise
//
//  Created by Brian Wong on 1/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLChartsViewModel.h"

@interface TPLChartsViewModel ()

@property (nonatomic, strong) TPLChartsDataSource *restaurantDataSrc;

@end

@implementation TPLChartsViewModel

- (instancetype)initWithStore:(TPLChartsDataSource *)store{
    self = [super init];
    if(self){
        self.restaurantDataSrc = store;
        self.restaurantData = [NSMutableArray array];
    }
    return self;
}

- (void)getRestaurantsWithCoordinate:(CLLocationCoordinate2D)coordinate{
    NSArray *categories = @[@"American", @"Sushi", @"Salad", @"Healthy", @"Mexican", @"Cheap"];
    
    NSMutableArray *rest = [[NSMutableArray alloc]initWithCapacity:categories.count];
    for (int i = 0; i < categories.count; ++i) {
        rest[i] = [NSNull null];//Must initialize empty objects in order to replace them
    }
    
    __block int count = 0;//Makes sure we've retrieved each restaurant so we can process all at once.
    for (NSString *category in categories) {
        NSMutableDictionary *categoryDict = [NSMutableDictionary dictionary];
        [self.restaurantDataSrc retrieveRestaurantsForCategory:category withCoordinate:coordinate completionHandler:^(id JSON) {
            NSUInteger index = [categories indexOfObject:category];
            if(JSON){
                [categoryDict setValue:[self parseJSON:JSON] forKey:category];
                [rest replaceObjectAtIndex:index withObject:categoryDict];//We do this to make sure our restaurant responses are in the same order as the categories sent.
                ++count;
                if(count == categories.count){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //Must use this proxy itself rather than the actual array!
                        NSMutableArray *arr = [self mutableArrayValueForKey:@"restaurantData"];
                        [arr addObjectsFromArray:rest];
                    });
                }
            }else{
                [categoryDict setValue:@{} forKey:category];//In case we get NOTHING for a category
            }
        } failureHandler:^(id error) {
            NSLog(@"Failed to retrieve restaurant for category!!!");
        }];
    }
}

#pragma mark - Helper methods
- (NSArray *)parseJSON:(NSDictionary*)venueDict{
    NSMutableArray *restaurantArr = [NSMutableArray array];
    NSDictionary *response = venueDict[@"response"];
    NSArray *groups = response[@"groups"];
    //Have to check for other groups here - what if it's not recommended?
    NSDictionary *recommended = [groups firstObject];
    NSArray *venueArray = recommended[@"items"];
    
    for (NSDictionary *venueDict in venueArray) {
        NSError *error;
        TPLRestaurant *restaurant = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:venueDict error:&error];
        if (error) {
            NSLog(@"Couldn't deserealize JSON: %@", error);
            //return nil;
        }
        [restaurantArr addObject:restaurant];
    }
    
    NSArray *rest = [NSArray arrayWithArray:restaurantArr];
    
    return rest;
}














//        if (!restaurant.fb_cover_photo) {
//            NSString *coordinateString = [NSString stringWithFormat:@"%f,%f", restaurant.locationCoordinate.latitude, restaurant.locationCoordinate.longitude];
//
//            //Get places id for a restaurant then chain the response to retrieve that restaurant's cover photo - Need a way to make sure the places is id is correct!!!
//            FBSDKGraphRequest *locationRequest = [[FBSDKGraphRequest alloc]initWithGraphPath:@"search" parameters:@{@"fields" : @"id, name", @"q" : [NSString stringByTrimmingSpecialCharacters:restaurant.name], @"type" : @"place", @"center" : coordinateString, @"distance" : @"1000", @"limit" : @"1"}  HTTPMethod:@"GET"];
//
//            //Get first id from parent "place" parameter - this request depends on the locationRequest
//            FBSDKGraphRequest *pageRequest = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/{result=place:$.data.[0].id}" parameters:@{@"fields" : @"id, name"} HTTPMethod:@"GET"];
//            //            FBSDKGraphRequest *photoRequest = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/{result=recent_photo:$.data.[0].id}" parameters:@{@"fields" : @"id, images"} HTTPMethod:@"GET"];
//
//            FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc]init];
//            [connection addRequest:locationRequest
//                 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                     if (error)
//                         NSLog(@"%@", error.localizedDescription);//Nothing should happen with result since this request is a dependency which FB will handle
//                 } batchParameters:@{@"name" : @"place"}];
//
//            [connection addRequest:pageRequest
//                 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                     if (!error) {
//                         //NSLog(@"%@", result);
//                         //                        NSString *restaurantName = result[@"name"];
//                         //                         if (restaurantName Substring restaurant.name) {
//                         //                             <#statements#>
//                         //                         }
//                         NSString *coverPhotoUrl = result[@"cover"][@"source"];
//                         restaurant.fb_places_id = result[@"id"];
//                         if (coverPhotoUrl) {
//                             restaurant.fb_cover_photo = coverPhotoUrl;
//                             [restaurantArr addObject:restaurant];
//                             //Our multiple async calls are complete when we've requested each restaurant
//                             if(restaurantArr.count == venueArray.count){
//                                 completionHandler(restaurantArr);
//                             }
//                         }
//                     }else{
//                         NSLog(@"%@", error.description);
//                         [restaurantArr addObject:restaurant];
//                         //Our multiple async calls are complete when we've requested each restaurant
//                         if(restaurantArr.count == venueArray.count){
//                             completionHandler(restaurantArr);
//                         }
//                     }
//                 } batchParameters:@{@"depends_on" : @"place"}];//Used to batch this request with previous one
//
//            //            [connection addRequest:photoRequest completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//            //                if (result) {
//            //                    NSLog(@"%@", result);
//            //                    NSArray *images = result[@"images"];
//            //                    NSDictionary *prof_pic = [images firstObject];
//            //
//            //                    if (prof_pic) {
//            //                        NSString *src = prof_pic[@"source"];
//            //                        restaurant.fb_cover_photo = src;
//            //                    }
//            //
//            //                    [restaurantArr addObject:restaurant];
//            //                    if(restaurantArr.count == venueArray.count){
//            //                        completionHandler(restaurantArr);
//            //                    }
//            //                }else{
//            //                    NSLog(@"%@", error.description);
//            //                    [restaurantArr addObject:restaurant];
//            //                    //Our multiple async calls are complete when we've requested each restaurant
//            //                    if(restaurantArr.count == venueArray.count){
//            //                        completionHandler(restaurantArr);
//            //                    }
//            //                }
//            //            } batchParameters:@{@"depends_on" : @"recent_photo"}];
//
//            [connection start];


@end
