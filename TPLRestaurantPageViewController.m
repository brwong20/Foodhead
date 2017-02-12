//
//  TPLRestaurantPageViewController.m
//  FoodWise
//
//  Created by Brian Wong on 1/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLRestaurantPageViewController.h"
#import "FoodWiseDefines.h"

@interface TPLRestaurantPageViewController ()

@property (nonatomic, strong)UILabel *restaurantNameLabel;
@property (nonatomic, strong)UILabel *hours;

@end

@implementation TPLRestaurantPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.selectedRestaurant.name;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getFSQRestuarantInfo:self.selectedRestaurant.venue_id];
    
}


#pragma Helper Methods

- (void)setupUI{
    CGSize frameSize = self.view.frame.size;
    self.restaurantNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(frameSize.width/2, frameSize.height/2, frameSize.width, frameSize.height * 0.1)];
    self.restaurantNameLabel.textAlignment = NSTextAlignmentCenter;
    self.restaurantNameLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.restaurantNameLabel.text = self.selectedRestaurant.name;
    //[self.view addSubview:self.restaurantNameLabel];
    
    
}

- (void)getFSQRestuarantInfo:(NSString *)restaurantId{
    NSString *completeUrl = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@?client_id=%@&client_secret=%@&v=%@", restaurantId,FOURSQ_CLIENT_ID, FOURSQ_SECRET, @"20170125"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:completeUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSLog(@"%@", json);
        
    }];
    [task resume];
    
}

@end
