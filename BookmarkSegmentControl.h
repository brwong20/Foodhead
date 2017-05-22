//
//  BookmarkSegmentControl.h
//  Foodhead
//
//  Created by Brian Wong on 5/18/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookmarkSegmentControlDelegate <NSObject>

- (void)didSelectSegment:(NSUInteger)segment;

@end

@interface BookmarkSegmentControl : UIView

@property (nonatomic, weak) id<BookmarkSegmentControlDelegate> delegate;

@end
