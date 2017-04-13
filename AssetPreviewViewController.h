//
//  AssetPreviewViewController.h
//  Joyspace
//
//  Created by Amir Hizkiya on 6/5/15.
//  Copyright (c) 2015 Taplet Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "SDWebImageManager.h"
//#import "SDImageCache.h"

@import Photos;

@interface AssetPreviewViewController : UIViewController

@property (assign) NSInteger pageindex;
@property (nonatomic, strong) PHAsset *currentAsset;


@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSString* videoGravity;

//@property (nonatomic, strong) SDImageCache *imageCache;

-(instancetype)initWithIndex:(NSUInteger)index andAsset:(PHAsset*)asset;

-(PHImageRequestOptions*)getOptionsForClass;

-(void)updateViewsForRotation;
-(NSObject*)getAssetObjectToShare;

@end
