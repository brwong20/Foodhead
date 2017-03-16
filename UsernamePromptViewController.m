//
//  UsernamePromptViewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/15/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UsernamePromptViewController.h"

@interface UsernamePromptViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *usernamePrompt;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation UsernamePromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.usernamePrompt = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.height * 0.2 - self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.15 - self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.5 , self.view.frame.size.height * 0.2)];
    self.usernamePrompt.text = @"Enter username";
    self.usernamePrompt.font = [UIFont systemFontOfSize:28.0];
    self.usernamePrompt.textColor = [UIColor lightGrayColor];
    self.usernamePrompt.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.usernamePrompt];
    
    self.usernameField  = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.usernamePrompt.frame), CGRectGetMaxY(self.usernamePrompt.frame), self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.1)];
    self.usernameField.placeholder = @"Username";
    self.usernameField.layer.cornerRadius = 14.0;
    self.usernameField.font = [UIFont systemFontOfSize:28.0];
    self.usernameField.delegate = self;
    self.usernameField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.usernameField];
    
    self.doneButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.usernameField.frame), self.view.frame.size.height * 0.7 - self.view.frame.size.width * 0.05, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.1)];
    self.doneButton.backgroundColor = [UIColor grayColor];
    self.doneButton.layer.cornerRadius = 14.0;
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(submitUsername) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneButton];
}

- (void)submitUsername{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //Enable/disable done based on input - USE RAC?!?@#?!@#?
    
    return YES;
}



@end
