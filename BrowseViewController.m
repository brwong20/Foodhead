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
#import "BrowseVideoRealm.h"

#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <SDWebImage/SDWebImageManager.h>

@interface BrowseViewController () <ASTableDelegate, ASTableDataSource, BrowsePlayerNodeDelegate>


//UI
@property (nonatomic, strong) ASTableNode *tableNode;

//Data source
@property (nonatomic, strong) BrowseContentManager *contentManager;
@property (nonatomic, strong) NSMutableArray *videoArr;
@property (nonatomic, strong) NSMutableArray *assetArr; //Caches our assets to prevent reloading as well as saving stopped play position
@property (nonatomic, strong) RLMNotificationToken *favVideoNotif;
@property (nonatomic, strong) RLMResults *favoriteVideos;
@property (nonatomic, strong) NSMutableDictionary *favoriteIndexes;


//Auto play properties
@property (nonatomic, assign) BOOL scrollingDown;
@property (nonatomic, assign) BOOL isInitialLoad;
@property (nonatomic, strong) NSIndexPath *currentPlayingIndex;

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
    self.favoriteIndexes = [NSMutableDictionary dictionary];
    self.isInitialLoad = YES;
    
    self.contentManager = [[BrowseContentManager alloc]init];
    [self getBrowseContent];
    
    self.favoriteVideos = [BrowseVideoRealm allObjects];
    __weak typeof(self) weakSelf = self;
    self.favVideoNotif = [self.favoriteVideos addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        if (error) {
            DLog(@"Couldn't create favorite video notification block: %@", error);
        }
        
        if (!change) {
            return;
        }
        
        if ([change deletionsInSection:0].count > 0) {
            [weakSelf deleteFavorites:[change deletionsInSection:0]];
        }
        
    }];
    
    self.tableNode.frame = self.view.bounds;
    UIEdgeInsets adjustForBarInsets = UIEdgeInsetsMake(15.0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame) + 5.0, 0);//Adjust for tab bar height covering views
    self.tableNode.view.contentInset = adjustForBarInsets;
    self.tableNode.view.scrollIndicatorInsets = adjustForBarInsets;
    self.tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableNode.view.bounces = NO;
    [self.view addSubnode:self.tableNode];
    
    //Will make our status bar opaque
    UIView *statusBarBg = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    statusBarBg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:statusBarBg];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Necessary to play background media along with videos
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
}

#pragma mark - ASTableDataSource methods

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    BrowseVideo *video = self.videoArr[indexPath.row];
    
    //Check if restaurant is a favorite through its primary key
    RLMResults *favResult = [self.favoriteVideos objectsWithPredicate:[NSPredicate predicateWithFormat:@"videoId == %@", video.videoId]];
    BrowseVideoRealm *favVid = [favResult firstObject];
    NSNumber *primaryKey;
    if (favVid) {
        primaryKey = favVid.videoId;
    }
    
    return ^{
        BrowseVideo *video = self.videoArr[indexPath.row];
        BrowsePlayerNode *vidNode = [[BrowsePlayerNode alloc]initWithVideo:video andPrimaryKey:primaryKey];
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
    
    NSDictionary *cachedAsset = self.assetArr[indexPath.row];
    if (![cachedAsset isEqual:[NSNull null]]) {
        //If we have already loaded an asset, use it.
        AVAsset *asset = cachedAsset[@"asset"];
        NSNumber *lastPlayTime = cachedAsset[@"lastPlayTime"];
        
        UIImage *lastFrame = cachedAsset[@"lastFrame"];
        [vidNode setPlaceholderImage:lastFrame];
        
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
        BrowseVideo *video = self.videoArr[indexPath.row];
        NSString *vidLink = video.videoLink;
        if ([video.isYoutubeVideo boolValue]) {
            NSString *thumbURL = [NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/hqdefault.jpg", vidLink];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:thumbURL] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                [vidNode setPlaceholderImage:image];
            }];
            
            [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:video.videoLink completionHandler:^(XCDYouTubeVideo * _Nullable video, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error);
                }else{
                    //TODO: Eventually load 720p only if fullscreen?
                    NSURL *vidURL = [video.streamURLs objectForKey:@(XCDYouTubeVideoQualityMedium360)];
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
                //[self loadPlaceHolderWithAsset:asset forNode:vidNode];
            
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

//- (void)loadPlaceHolderWithAsset:(AVAsset *)asset forNode:(BrowsePlayerNode *)vidNode{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        //Cache last frame as well so it looks like we never stopped playing
//        AVAssetImageGenerator *previewImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
//        previewImageGenerator.appliesPreferredTrackTransform = YES;
//        [previewImageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:CMTimeMake(1.0, 1.0)]]
//                                                    completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
//                                                        if (error != nil && result != AVAssetImageGeneratorCancelled) {
//                                                            NSLog(@"Asset preview image generation failed with error: %@", error);
//                                                        }
//                                                        
//                                                        UIImage *firstFrame = [UIImage imageWithCGImage:image];
//                                                        dispatch_async(dispatch_get_main_queue(), ^{
//                                                            [vidNode setPlaceholderImage:firstFrame];
//                                                            //CGImageRelease(image);
//                                                        });
//                                                    }];
//    });
//}

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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    self.scrollingDown = ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y >0) ? NO : YES;
    //If user scrolls very fast, nothing should play/pause in order to optimize scroll performance
    if (![self checkUserIsScrollingFast:scrollView]) {
        [self checkVideoToPlay];
    }
    
    //ensure that the end of scroll is fired.
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //[self checkVideoToPlay];
}


- (void)checkVideoToPlay{
    for(BrowsePlayerNode *node in [self.tableNode visibleNodes]){
        NSIndexPath *indexPath = [self.tableNode indexPathForNode:node];
        CGRect cellRect = [self.tableNode rectForRowAtIndexPath:indexPath];

        //If we want to check based on actual video player frame
//        CGRect videoRect = [node.videoNode.view convertRect:node.videoNode.bounds toView:self.view];
//        CGRect intersect = CGRectIntersection(self.tableNode.view.frame, videoRect);

        UIView *superview = self.tableNode.view.superview;
        CGRect convertedRect=[self.tableNode.view convertRect:cellRect toView:superview];
        CGRect intersect = CGRectIntersection(self.tableNode.view.frame, convertedRect);
        float visibleHeight = CGRectGetHeight(intersect);
        
         //Only if more than 85% of the cell is visible is it considered to be playable
        if(visibleHeight > node.view.frame.size.height * 0.85){
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
    }
    
    //Cache the favorited video's index so we can easily delete them later.
    for (BrowseVideo *video in items) {
        [self.videoArr addObject:video];
        [self.assetArr addObject:[NSNull null]];
        RLMResults *favResult = [self.favoriteVideos objectsWithPredicate:[NSPredicate predicateWithFormat:@"videoId == %@", video.videoId]];
        BrowseVideoRealm *favVid = [favResult firstObject];
        if (favVid) {
            NSUInteger collectionIndex = [self.videoArr indexOfObject:video];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:collectionIndex inSection:0];
            [self.favoriteIndexes setObject:indexPath forKey:video.videoId];
        }
    }
    
    [self.tableNode insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - BrowsePlayerNode Delegate methods

- (void)browsePlayerNode:(BrowsePlayerNode *)node didChangePlayerState:(ASVideoNodePlayerState)state{
    //All other videos should stop playing if user chooses to play a specific video
    if (state == ASVideoNodePlayerStatePlaying) {
        for (BrowsePlayerNode *playerNode in [self.tableNode visibleNodes]) {
            if (playerNode != node) {
                [playerNode.videoNode pause];
            }
        }
    }
}

#pragma mark - Helper Methods

- (NSMutableDictionary *)saveAssetWithTime:(BrowsePlayerNode *)playerNode{
    NSMutableDictionary *assetDict = [NSMutableDictionary dictionary];
    [assetDict setObject:playerNode.videoNode.asset forKey:@"asset"];
    CGFloat seconds = CMTimeGetSeconds(playerNode.videoNode.videoNode.player.currentTime);
    [assetDict setObject:@(seconds) forKey:@"lastPlayTime"];
    
    //Cache last frame as well so it looks like we never stopped playing
    AVAssetImageGenerator *previewImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:playerNode.videoNode.asset];
    previewImageGenerator.appliesPreferredTrackTransform = YES;
    [previewImageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:playerNode.videoNode.videoNode.player.currentTime]]
                                                completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
                                                    if (error != nil && result != AVAssetImageGeneratorCancelled) {
                                                        NSLog(@"Asset preview image generation failed with error: %@", error);
                                                    }
                                                    
                                                    UIImage *lastFrame = [UIImage imageWithCGImage:image];
                                                    [assetDict setObject:lastFrame forKey:@"lastFrame"];
                                                }];
    
    return assetDict;
}

- (void)browsePlayerNode:(BrowsePlayerNode *)node wasFavorited:(BrowseVideoRealm *)favorite{
    NSIndexPath *indexPath = [self.tableNode indexPathForNode:node];
    [self.favoriteIndexes setObject:indexPath forKey:favorite.videoId];
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
        if (scrollSpeed > 0.3) {
            _isScrollingFast = YES;
        } else {
            _isScrollingFast = NO;
        }
        
        _lastOffset = currentOffset;
        _lastOffsetCapture = currentTime;
    }
    return _isScrollingFast;
}

- (void)deleteFavorites:(NSArray<NSIndexPath*> *)deleted{
    //Find the deleted restaurant(s) based on our cached collection
    NSArray *favIds = [self.favoriteIndexes allKeys];
    for (NSNumber *videoId in favIds) {
        //If the restaurant was deleted we shouldn't be able to find it in our updated RLMResults. Guaranteed to only return one object since the foursqId is a primary key
        RLMResults *results = [self.favoriteVideos objectsWithPredicate:[NSPredicate predicateWithFormat:@"videoId == %@", videoId]];
        BrowseVideoRealm *isFav = [results firstObject];
        if (!isFav) {
            //If not a favorite anymore, get the node at previously stored index path and update it
            BrowsePlayerNode *node = [self.tableNode nodeForRowAtIndexPath:[self.favoriteIndexes objectForKey:videoId]];
            [node toggleUnfavorite];
            //Finally, update our local favorite dictionary.
            [self.favoriteIndexes removeObjectForKey:videoId];
        }
    }
}


@end
