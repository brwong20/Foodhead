//
//  BRWSearchView.m
//  FoodWise
//
//  Created by Brian Wong on 2/15/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "BRWSearchView.h"

#warning USE RAC!!! :)
#import <ReactiveObjC/ReactiveObjC.h>

@interface BRWSearchView () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UITableView *resultsView;
@property (nonatomic, strong) NSMutableArray *searchResults;


@end

@implementation BRWSearchView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI:frame];
        self.searchResults = [NSMutableArray array];
    }
    return self;
}

- (void)setupUI:(CGRect)frame{
    self.backgroundColor = [UIColor greenColor];
    self.layer.cornerRadius = 6.0;
    self.clipsToBounds = YES;
    
    self.searchField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.searchField.placeholder = @"Find restaurant";
    self.searchField.delegate = self;
    self.searchField.font = [UIFont systemFontOfSize:20.0];
    self.searchField.backgroundColor = [UIColor whiteColor];
    self.searchField.textColor = [UIColor darkGrayColor];
    self.searchField.layer.borderWidth = 1.5;
    self.searchField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.searchField addTarget:self action:@selector(userDidType:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.searchField];
    
    self.resultsView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchField.frame), frame.size.width, 0.0)];
    self.resultsView.delegate = self;
    self.resultsView.dataSource = self;
    self.resultsView.backgroundColor = [UIColor whiteColor];
    self.resultsView.rowHeight = self.resultCellHeight;
    [self.resultsView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self addSubview:self.resultsView];
    
}

#pragma mark UITextFieldDelegate methods


#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Search result #%ld", (long)indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResults.count;
}

#pragma mark - Helper methods

//Expand all the way when user is typing/loading

- (void)changeResultsHeight{
    CGFloat tableHeight = self.resultCellHeight;
    if(self.searchResults.count <= 6){//TODO: This condition should be its own check based on phone screen height (always put it above the keyboard) and just let user scroll instead.
        tableHeight *= self.searchResults.count;
    }else{
        tableHeight *= 6;
    }
    
    //Add extra height to search field's height since it's the same as our default frame height.
    CGFloat frameHeight = self.searchField.frame.size.height + tableHeight;
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:4.0 initialSpringVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect tableFrame = self.resultsView.frame;
        CGRect frame = self.frame;
        frame.size.height = frameHeight;
        tableFrame.size.height = tableHeight;
        self.frame = frame;
        self.resultsView.frame = tableFrame;
    } completion:nil];
}

- (void)userDidType:(UITextField *)textField{
    if (textField.text.length > 0) {
        for (int i = 0; i < 6; ++i) {
            [self.searchResults addObject:@"dummy"];
        }
    }else{
        [self.searchResults removeAllObjects];
        
        
    }
    [self.resultsView reloadData];
    [self changeResultsHeight];
}

//- (void)addObservers{
//    
//}
//
//- (void)removeObservers{
//    
//}
@end
