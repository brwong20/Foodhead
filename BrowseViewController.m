//
//  BrowseViewController.m
//  Foodhead
//
//  Created by Brian Wong on 4/29/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "BrowseViewController.h"
#import "BrowsePlayerNode.h"
#import "FoodWiseDefines.h"
#import "BrowseContentManager.h"

#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface BrowseViewController () <ASTableDelegate, ASTableDataSource, BrowsePlayerNodeDelegate>

@property (nonatomic, strong) BrowseContentManager *contentManager;

@property (nonatomic, strong) ASTableNode *tableNode;
@property (nonatomic, strong) NSMutableArray *videoArr;
@property (nonatomic, strong) NSMutableArray *assetArr; //Caches our assets to prevent reloading as well as saving stopped play position

@property (nonatomic, strong) NSIndexPath *currentPlayingIndex;


//Auto play properties
@property (nonatomic, assign) BOOL scrollingDown;
@property (nonatomic, assign) BOOL isInitialLoad;

//Tracks how fast user scrolls
@property (nonatomic, assign) CGPoint lastOffset;
@property (nonatomic, assign) NSTimeInterval lastOffsetCapture;
@property (nonatomic, assign) BOOL isScrollingFast;


@end

@implementation BrowseViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.tableNode = [[ASTableNode alloc]initWithStyle:UITableViewStylePlain];
        self.tableNode.delegate = self;
        self.tableNode.dataSource = self;
        self.tableNode.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.navigationController.navigationBar setHidden:YES];
    
    self.videoArr = [NSMutableArray array];
    self.assetArr = [NSMutableArray array];
    self.isInitialLoad = YES;
    
    self.contentManager = [[BrowseContentManager alloc]init];
    [self getBrowseContent];
    
    self.tableNode.frame = self.view.bounds;
    UIEdgeInsets adjustForBarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views
    self.tableNode.view.contentInset = adjustForBarInsets;
    self.tableNode.view.scrollIndicatorInsets = adjustForBarInsets;
    self.tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubnode:self.tableNode];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Necessary to play background media along with videos
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
}

#pragma mark - ASTableDataSource methods

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return ^{
        BrowseVideo *video = self.videoArr[indexPath.row];
        BrowsePlayerNode *vidNode = [[BrowsePlayerNode alloc]initWithVideo:video];
        vidNode.delegate = self;
        return vidNode;
    };
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section{
    return self.videoArr.count;
}

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode{
    return 1;
}

- (void)tableNode:(ASTableNode *)tableNode willDisplayRowWithNode:(ASCellNode *)node{
    NSIndexPath *indexPath = [self.tableNode indexPathForNode:node];
    BrowsePlayerNode *vidNode = (BrowsePlayerNode *)node;
    BrowseVideo *video = self.videoArr[indexPath.row];
    NSString *vidLink = video.videoLink;
    
    NSDictionary *cachedAsset = self.assetArr[indexPath.row];
    if (![cachedAsset isEqual:[NSNull null]]) {
        //If we have already loaded an asset, use it.
        AVAsset *asset = cachedAsset[@"asset"];
        NSNumber *lastPlayTime = cachedAsset[@"lastPlayTime"];
        vidNode.videoNode.asset = asset;
        
        //If video has been played, resume the last time the user stopped at.
        NSArray *keys = @[@"playable", @"duration", @"tracks"];
        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
            NSError *error;
            for (NSString *key in keys) {
                AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                if (keyStatus == AVKeyValueStatusFailed) {
                    DLog(@"Failed to load key : %@ with error: %@", key, error);
                }
            }
            
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    vidNode.videoNode.asset = asset;
                    int32_t timeScale = asset.duration.timescale;
                    CMTime time = CMTimeMakeWithSeconds(lastPlayTime.floatValue, timeScale);
                    [vidNode.videoNode.videoNode.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                });
            }
            
        }];
    }else{
        if ([video.isYoutubeVideo boolValue]) {
            [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:video.videoLink completionHandler:^(XCDYouTubeVideo * _Nullable video, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error);
                }else{
                    NSURL *vidURL = [video.streamURLs objectForKey:@(XCDYouTubeVideoQualityHD720)];
                    AVAsset *asset = [AVAsset assetWithURL:vidURL];
                    
                    NSArray *keys = @[@"playable", @"duration", @"tracks"];//This is an extra optimization to not load the asset into the video player unless it's completely ready to be played.
                    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                        NSError *error;
                        for (NSString *key in keys) {
                            AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                            if (keyStatus == AVKeyValueStatusFailed) {
                                DLog(@"Failed to load key : %@ with error: %@", key, error);
                            }
                        }
                        
                        if (!error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                vidNode.videoNode.asset = asset;
                            });
                        }
                    }];
                }
            }];
        }else{
            //Only set the asset for the video node until absolutley necessary, otherwise Texture will perform uneccssary AVPlayer work and slow down the UI.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSURL *vidURL;
                vidURL = [NSURL URLWithString:vidLink];
                AVAsset *asset = [AVAsset assetWithURL:vidURL];
                NSArray *keys = @[@"playable"];
                [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                    NSError *error;
                    for (NSString *key in keys) {
                        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                        if (keyStatus == AVKeyValueStatusFailed) {
                            DLog(@"Failed to load key : %@ with error: %@", key, error);
                        }
                    }
                    
                    if (!error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            vidNode.videoNode.asset = asset;
                        });
                    }
                }];
            });
        }

        //Always start playing the first video on initial screen load (i.e. When user first opens the app)
        if (self.isInitialLoad && indexPath.row == 0) {
            [vidNode.videoNode play];
            self.currentPlayingIndex = indexPath;
            self.isInitialLoad = NO;
        }
    }
}

- (void)tableNode:(ASTableNode *)tableNode didEndDisplayingRowWithNode:(ASCellNode *)node{
    BrowsePlayerNode *vidNode = (BrowsePlayerNode *)node;
    NSIndexPath *index = [self.tableNode indexPathForNode:node];
    //Asset might not have loaded yet so don't try saving
    if (vidNode.videoNode.asset) {
       self.assetArr[index.row] = [self saveAssetWithTime:vidNode];
    }
}

#pragma mark - ASTableNodeDelegate methods


#pragma mark - ScrollViewDelegate methods

//Videos will resume playing once user scrolling stops and/or user stops scrolling
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrollingDown = ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y >0) ? NO : YES;
    //If user scrolls very fast, nothing should play/pause in order to optimize scroll performance
    if (![self checkUserIsScrollingFast:scrollView]) {
        [self checkVideoToPlay];
    }
}


- (void)checkVideoToPlay{
    for(BrowsePlayerNode *node in [self.tableNode visibleNodes]){
        NSIndexPath *indexPath = [self.tableNode indexPathForNode:node];
        CGRect cellRect = [self.tableNode rectForRowAtIndexPath:indexPath];
        UIView *superview = self.tableNode.view.superview;
        
        CGRect convertedRect=[self.tableNode.view convertRect:cellRect toView:superview];
        CGRect intersect = CGRectIntersection(self.tableNode.view.frame, convertedRect);
        float visibleHeight = CGRectGetHeight(intersect);
        
         //Only if more than 80% of the cell is visible is it considered to be playable
        if(visibleHeight > node.view.frame.size.height * 0.8){
            //In the case that there are two video cells on the screen (i.e both are visible). We will play the second of the two cells if the user is scrolling down, and the first if user is scrolling up. We will also cache any paused nodes and save their play time.
            if (self.currentPlayingIndex > indexPath && !self.scrollingDown) {
                BrowsePlayerNode *nextNode = [self.tableNode nodeForRowAtIndexPath:self.currentPlayingIndex];
                [nextNode.videoNode pause];
                
                //Current node to play (the one "on top")
                [node.videoNode play];
                self.currentPlayingIndex = indexPath;
            }else if (self.currentPlayingIndex < indexPath && self.scrollingDown){
                BrowsePlayerNode *prevNode = [self.tableNode nodeForRowAtIndexPath:self.currentPlayingIndex];
                [prevNode.videoNode pause];
                
                //Current node to play (the one on the "bottom")
                [node.videoNode play];
                self.currentPlayingIndex = indexPath;
            }
        }else{
            [node.videoNode pause];
        }
    }
}

#pragma mark - BrowseContentManager

- (void)getBrowseContent{
    [self.contentManager getBrowseContentWithCompletion:^(NSMutableArray *media) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self insertItemsInTable:media];
        });
    } failureHandler:^(id error) {
        NSLog(@"%@", error);
    }];
    
}

- (void)insertItemsInTable:(NSMutableArray *)items{
    NSInteger section = 0;
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger newTotalNumberOfPhotos = self.videoArr.count + items.count;
    for (NSUInteger row = self.videoArr.count; row < newTotalNumberOfPhotos; row++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        [indexPaths addObject:path];

        [self.assetArr addObject:[NSNull null]];
    }
    
    [self.videoArr addObjectsFromArray:items];
    [self.tableNode insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - BrowsePlayerNode Delegate methods

- (void)playBackButtonTappedForNode:(BrowsePlayerNode *)node withState:(ASVideoNodePlayerState)state{
//    for (BrowsePlayerNode *vidNode in self.tableNode.visibleNodes) {
//        if ([vidNode isEqual:node]) {
//            [vidNode.videoNode pause];
//        }
//    }
}

#pragma mark - Helper Methods

- (NSMutableDictionary *)saveAssetWithTime:(BrowsePlayerNode *)playerNode{
    NSMutableDictionary *assetDict = [NSMutableDictionary dictionary];
    [assetDict setObject:playerNode.videoNode.asset forKey:@"asset"];
    CGFloat seconds = CMTimeGetSeconds(playerNode.videoNode.videoNode.player.currentTime);
    [assetDict setObject:@(seconds) forKey:@"lastPlayTime"];
    
    return assetDict;
}

//Taken from stackoverflow to check how fast user is scrolling
- (BOOL)checkUserIsScrollingFast:(UIScrollView *)scrollView{
    CGPoint currentOffset = scrollView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - _lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - _lastOffset.y;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        
        CGFloat scrollSpeed = fabs(scrollSpeedNotAbs);
        if (scrollSpeed > 0.5) {
            _isScrollingFast = YES;
        } else {
            _isScrollingFast = NO;
        }
        
        _lastOffset = currentOffset;
        _lastOffsetCapture = currentTime;
    }
    return _isScrollingFast;
}

@end
