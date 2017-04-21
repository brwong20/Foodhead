//
//  UserFeedbackViewController.m
//  Foodhead
//
//  Created by Brian Wong on 3/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UserFeedbackViewController.h"
#import "UIFont+Extension.h"
#import "FoodWiseDefines.h"
#import "LayoutBounds.h"

#import <SAMKeychain/SAMKeychain.h>
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface UserFeedbackViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *promptContainer;
@property (nonatomic, strong) UILabel *promptTitle;
@property (nonatomic, strong) UILabel *promptLabel;

@property (nonatomic, strong) UIImageView *owlImage;
@property (nonatomic, strong) UITextView *feedbackView;
@property (nonatomic, strong) UIButton *submitButton;

@end

@implementation UserFeedbackViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"arrow_back"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exitFeedback)];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;//Preserves swipe back gesture
    
    self.owlImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.1, self.view.frame.size.height * 0.13, self.view.frame.size.width * 0.2, self.view.frame.size.width * 0.2)];
    self.owlImage.backgroundColor = [UIColor clearColor];
    [self.owlImage setImage:[UIImage imageNamed:@"owl_full"]];
    [self.view addSubview:self.owlImage];
    
    self.promptContainer = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.4, CGRectGetMidY(self.owlImage.frame) - self.owlImage.frame.size.height * 0.03, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.2)];
    self.promptContainer.backgroundColor = [UIColor whiteColor];
    self.promptContainer.layer.cornerRadius = self.promptContainer.frame.size.height * 0.1;
    self.promptContainer.layer.borderWidth = 2.0;
    self.promptContainer.layer.borderColor = UIColorFromRGB(0x49606A).CGColor;
    [self.view addSubview:self.promptContainer];
    
    self.promptTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.promptContainer.frame.size.width/2 - self.promptContainer.frame.size.width * 0.4, self.promptContainer.frame.size.height * 0.2 - self.promptContainer.frame.size.height * 0.15, self.promptContainer.frame.size.width * 0.8, self.promptContainer.frame.size.height * 0.3)];
    self.promptTitle.backgroundColor = [UIColor clearColor];
    self.promptTitle.textAlignment = NSTextAlignmentCenter;
    self.promptTitle.font = [UIFont nun_boldFontWithSize:self.view.frame.size.height * 0.03];
    self.promptTitle.text = @"Have ideas?";
    self.promptTitle.textColor = UIColorFromRGB(0x48606A);
    [self.promptContainer addSubview:self.promptTitle];
    
    self.promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.promptContainer.frame.size.width/2 - self.promptContainer.frame.size.width * 0.45, CGRectGetMaxY(self.promptTitle.frame), self.promptContainer.frame.size.width * 0.9, self.promptContainer.frame.size.height * 0.5)];
    self.promptLabel.backgroundColor = [UIColor clearColor];
    self.promptLabel.numberOfLines = 2;
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    self.promptLabel.font = [UIFont nun_fontWithSize:self.view.frame.size.height * 0.025];
    self.promptLabel.text = @"Share your feedback or report any issues. We're always listening!";
    [self.promptContainer addSubview:self.promptLabel];
    
    self.feedbackView = [[UITextView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.4, CGRectGetMaxY(self.promptContainer.frame) + self.view.frame.size.height * 0.02, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.3)];
    self.feedbackView.backgroundColor = [UIColor whiteColor];
    self.feedbackView.layer.cornerRadius = self.feedbackView.frame.size.height * 0.07;
    self.feedbackView.layer.borderWidth = 2.0;
    self.feedbackView.layer.borderColor = UIColorFromRGB(0x49606A).CGColor;
    self.feedbackView.font = [UIFont nun_fontWithSize:self.view.frame.size.height * 0.025];
    self.feedbackView.contentInset = UIEdgeInsetsMake(3.0, 5.0, -3.0, -5.0);
    self.feedbackView.delegate = self;
    [self.view addSubview:self.feedbackView];
    
    self.submitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.2, CGRectGetMaxY(self.feedbackView.frame) + self.view.frame.size.height * 0.04, self.view.frame.size.width * 0.4, self.view.frame.size.height * 0.06)];
    self.submitButton.backgroundColor = UIColorFromRGB(0xC684D5);
    self.submitButton.layer.cornerRadius = self.submitButton.frame.size.height * 0.3;
    self.submitButton.layer.borderColor = UIColorFromRGB(0x49606A).CGColor;
    self.submitButton.layer.borderWidth = 1.5;
    self.submitButton.titleLabel.font = [UIFont nun_boldFontWithSize:self.submitButton.frame.size.height * 0.4];
    self.submitButton.enabled = NO;
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(submitFeedback) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
    
    UITapGestureRecognizer *dismissKeyboard = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    dismissKeyboard.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismissKeyboard];    
}

- (void)exitFeedback{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissKeyboard{
    if ([self.feedbackView isFirstResponder]) {
        [self.feedbackView resignFirstResponder];
    }
}

//Eventually needs to be modularized into a different class
- (void)submitFeedback{
    self.submitButton.enabled = NO;
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc]init];
    NSDictionary *params = @{@"message" : self.feedbackView.text};
    NSString *authToken = [SAMKeychain passwordForService:YUM_SERVICE account:KEYCHAIN_ACCOUNT];
    if (authToken) {
        [sessionManager.requestSerializer setValue:authToken forHTTPHeaderField:@"AUTHTOKEN"];
    }
    
    [SVProgressHUD setContainerView:self.view];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:APPLICATION_BLUE_COLOR];
    [SVProgressHUD setFont:[UIFont nun_fontWithSize:20.0]];
    [SVProgressHUD setMinimumSize:CGSizeMake(self.view.frame.size.width * 0.4, self.view.frame.size.height * 0.2)];
    [SVProgressHUD showWithStatus:@"Submitting feedback"];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    [sessionManager POST:API_FEEDBACK parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.submitButton.enabled = YES;
        [SVProgressHUD showSuccessWithStatus:@"Thanks for the feedback!"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.submitButton.enabled = YES;
        [SVProgressHUD showErrorWithStatus:@"Failed to submit feedback. Please try again!"];
    }];
}

#pragma mark - UITextView Delegate methods

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length > 0) {
        self.submitButton.enabled = YES;
    }else{
        self.submitButton.enabled = NO;
    }
}

@end
