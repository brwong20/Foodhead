//
//  Timer.m
//  Foodhead
//
//  Created by Brian Wong on 5/31/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "Timer.h"
#import "FoodheadAnalytics.h"
#import "FoodWiseDefines.h"

@interface Timer ()

@property (nonatomic, weak) NSTimer *homeTimer;
@property (nonatomic, weak) NSTimer *browseTimer;

@property int homeTime;
@property int browseTime;

@end

@implementation Timer


+ (Timer *)sharedInstance
{
    static Timer *timerInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerInstance = [[self alloc]init];
    });
    return timerInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sumTime:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sumTime:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)homeTimeTicked:(NSTimer *)timer{
    ++_homeTime;
}

- (void)browseTimeTicked:(NSTimer *)timer{
    ++_browseTime;
}

- (void)startTrackingHomeTime{
    if (!self.homeTimer) {
        self.homeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(homeTimeTicked:) userInfo:nil repeats:YES];
    }
}

- (void)startTrackingBrowseTime{
    if (!self.browseTimer) {
        self.browseTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(browseTimeTicked:) userInfo:nil repeats:YES];
    }
}

- (void)stopTrackingHomeTime{
    [self.homeTimer invalidate];
    self.homeTimer = nil;
}

- (void)stopTrackingBrowseTime{
    [self.browseTimer invalidate];
    self.browseTimer = nil;
}

- (void)sumTime:(NSNotification *)notif{
    if (_homeTime > 0) {
        NSUInteger totalHome = (int)_homeTime;
        NSUInteger minutes = floor(totalHome % 3600 / 60);
        NSUInteger seconds = floor(totalHome % 3600 % 60);
        NSString *homeStr = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)minutes, (unsigned long)seconds];
        _homeTime = 0;
        [FoodheadAnalytics logEvent:TIME_SPENT_HOME withParameters:@{@"homeTime" : homeStr}];
    }
    
    if (_browseTime > 0) {
        NSUInteger totalBrowse = (int)_browseTime;
        NSUInteger minBrowse = floor(totalBrowse % 3600 / 60);
        NSUInteger secBrowse = floor(totalBrowse % 3600 % 60);
        NSString *browseStr = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)minBrowse, (unsigned long)secBrowse];
        _browseTime = 0;
        [FoodheadAnalytics logEvent:TIME_SPENT_BROWSE withParameters:@{@"browseTime" : browseStr}];
    }
}

@end
