//
//  VideoNode.m
//  Foodhead
//
//  Created by Brian Wong on 4/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "VideoNode.h"

@interface VideoNode ()

@end

@implementation VideoNode

- (instancetype)initWithVideoURL:(NSURL *)url{
    self = [super init];
    if (self) {
        AVAsset *asset = [AVAsset assetWithURL:url];
        self.asset = asset;
        self.shouldAutoplay = YES;
        self.shouldAutorepeat = NO;
        self.muted = YES;
    }
    return self;
}

@end
