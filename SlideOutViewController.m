//
//  SlideOutViewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/16/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "SlideOutViewController.h"
#import "UserProfileView.h"
#import "SidePanelSearchView.h"
#import "UserProfileViewController.h"

#import "FoodWiseDefines.h"

@interface SlideOutViewController ()

@property (nonatomic, strong) UserProfileView *profileView;
@property (nonatomic, strong) SidePanelSearchView *searchView;

@end

@implementation SlideOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //[self setNeedsStatusBarAppearanceUpdate];
}
- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //Need to offset all views by same width we're cutting off from the rear view (SLIDED_PANEL_WIDTH)
    self.profileView = [[UserProfileView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width - SLIDED_PANEL_WIDTH, self.view.frame.size.height * 0.3)];
    [self.view addSubview:self.profileView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProfile)];
    [self.profileView addGestureRecognizer:tap];
    
    self.searchView = [[SidePanelSearchView alloc]initWithFrame:CGRectMake(0.0, CGRectGetMaxY(self.profileView.frame), self.view.frame.size.width - SLIDED_PANEL_WIDTH, self.view.frame.size.height * 0.7)];
    [self.view addSubview:self.searchView];
}

- (void)showProfile{
    UserProfileViewController *profileVC = [[UserProfileViewController alloc]init];
    [self presentViewController:profileVC animated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
