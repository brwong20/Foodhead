//
//  AlbumCellNode.h
//  Foodhead
//
//  Created by Brian Wong on 5/9/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface AlbumCellNode : ASCellNode

- (instancetype)initWithPhotoURL:(NSURL *)url;

@property (nonatomic, strong) ASNetworkImageNode *imageNode;

@end
