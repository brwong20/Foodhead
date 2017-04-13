//
//  PreviewAnimation.m
//  Joyspace
//
//  Created by Amir Hizkiya on 6/5/15.
//  Copyright (c) 2015 Taplet Inc. All rights reserved.
//

#import "PreviewAnimation.h"
#import <AVFoundation/AVUtilities.h>

@interface PreviewAnimation()

@property (nonatomic, strong)UIImageView *smallImageViewRef;
@property (nonatomic, strong)UIImageView *bigImageViewRef;
@property (nonatomic, strong)UIVisualEffectView *blurEffectView;
@end
@implementation PreviewAnimation

#define BLUR_TAG @"blurEffectView"
- (instancetype)initWithSmallImageView:(UIImageView*)smallImageView ToBigImageView:(UIImageView*)bigImageView
{
    self = [super init];
    if (self) {
        _smallImageViewRef = smallImageView;
        _bigImageViewRef = bigImageView;
        
        //First lets add the blur view to the View
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blurEffectView.frame = APPLICATION_FRAME;
        self.blurEffectView.tag = [BLUR_TAG hash];
        
    }
    return self;
}

#pragma mark UIViewControllerAnimatedTransitioning methods
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (viewController.isBeingPresented) {
        [self animateZoomInTransition:transitionContext];
    }
    else {
        [self animateZoomOutTransition:transitionContext];
    }
}

- (void)animateZoomInTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get the view controllers participating in the transition
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    //First lets add the blur view to the View
    [fromViewController.view addSubview:self.blurEffectView];
    
    toViewController.view.alpha = 0;
    
    // Create a temporary view for the zoom in transition and set the initial frame based
    // on the reference image view
    UIImageView *transitionView = [[UIImageView alloc] initWithImage:self.smallImageViewRef.image];
    transitionView.contentMode = UIViewContentModeScaleAspectFill;
    transitionView.clipsToBounds = YES;
    transitionView.frame = [transitionContext.containerView convertRect:self.smallImageViewRef.bounds
                                                               fromView:self.smallImageViewRef];
    
    [transitionContext.containerView addSubview:transitionView];
    [transitionContext.containerView addSubview:toViewController.view];
    
    //Setup frame for Orientation and aspect ration
    CGRect frame;
    if (self.smallImageViewRef.image.size.width > self.smallImageViewRef.image.size.height) {
        frame = ASSET_FRAME_LANDSCAPE;
    }
    else
    {
        frame = ASSET_FRAME;
    }
    CGRect transitionViewFinalFrame = AVMakeRectWithAspectRatioInsideRect(self.smallImageViewRef.image.size, frame);
    
    // Perform the transition using a spring motion effect
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         transitionView.frame = transitionViewFinalFrame;
                         if (self.smallImageViewRef.image.size.width > self.smallImageViewRef.image.size.height) {
                             transitionView.transform = CGAffineTransformMakeRotation(M_PI_2);
                             transitionView.center = self.blurEffectView.center;
                         }
                     }
                     completion:^(BOOL finished) {
                         toViewController.view.alpha = 1;
                         [transitionView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)animateZoomOutTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get the view controllers participating in the transition
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    // Compute the initial frame for the temporary view based on the image view
    //CGRect transitionViewInitialFrame = AVMakeRectWithAspectRatioInsideRect(self.bigImageViewRef.image.size, APPLICATION_FRAME);
    CGRect transitionViewInitialFrame = [transitionContext.containerView convertRect:self.bigImageViewRef.bounds
                                                                     fromView:self.bigImageViewRef];
    
    if (self.bigImageViewRef.image.size.width > self.bigImageViewRef.image.size.height) {
        transitionViewInitialFrame = ASSET_FRAME_LANDSCAPE;
    }
    else
    {
        transitionViewInitialFrame = ASSET_FRAME;
    }
    
    // Compute the final frame for the temporary view based on the reference
    // image view
    CGRect transitionViewFinalFrame = [transitionContext.containerView convertRect:self.smallImageViewRef.bounds
                                                                          fromView:self.smallImageViewRef];
    
    if (UIApplication.sharedApplication.isStatusBarHidden && ![toViewController prefersStatusBarHidden]) {
        transitionViewFinalFrame = CGRectOffset(transitionViewFinalFrame, 0, 20);
    }
    
    // Create a temporary view for the zoom out transition based on the image
    // view controller contents
    UIImageView *transitionView = [[UIImageView alloc] initWithImage:self.bigImageViewRef.image];
    
    
    transitionView.contentMode = UIViewContentModeScaleAspectFill;
    transitionView.clipsToBounds = YES;
    transitionView.frame = transitionViewInitialFrame;
    if (self.bigImageViewRef.image.size.width > self.bigImageViewRef.image.size.height) {
        transitionView.transform = CGAffineTransformMakeRotation(M_PI_2);
        transitionView.center = self.blurEffectView.center;
    }

    
    [transitionContext.containerView addSubview:transitionView];
    //Revome the old view from the background
    [fromViewController.view removeFromSuperview];
    
    //remove the blurview
    [[toViewController.view viewWithTag:[BLUR_TAG hash]] removeFromSuperview];
    
    // Perform the transition
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                     animations:^{
                         transitionView.frame = transitionViewFinalFrame;
                         if (self.smallImageViewRef.image.size.width > self.smallImageViewRef.image.size.height) {
                             transitionView.transform = CGAffineTransformMakeRotation(0);
                         }
                     } completion:^(BOOL finished) {
                         [transitionView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                         
                     }];
}

@end
