//
//  AlbumCellNode.m
//  Foodhead
//
//  Created by Brian Wong on 5/9/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "AlbumCellNode.h"

@interface AlbumCellNode () <ASNetworkImageNodeDelegate>

@end

@implementation AlbumCellNode

- (instancetype)initWithPhotoURL:(NSURL *)url{
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _imageNode = [[ASNetworkImageNode alloc]init];
        _imageNode.backgroundColor = [UIColor whiteColor];
        _imageNode.placeholderFadeDuration = 0.15;
        _imageNode.contentMode = UIViewContentModeScaleAspectFill;
        _imageNode.delegate = self;
        _imageNode.URL = url;
        
    }
    return self;
}

- (ASStackLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize{    
    ASStackLayoutSpec *stackLayout = [ASStackLayoutSpec verticalStackLayoutSpec];
    
    CGFloat ratio = constrainedSize.max.height / constrainedSize.max.width;
    ASRatioLayoutSpec *ratioSpec = [ASRatioLayoutSpec ratioLayoutSpecWithRatio:ratio child:_imageNode];
    ratioSpec.alignSelf = ASStackLayoutAlignSelfCenter;
    stackLayout.children = @[ratioSpec];
    
    return stackLayout;
}

@end
