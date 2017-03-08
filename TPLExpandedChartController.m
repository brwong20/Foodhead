//
//  TPLExpandedChartController.m
//  FoodWise
//
//  Created by Brian Wong on 2/14/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLExpandedChartController.h"
#import "ExpandedChartTableViewCell.h"
#import "TPLRestaurant.h"
#import "FoodWiseDefines.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface TPLExpandedChartController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation TPLExpandedChartController

static NSString *cellId = @"categoryRowCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *categoryName = [[self.chartInfo allKeys]firstObject];
    self.title = categoryName;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[ExpandedChartTableViewCell class] forCellReuseIdentifier:cellId];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ExpandedChartTableViewCell *cell = (ExpandedChartTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    NSArray *restaurantArr = [self.chartInfo.allValues firstObject];
    TPLRestaurant *restaurant = [restaurantArr objectAtIndex:indexPath.row];
    
    cell.restaurantName.text = restaurant.name;
    //cell.thumbImageView sd_setImageWithURL:
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *restaurantArr = [[self.chartInfo allValues]firstObject];
    return restaurantArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CATEGORY_RESTAURANT_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

@end
