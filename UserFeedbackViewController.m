//
//  UserFeedbackView.m
//  Foodhead
//
//  Created by Brian Wong on 3/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UserFeedbackView.h"
#import "UIFont+Extension.h"

#import <AFNetworking/AFNetworking.h>

@interface UserFeedbackView ()

@property (nonatomic, strong) UIView *promptContainer;
@property (nonatomic, strong) UILabel *promptTitle;
@property (nonatomic, strong) UILabel *promptLabel;

@property (nonatomic, strong) UIImageView *owlImage;
@property (nonatomic, strong) UITextView *feedbackView;
@property (nonatomic, strong) UIButton *submitButton;

@end

@implementation UserFeedbackView

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.owlImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.1, self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.2, self.view.frame.size.width * 0.2)];
    self.owlImage.backgroundColor = [UIColor clearColor];
    [self.owlImage setImage:[UIImage imageNamed:@"owl_full"]];
    [self.view addSubview:self.owlImage];
    
    self.promptContainer = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.425, CGRectGetMidY(self.owlImage.frame), self.view.frame.size.width * 0.85, self.view.frame.size.height * 0.3)];
    self.promptContainer.backgroundColor = [UIColor whiteColor];
    self.promptContainer.layer.cornerRadius = self.promptContainer.frame.size.height * 0.8;
    self.promptContainer.layer.borderWidth = 5.0;
    self.promptContainer.layer.borderColor = [UIColor grayColor].CGColor;
    [self.view addSubview:self.promptContainer];
    
    self.promptTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.promptContainer.frame.size.width/2 - self.promptContainer.frame.size.width * 0.4, self.promptContainer.frame.size.height * 0.2 - self.promptContainer.frame.size.height * 0.15, self.promptContainer.frame.size.width * 0.8, self.promptContainer.frame.size.height * 0.3)];
    self.promptTitle.backgroundColor = [UIColor clearColor];
    self.promptTitle.textAlignment = NSTextAlignmentCenter;
    self.promptTitle.font = [UIFont nun_boldFontWithSize:20.0];
    self.promptTitle.text = @"Have ideas?";
    [self.promptContainer addSubview:self.promptTitle];
    
    self.promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.promptContainer.frame.size.width/2 - self.promptContainer.frame.size.width * 0.4, CGRectGetMaxY(self.promptTitle.frame), self.promptContainer.frame.size.width * 0.8, self.promptContainer.frame.size.height * 0.6)];
    self.promptLabel.backgroundColor = [UIColor clearColor];
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    self.promptLabel.font = [UIFont nun_fontWithSize:16.0];
    self.promptLabel.text = @"Share your feedback or report any issues. We're always listening!";
    [self.promptContainer addSubview:self.promptLabel];
    
}

- (void)setupUI{
    
}


//Eventually needs to be modularized into a different class
- (void)submitFeedback{
    
    
    
    
    
}

@end
