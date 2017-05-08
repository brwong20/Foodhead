//
//  VideoNode.h
//  Foodhead
//
//  Created by Brian Wong on 4/28/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface VideoNode : ASCellNode

- (instancetype)initWithVideoURL:(NSURL *)url;

@end
