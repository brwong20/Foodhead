//
//  TPLChartSectionView.h
//  FoodWise
//
//  Created by Brian Wong on 2/14/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChartSectionViewDelegate <NSObject>

- (void)didSelectSection:(NSUInteger)section;

@end

@interface TPLChartSectionView : UIView

@property (nonatomic, assign) NSUInteger section;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) id<ChartSectionViewDelegate> delegate;

@end
