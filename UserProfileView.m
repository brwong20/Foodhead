//
//  UserProfileView.m
//  FoodWise
//
//  Created by Brian Wong on 2/17/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UserProfileView.h"

@interface UserProfileView()

@property (nonatomic, strong) UIImageView *profilePic;
@property (nonatomic, strong) UIButton *settingsButton;

@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *rankLabel;

@end

@implementation UserProfileView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI:frame];
    }
    return self;
}

- (void)setupUI:(CGRect)frame{
    self.backgroundColor = [UIColor whiteColor];
    
    self.profilePic = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.125, frame.size.height * 0.3 - frame.size.width * 0.125, frame.size.width * 0.25, frame.size.width * 0.25)];
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.height/2;
    self.profilePic.contentMode = UIViewContentModeScaleAspectFit;
    self.profilePic.backgroundColor = [UIColor whiteColor];
    self.profilePic.clipsToBounds = YES;
    [self.profilePic setImage:[UIImage imageNamed:@"fukboi"]];
    [self addSubview:self.profilePic];
    
    self.settingsButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.08 - frame.size.width * 0.05, 10.0, frame.size.width * 0.1, frame.size.width * 0.1)];
    self.settingsButton.backgroundColor = [UIColor grayColor];
    [self.settingsButton setTitle:@"S" forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(didClickSettings) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.settingsButton];
    
    self.usernameLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.25, CGRectGetMaxY(self.profilePic.frame) + frame.size.height * 0.1, frame.size.width * 0.5, frame.size.height * 0.2)];
    self.usernameLabel.textAlignment = NSTextAlignmentCenter;
    self.usernameLabel.backgroundColor = [UIColor clearColor];
    [self.usernameLabel setText:@"Fuk u fucker"];
    [self.usernameLabel setFont:[UIFont systemFontOfSize:24.0]];
    [self addSubview:self.usernameLabel];
}

- (void)didClickSettings{
    
}

@end
