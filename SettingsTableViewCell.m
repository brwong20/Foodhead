//
//  SettingsTableViewCell.m
//  Foodhead
//
//  Created by Brian Wong on 3/22/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "SettingsTableViewCell.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"

@interface SettingsTableViewCell ()

@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong) UIView *sepLine;

@end

@implementation SettingsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.sepLine = [[UIView alloc]initWithFrame:SEP_LINE_RECT];
        self.sepLine.backgroundColor = UIColorFromRGB(0x47606A);
        self.sepLine.alpha = 0.15;
        [self.contentView addSubview:self.sepLine];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.sepLine.frame), SETTINGS_CELL_HEIGHT * 0.4 - SETTINGS_CELL_HEIGHT * 0.3, APPLICATION_FRAME.size.width * 0.6, SETTINGS_CELL_HEIGHT * 0.6)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont nun_fontWithSize:16.0];
        [self.contentView addSubview:self.titleLabel];
        
        self.arrow = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.sepLine.frame) - SETTINGS_CELL_HEIGHT * 0.2, CGRectGetMidY(self.titleLabel.frame) - SETTINGS_CELL_HEIGHT * 0.05, SETTINGS_CELL_HEIGHT * 0.1, SETTINGS_CELL_HEIGHT * 0.1)];
        self.arrow.backgroundColor = [UIColor clearColor];
        [self.arrow setImage:[UIImage imageNamed:@"arrow_right"]];
        [self.contentView addSubview:self.arrow];
    }
    return self;
}

@end
