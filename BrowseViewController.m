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
@property (nonatomic, assign) BOOL scrollingDown;

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
    
    self.contentManager = [[BrowseContentManager alloc]init];
    [self getBrowseContent];
    
    self.tableNode.frame = self.view.bounds;
    UIEdgeInsets adjustForBarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views
    self.tableNode.view.contentInset = adjustForBarInsets;
    self.tableNode.view.scrollIndicatorInsets = adjustForBarInsets;
    self.tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubnode:self.tableNode];
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
    
    __weak typeof(self) weakSelf = self;
    if (vidNode.videoNode.asset == nil) {
//        NSDictionary *cachedAsset = self.assetArr[indexPath.row];
//        if (![cachedAsset isEqual:[NSNull null]]) {
//            AVAsset *asset = cachedAsset[@"asset"];
//            NSNumber *lastPlayTime = cachedAsset[@"lastPlayTime"];
//            CMTime tm = CMTimeMake(lastPlayTime.floatValue, 10000);
//            vidNode.videoNode.asset = asset;
//            //[vidNode.videoNode.player seekToTime:tm];
//        }else{
            if ([video.isYoutubeVideo boolValue]) {
                [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:video.videoLink completionHandler:^(XCDYouTubeVideo * _Nullable video, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"%@", error);
                    }else{
                        NSURL *vidURL = [video.streamURLs objectForKey:@(XCDYouTubeVideoQualityHD720)];
                        AVAsset *asset = [AVAsset assetWithURL:vidURL];
                        weakSelf.assetArr[indexPath.row] = asset;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            vidNode.videoNode.asset = asset;
                            //vidNode.videoNode.URL = video.smallThumbnailURL;
                        });
                    }
                }];
            }else{
                //Shouldn't have a block within a block...
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSURL *vidURL;
                    vidURL = [NSURL URLWithString:vidLink];
                    AVAsset *asset = [AVAsset assetWithURL:vidURL];
                    weakSelf.assetArr[indexPath.row] = asset;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        vidNode.videoNode.asset = asset;
                        
                        //Always start playing first video
                        if(indexPath.row == 0){
                            [vidNode.videoNode play];
                            self.currentPlayingIndex = indexPath;
                        }
                    });
                });
            }
        //}
        //vidNode.videoNode.URL = [NSURL URLWithString:@"https://s-media-cache-ak0.pinimg.com/originals/c6/34/03/c634035de2d41fbe8e98f61961fe6179.png"];
    }
}

- (void)tableNode:(ASTableNode *)tableNode didEndDisplayingRowWithNode:(ASCellNode *)node{
    BrowsePlayerNode *videoNode = (BrowsePlayerNode *)node;
    
    NSDictionary *assetInfo = [NSMutableDictionary dictionary];
    [assetInfo setValue:videoNode.videoNode.asset forKey:@"asset"];
    //[assetInfo setValue:@(CMTimeGetSeconds(videoNode.videoNode.player.currentTime)) forKey:@"lastPlayTime"];
    [self.assetArr addObject:assetInfo];
}

#pragma mark - ASTableNodeDelegate methods


#pragma mark - ScrollViewDelegate methods

//Videos will resume playing once user scrolling stops and/or user stops scrolling
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrollingDown = ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y >0) ? NO : YES;
    [self checkVideoToPlay];
}


- (void)checkVideoToPlay{
    for(BrowsePlayerNode *node in [self.tableNode visibleNodes])
    {
        NSIndexPath *indexPath = [self.tableNode indexPathForNode:node];
        CGRect cellRect = [self.tableNode rectForRowAtIndexPath:indexPath];
        UIView *superview = self.tableNode.view.superview;
        
        CGRect convertedRect=[self.tableNode.view convertRect:cellRect toView:superview];
        CGRect intersect = CGRectIntersection(self.tableNode.view.frame, convertedRect);
        float visibleHeight = CGRectGetHeight(intersect);
        
         //Only if more than 60% of the cell is visible is it considered to be playable
        if(visibleHeight > node.view.frame.size.height * 0.75){
            //In the case that there are two video cells on the screen (i.e both are visible). We will play the second of the two cells if the user is scrolling down, and the first if user is scrolling up. We will also cache any paused nodes and save their play time.
            if (self.currentPlayingIndex > indexPath && !self.scrollingDown) {
                BrowsePlayerNode *nextNode = [self.tableNode nodeForRowAtIndexPath:self.currentPlayingIndex];
                [nextNode.videoNode pause];
                
                //[self.assetArr insertObject:[self saveAssetWithTime:nextNode] atIndex:self.currentPlayingIndex.row];;//Cache paused asset
                
                //Current node to play (the one "on top")
                [node.videoNode play];
                self.currentPlayingIndex = indexPath;
            }else if (self.currentPlayingIndex < indexPath && self.scrollingDown){
                BrowsePlayerNode *prevNode = [self.tableNode nodeForRowAtIndexPath:self.currentPlayingIndex];
                [prevNode.videoNode pause];
                
                //[self.assetArr insertObject:[self saveAssetWithTime:prevNode] atIndex:self.currentPlayingIndex.row];
;//Cache paused asset
                
                //Current node to play (the one on the "bottom")
                [node.videoNode play];
                self.currentPlayingIndex = indexPath;
            }
        }else{
            //[self.assetArr insertObject:[self saveAssetWithTime:node] atIndex:indexPath.row];
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
        
        //[self.assetArr addObject:[NSNull null]];
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

//- (NSMutableDictionary *)saveAssetWithTime:(BrowsePlayerNode *)playerNode{
//    NSMutableDictionary *assetDict = [NSMutableDictionary dictionary];
//    [assetDict setObject:playerNode.videoNode.asset forKey:@"asset"];
//    CGFloat seconds = CMTimeGetSeconds(playerNode.videoNode.player.currentTime);
//    [assetDict setObject:@(seconds) forKey:@"lastPlayTime"];
//    
//    return assetDict;
//}

@end
