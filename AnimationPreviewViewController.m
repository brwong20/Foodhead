//
//  AnimationPreviewViewController.m
//  Joyspace
//
//  Created by Amir Hizkiya on 6/5/15.
//  Copyright (c) 2015 Taplet Inc. All rights reserved.
//

#import "AnimationPreviewViewController.h"

@interface AnimationPreviewViewController ()

@property (assign) BOOL isNavbarHidden;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@end

@implementation AnimationPreviewViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isNavbarHidden = NO;
    //self.view.backgroundColor = [UIColor clearColor];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.frame = APPLICATION_FRAME;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.blurEffectView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isNavbarHidden = YES;
    
    //[UIView animateWithDuration:0.3 animations:^{
    //   [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    //}];
}

-(PHImageRequestOptions*)getOptionsForClass
{
    PHImageRequestOptions *options =[[PHImageRequestOptions alloc] init];
    
    //Need to load the full res image
    
    
    //If we are dealing with a video its complicated to load async
    if (self.currentAsset.mediaType == PHAssetMediaTypeVideo) {
        options.synchronous = YES;
    } else {
        options.synchronous = YES;
    }
    
    return options;
}

-(void)updateViewsForRotation
{
    [super updateViewsForRotation];
    
    self.blurEffectView.frame = APPLICATION_FRAME;
    
}


#pragma mark Operating System delegate methods
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    
    // Code here will execute before the rotation begins.
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        
        [self updateViewsForRotation];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Code here will execute after the rotation has finished.
        
    }];
}
@end
