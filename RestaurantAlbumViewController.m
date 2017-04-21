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

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImagePrefetcher.h>

@interface RestaurantAlbumViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, IDMPhotoBrowserDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) TPLRestaurantPageViewModel *viewModel;

@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, strong) NSMutableArray *idmPhotos;
@property (nonatomic, assign) BOOL requestingImages;//Makes sure user doesn't run multiple requests for more images

@property (nonatomic, strong) AnimationPreviewViewController *previewVC;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGest;
@property (nonatomic, assign) BOOL gestureCancelled;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

static NSString *cellId = @"albumCell";
static NSString *loadingCellId = @"loadingCell";

#define NUM_COLUMNS 3

@implementation RestaurantAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.viewModel = [[TPLRestaurantPageViewModel alloc]init];
    self.idmPhotos = [NSMutableArray array];
    self.requestingImages = NO;
    
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
}

- (void)setupNavBar{
    self.navigationItem.title = self.restaurant.name;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont nun_mediumFontWithSize:APPLICATION_FRAME.size.width * 0.06]};
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
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 1.0;
    flowLayout.minimumInteritemSpacing = 1.0;
        
    self.photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
    self.photoCollectionView.backgroundColor = [UIColor whiteColor];
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);//Adjust for tab bar height covering views
    self.photoCollectionView.contentInset = adjustForTabbarInsets;
    self.photoCollectionView.scrollIndicatorInsets = adjustForTabbarInsets;
    self.photoCollectionView.showsVerticalScrollIndicator = NO;
    [self.photoCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.photoCollectionView];
    
    self.longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressGest.minimumPressDuration = 0.15;
    [self.photoCollectionView addGestureRecognizer:self.longPressGest];
}

#pragma mark - Networking

- (void)loadMoreImages{
    if (![NSString isEmpty:self.nextPg]) {
        self.requestingImages = YES;
        [self.viewModel retrieveImagesForRestaurant:self.restaurant page:self.nextPg completionHandler:^(id completionHandler) {
            self.nextPg = completionHandler[@"next_page"];
            NSArray *images = completionHandler[@"images"];
            
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
                    [self.media addObject:review];
                    NSURL *photoURL = [[NSURL alloc]initWithString:review.imageURL];
                    IDMPhoto *photo = [IDMPhoto photoWithURL:photoURL];
                    [self.idmPhotos addObject:photo];
                }else{
                    [self.media addObject:photoInfo];
                    NSURL *photoURL = [[NSURL alloc]initWithString:photoInfo[@"url"]];
                    IDMPhoto *photo = [IDMPhoto photoWithURL:photoURL];
                    [self.idmPhotos addObject:photo];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.requestingImages = NO;
                [self.photoCollectionView reloadData];
            });
        } failureHandler:^(id failureHandler) {
            DLog(@"Failed to get more images: %@", failureHandler);
            self.requestingImages = NO;
        }];
    }
}

#pragma mark - UICollectionViewDatasource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self photoCellForIndexPath:indexPath];
}

- (UICollectionViewCell *)photoCellForIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionCell *cell = [self.photoCollectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
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
    
    [cell.coverImageView sd_setImageWithURL:photoURL placeholderImage:[UIImage new] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (cacheType == SDImageCacheTypeNone) {
            cell.coverImageView.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                cell.coverImageView.alpha = 1.0;
            }];
        }else{
            cell.coverImageView.alpha = 1.0;
        }
    }];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.media.count;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc]initWithPhotos:self.idmPhotos];
    browser.delegate = self;
    browser.useWhiteBackgroundColor = YES;
    browser.displayDoneButton = NO;
    browser.dismissOnTouch = YES;
    browser.displayToolbar = NO;
    browser.autoHideInterface = NO;
    browser.forceHideStatusBar = YES;
    browser.usePopAnimation = YES;
    browser.disableVerticalSwipe = YES;
    browser.progressTintColor = APPLICATION_BLUE_COLOR;
    [browser trackPageCount];
    
    
    [browser setInitialPageIndex:indexPath.row];
    [self presentViewController:browser animated:YES completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.media.count - 6 && !self.requestingImages) {
        [self loadMoreImages];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout 

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat itemWidth = (CGRectGetWidth(self.view.frame) - (NUM_COLUMNS - 1.0)) / NUM_COLUMNS;
    return CGSizeMake(itemWidth, itemWidth);
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
        CGPoint p = [gestureRecognizer locationInView:self.photoCollectionView];
        self.selectedIndexPath = [self.photoCollectionView indexPathForItemAtPoint:p];
        
        //Must check if thumbnail has loaded first b/c we need the smaller image to perform animation as
        ImageCollectionCell *imgCell = (ImageCollectionCell *)[self.photoCollectionView cellForItemAtIndexPath:self.selectedIndexPath];
        if (!CGSizeEqualToSize(imgCell.coverImageView.image.size, CGSizeZero)) {
            NSDictionary *imgInfo = self.media[self.selectedIndexPath.row];
            NSURL *imgURL = [NSURL URLWithString:imgInfo[@"url"]];
            
            //Init the view controller for previewing
            self.previewVC = [[AnimationPreviewViewController alloc] initWithIndex:0 andImageURL:imgURL withPlaceHolder:imgCell.coverImageView.image];
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
    ImageCollectionCell* cell = (ImageCollectionCell*)[self.photoCollectionView cellForItemAtIndexPath:self.selectedIndexPath];
    
    //Now lets get the current image
    smallImageView = cell.coverImageView;
    
    //Now lets get the Animation Imageview
    bigImageView = [(AnimationPreviewViewController*)presented imageView];
    
    return [[PreviewAnimation alloc] initWithSmallImageView:smallImageView ToBigImageView:bigImageView];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    UIImageView *smallImageView;
    UIImageView *bigImageView;
    
    //First lets get the current cell
    ImageCollectionCell* cell = (ImageCollectionCell*)[self.photoCollectionView cellForItemAtIndexPath:self.selectedIndexPath];
    
    //Now lets get the current image
    smallImageView = cell.coverImageView;
    
    //Now lets get the Animation Imageview
    bigImageView = [(AnimationPreviewViewController*)dismissed imageView];
    
    return [[PreviewAnimation alloc] initWithSmallImageView:smallImageView ToBigImageView:bigImageView];
}

@end
