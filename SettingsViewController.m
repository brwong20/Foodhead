//
//  SettingsViewController.m
//  Foodhead
//
//  Created by Brian Wong on 3/22/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"
#import "WebViewController.h"
#import "FoodWiseDefines.h"
#import "UserFeedbackViewController.h"

#import "UIFont+Extension.h"


@interface SettingsViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;


@end

static NSString *cellId = @"settingCell";

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = SETTINGS_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    [self.tableView registerClass:[SettingsTableViewCell class] forCellReuseIdentifier:cellId];
    [self.view addSubview:self.tableView];
}

- (void)setupNavBar{
    [self.navigationItem setTitle:@"Settings"];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont nun_boldFontWithSize:20.0]};
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"arrow_back"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exitSettings)];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;//Preserves swipe back gesture
}

- (void)exitSettings{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SettingsTableViewCell *cell = (SettingsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"Submit feedback";
    }else if (indexPath.row == 1){
        cell.titleLabel.text = @"Privacy policy";
    }else if (indexPath.row == 2){
        cell.titleLabel.text = @"Terms of service";
    }
    return cell;
    
}

#pragma mark - UITableViewDelegate 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UserFeedbackViewController *feedbackVC = [[UserFeedbackViewController alloc]init];
        [self.navigationController pushViewController:feedbackVC animated:YES];
    }else if (indexPath.row == 1){
        WebViewController *webVC = [[WebViewController alloc]init];
        webVC.webLink = FOODHEAD_PRIVACY_URL;
        [self.navigationController pushViewController:webVC animated:YES];
    }else if (indexPath.row == 2){
        WebViewController *webVC = [[WebViewController alloc]init];
        webVC.webLink = FOODHEAD_TERMS_URL;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

@end
