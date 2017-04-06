//
//  ImageCollectionCell.h
//  TrueBite
//
//  Created by Brian Wong on 9/6/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageCollectionCellDelegate <NSObject>

- (void)didTapSeeAllButton;

@end

@interface ImageCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, weak) id<ImageCollectionCellDelegate>delegate;

//Used in the restaurant page mini album
- (void)showSeeAllButton;

@end
