//
//  SidePanelSearchView.m
//  FoodWise
//
//  Created by Brian Wong on 2/17/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "SidePanelSearchView.h"

@interface SidePanelSearchView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UITableView *categoryTable;

@end

static NSString *cellId = @"searchCell";

@implementation SidePanelSearchView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI:frame];
    }
    return self;
}

- (void)setupUI:(CGRect)frame{
    self.backgroundColor = [UIColor whiteColor];
    
    self.searchField = [[UITextField alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.45, 0.0, frame.size.width * 0.9, frame.size.height * 0.11)];
    self.searchField.placeholder = @"What are you looking for?";
    self.searchField.layer.cornerRadius = self.searchField.frame.size.height * 0.5;
    self.searchField.backgroundColor = [UIColor lightGrayColor];
    [self.searchField setFont:[UIFont systemFontOfSize:frame.size.height * 0.035]];
    [self addSubview:self.searchField];
    
    self.categoryTable = [[UITableView alloc]initWithFrame:CGRectMake(frame.size.width * 0.3 - frame.size.width * 0.25, CGRectGetMaxY(self.searchField.frame) + 5.0, frame.size.width * 0.5, frame.size.height * 0.84)];
    self.categoryTable.delegate = self;
    self.categoryTable.dataSource = self;
    self.categoryTable.rowHeight = 50.0;
    [self.categoryTable registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    [self addSubview:self.categoryTable];
}

#pragma mark - Helper Methods

#pragma mark - UITableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.text = @"Category";
    return cell;
}


#pragma mark - UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8.0;
}


@end
