//
//  RestaurantPageControlView.h
//  Foodhead
//
//  Created by Brian Wong on 5/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RestaurantPageControlViewDelegate <NSObject>

- (void)userCLickedCallButton;
- (void)userClickedShareButton;
- (void)userClickedFavoriteButton;

@end

@interface RestaurantPageControlView : UIView

@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *priceTitle;;

@property (nonatomic, strong) UIButton *callButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *favoriteButton;

@property (nonatomic, weak)id <RestaurantPageControlViewDelegate> delegate;

- (void)setTextForPrice:(NSNumber *)price;
- (void)toggleFavoriteButton:(BOOL)favorite;

@end
