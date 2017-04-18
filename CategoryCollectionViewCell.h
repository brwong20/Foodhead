//
//  CategoryCollectionViewCell.h
//  Foodhead
//
//  Created by Brian Wong on 4/8/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Category.h"

@interface CategoryCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) UILabel *categoryName;
@property (nonatomic, strong) UIImageView *categoryImgView;


- (void)showCategory:(NSString *)category;

@end
