//
//  RestaurantAlbumViewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/17/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "RestaurantAlbumViewController.h"
#import "ImageCollectionCell.h"
#import "TPLRestaurantPageViewModel.h"
#import "UserReview.h"
#import "User.h"
#import "ReviewMetricView.h"
#import "UIFont+Extension.h"
#import "FoodWiseDefines.h"
#import "NSString+IsEmpty.h"
#import "FoodheadAnalytics.h"
#import "AnimationPreviewViewController.h"
#import "AssetPreviewViewController.h"
#import "PreviewAnimation.h"
#import "LayoutBounds.h"
#import "AlbumCellNode.h"

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface RestaurantAlbumViewController ()<UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, IDMPhotoBrowserDelegate, UIViewControllerTransitioningDelegate, ASCollectionDelegate, ASCollectionDataSource>

@property (nonatomic, strong) TPLRestaurant *restaurant;

//Texture
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) ASCollectionNode *collectionNode;

//Data source
@property (nonatomic, strong) NSString *nextPg;
@property (nonatomic, strong) NSMutableArray *media;
@property (nonatomic, strong) TPLRestaurantPageViewModel *viewModel;
//@property (nonatomic, strong) AVAsset *asset;
//@property (nonatomic, strong) NSMutableArray *videoAssets;//Cache video assets to prevent reloading of videos for ASVideoNode
@property (nonatomic, strong) NSMutableArray *idmPhotos;
@property (nonatomic, strong) ASBatchContext *batchContext;

//Hold to preview
@property (nonatomic, strong) AnimationPreviewViewController *previewVC;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGest;
@property (nonatomic, assign) BOOL gestureCancelled;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;


@end

static NSString *cellId = @"albumCell";
static NSString *loadingCellId = @"loadingCell";

#define NUM_COLUMNS 3

@implementation RestaurantAlbumViewController

- (instancetype)initWithMedia:(NSMutableArray *)media nextPage:(NSString *)nextPg forRestuarant:(TPLRestaurant *)restaurant{
    if (!(self = [super init])) { return nil; }
    
    _flowLayout = [[UICollectionViewFlowLayout alloc]init];
    _flowLayout.minimumLineSpacing = 1.0;
    _flowLayout.minimumInteritemSpacing = 1.0;
    
    _collectionNode = [[ASCollectionNode alloc] initWithCollectionViewLayout:_flowLayout];
    _collectionNode.delegate = self;
    _collectionNode.dataSource = self;
    
    //Important: Must create a new object here so both the restaurant page and album don't hold the same reference. This is important now because the restaurant page refreshes the media each time it appears so if the user swipes in and out, the restaurant page could remove all the media and refresh this album with an invalid number of items (i.e. Invalid number of items assertion will be thrown).
    _media = media;
    _nextPg = nextPg;
    _restaurant = restaurant;
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.viewModel = [[TPLRestaurantPageViewModel alloc]init];
    self.idmPhotos = [NSMutableArray array];
    
    //Sometimes the long press gesture finishes too fast so we use this to track completion.
    self.gestureCancelled = NO;
    
    NSMutableArray *photoURLs = [NSMutableArray array];
    for (id photoInfo in self.media) {
        IDMPhoto *photo;
        
        //Check if UserReview or insta img
        if ([photoInfo isKindOfClass:[UserReview class]]) {
            UserReview *userReview = (UserReview *)photoInfo;
            photo = [IDMPhoto photoWithURL:[NSURL URLWithString:userReview.imageURL]];
        }else{
            NSURL *photoURL = [[NSURL alloc]initWithString:photoInfo[@"url"]];
            [photoURLs addObject:photoURL];
            photo = [IDMPhoto photoWithURL:photoURL];
        }
        [self.idmPhotos addObject:photo];
    }
    
    [self setupAlbum];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNavBar];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.batchContext cancelBatchFetching];
}

- (void)setupNavBar{
    self.navigationItem.title = self.restaurant.name;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"arrow_back"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exitRestaurantAlbum)];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;//Preserves swipe back gesture
}

- (void)exitRestaurantAlbum{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark - UI

- (void)setupAlbum{
    self.view.backgroundColor = [UIColor whiteColor];
    
    _collectionNode.view.frame = self.view.bounds;
    [self.view addSubnode:_collectionNode];
    
    _collectionNode.view.leadingScreensForBatching = 1.0;
    _collectionNode.backgroundColor = [UIColor whiteColor];
    
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views
    self.collectionNode.view.contentInset = adjustForTabbarInsets;
    self.collectionNode.view.scrollIndicatorInsets = adjustForTabbarInsets;
    self.collectionNode.view.showsVerticalScrollIndicator = NO;
    
    self.longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressGest.minimumPressDuration = 0.15;
    [self.collectionNode.view addGestureRecognizer:self.longPressGest];
}

#pragma mark - Networking

- (void)loadMoreImagesWithContext:(ASBatchContext *)context{
    if (![NSString isEmpty:self.nextPg]) {
        [self.viewModel retrieveImagesForRestaurant:self.restaurant page:self.nextPg completionHandler:^(id completionHandler) {
            self.nextPg = completionHandler[@"next_page"];
            NSArray *images = completionHandler[@"images"];
            
            NSMutableArray *moreMedia = [NSMutableArray array];
            
            if ([NSString isEmpty:self.nextPg] || images.count == 0) return;
            
            for (NSDictionary *photoInfo in images) {
                BOOL isVideo = photoInfo[@"isVideo"];
                if (isVideo) {
                    continue;
                }
                
                if ([photoInfo[@"type"] isEqualToString:USER_REVIEW_PHOTO]) {
                    UserReview *review = [MTLJSONAdapter modelOfClass:[UserReview class] fromJSONDictionary:photoInfo error:nil];
                    User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:photoInfo error:nil];
                    [review mergeValuesForKeysFromModel:user];
                    [moreMedia addObject:review];
                    NSURL *photoURL = [[NSURL alloc]initWithString:review.imageURL];
                    IDMPhoto *photo = [IDMPhoto photoWithURL:photoURL];
                    [self.idmPhotos addObject:photo];
                }else{
                    [moreMedia addObject:photoInfo];
                    NSURL *photoURL = [[NSURL alloc]initWithString:photoInfo[@"url"]];
                    IDMPhoto *photo = [IDMPhoto photoWithURL:photoURL];
                    [self.idmPhotos addObject:photo];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self insertItemsInCollection:moreMedia];
                [self.batchContext completeBatchFetching:YES];
            });
        } failureHandler:^(id failureHandler) {
            DLog(@"Failed to get more images: %@", failureHandler);
            [self.batchContext cancelBatchFetching];
        }];
    }
}


#pragma mark IDMPhotoBrowserDelegate Methods

//Display our custom metric view if it's a user photo
- (IDMCaptionView *)photoBrowser:(IDMPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index{
    id photoInfo = self.media[index];
    if ([photoInfo isKindOfClass:[UserReview class]]) {
        UserReview *userReview = (UserReview *)photoInfo;
        IDMPhoto *photo = [[IDMPhoto alloc]initWithURL:[NSURL URLWithString:userReview.imageURL]];
        ReviewMetricView *ratingView = [[ReviewMetricView alloc]initWithPhoto:photo];
        [ratingView loadReview:userReview];
        return ratingView;
    }
    return nil;
}

- (void)willDisappearPhotoBrowser:(IDMPhotoBrowser *)photoBrowser{
    [FoodheadAnalytics logEvent:ALBUM_SWIPE_COUNT withParameters:@{@"albumSwipeCount" : photoBrowser.pagingCount}];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.gestureCancelled = NO;
        CGPoint p = [gestureRecognizer locationInView:self.collectionNode.view];
        self.selectedIndexPath = [self.collectionNode.view indexPathForItemAtPoint:p];
        
        //Must check if thumbnail has loaded first b/c we need the smaller image to perform animation as
        AlbumCellNode *imgCell = (AlbumCellNode *)[self.collectionNode nodeForItemAtIndexPath:self.selectedIndexPath];
        if (!CGSizeEqualToSize(imgCell.imageNode.image.size, CGSizeZero)) {
            NSDictionary *imgInfo = self.media[self.selectedIndexPath.row];
            NSURL *imgURL = [NSURL URLWithString:imgInfo[@"url"]];
            
            //Init the view controller for previewing
            self.previewVC = [[AnimationPreviewViewController alloc] initWithIndex:0 andImageURL:imgURL withPlaceHolder:imgCell.imageNode.image];
            self.previewVC.modalPresentationCapturesStatusBarAppearance = YES;//Must use this in order to hide the status bar
            self.previewVC.transitioningDelegate = self;
            [self.previewVC setModalPresentationStyle:UIModalPresentationCustom];
            [self presentViewController:self.previewVC animated:YES completion:^{
                if (self.gestureCancelled) {
                    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
                }
            }];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.previewVC dismissViewControllerAnimated:YES completion:nil];
    } else if(gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        self.gestureCancelled = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.previewVC dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    UIImageView *smallImageView;
    UIImageView *bigImageView;
    
    //First lets get the current cell
    AlbumCellNode* cell = (AlbumCellNode*)[self.collectionNode nodeForItemAtIndexPath:self.selectedIndexPath];
    
    //Now lets get the current image
    smallImageView = (UIImageView *)cell.imageNode.view;
    
    //Now lets get the Animation Imageview
    bigImageView = [(AnimationPreviewViewController*)presented imageView];
    
    return [[PreviewAnimation alloc] initWithSmallImageView:smallImageView ToBigImageView:bigImageView];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    UIImageView *smallImageView;
    UIImageView *bigImageView;
    
    //First lets get the current cell
    AlbumCellNode* cell = (AlbumCellNode*)[self.collectionNode nodeForItemAtIndexPath:self.selectedIndexPath];
    
    //Now lets get the current image
    smallImageView = (UIImageView *)cell.imageNode.view;
    
    //Now lets get the Animation Imageview
    bigImageView = [(AnimationPreviewViewController*)dismissed imageView];
    
    return [[PreviewAnimation alloc] initWithSmallImageView:smallImageView ToBigImageView:bigImageView];
}

#pragma mark - ASCollectionNodeDatasource methods

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath{
    id photo = self.media[indexPath.row];
    NSURL *photoURL;
    if ([photo isKindOfClass:[UserReview class]]) {
        UserReview *userReview = (UserReview *)photo;
        photoURL = [NSURL URLWithString:userReview.thumbnailURL];
    }else{
        NSDictionary *imgInfo = self.media[indexPath.row];
        NSString *imgURL = imgInfo[@"thumbnail_url"];
        photoURL = [NSURL URLWithString:imgURL];
    }

    return ^{
        AlbumCellNode *vidNode = [[AlbumCellNode alloc]initWithPhotoURL:photoURL];
        return vidNode;
    };
    
}

- (ASSizeRange)collectionView:(ASCollectionView *)collectionView constrainedSizeForNodeAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = ((CGRectGetWidth(self.view.bounds) - (NUM_COLUMNS - 1.0)) / NUM_COLUMNS) - _flowLayout.minimumInteritemSpacing/2;
    CGSize itemSize = CGSizeMake(itemWidth, itemWidth);
    return ASSizeRangeMake(itemSize);
}

- (NSInteger)numberOfSectionsInCollectionNode:(ASCollectionNode *)collectionNode{
    return 1;
}

- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section{
    return self.media.count;
}

#pragma mark - ASCollectionDelegate methods

- (void)collectionNode:(ASCollectionNode *)collectionNode didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc]initWithPhotos:self.idmPhotos];
    browser.delegate = self;
    browser.useWhiteBackgroundColor = YES;
    browser.displayDoneButton = NO;
    browser.dismissOnTouch = YES;
    browser.displayToolbar = NO;
    browser.autoHideInterface = NO;
    browser.forceHideStatusBar = YES;
    browser.usePopAnimation = YES;
    //browser.disableVerticalSwipe = YES;
    browser.progressTintColor = APPLICATION_BLUE_COLOR;
    [browser trackPageCount];
    
    [browser setInitialPageIndex:indexPath.row];
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark - Helper methods

- (void)insertItemsInCollection:(NSMutableArray *)items{
    NSInteger section = 0;
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger newTotalNumberOfPhotos = self.media.count + items.count;
    for (NSUInteger row = self.media.count; row < newTotalNumberOfPhotos; row++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        [indexPaths addObject:path];
    }
    
    [self.media addObjectsFromArray:items];
    [self.collectionNode insertItemsAtIndexPaths:indexPaths];
}

- (BOOL)shouldBatchFetchForCollectionNode:(ASCollectionNode *)collectionNode{
    if (self.nextPg) {
        return YES;
    }
    return NO;
}

- (void)collectionNode:(ASCollectionNode *)collectionNode willBeginBatchFetchWithContext:(ASBatchContext *)context{
    self.batchContext = context;
    [self loadMoreImagesWithContext:self.batchContext];
}


@end
