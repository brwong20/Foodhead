//
//  BRWSearchView.m
//  FoodWise
//
//  Created by Brian Wong on 2/15/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "BRWSearchView.h"

#import "TPLRestaurant.h"
#import "TPLRestaurantManager.h"
#import "FoodWiseDefines.h"
#import "SuggestionTableViewCell.h"
#import "UIFont+Extension.h"

@interface BRWSearchView () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) TPLRestaurantManager *restaurantManager;

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
        self.restaurantManager = [[TPLRestaurantManager alloc]init];
    }
    return self;
}

- (void)setupUI:(CGRect)frame{
    self.layer.cornerRadius = frame.size.height * 0.12;
    self.clipsToBounds = YES;
    
    self.searchField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.searchField.placeholder = @"Find restaurant";
    self.searchField.delegate = self;
    self.searchField.backgroundColor = [UIColor whiteColor];
    self.searchField.alpha = 0.9;
    self.searchField.font = [UIFont nun_lightFontWithSize:18.0];
    self.searchField.textColor = UIColorFromRGB(0x7A7A7B);
    [self.searchField addTarget:self action:@selector(userDidType:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.searchField];
    
    self.resultsView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchField.frame), frame.size.width, 0.0)];
    self.resultsView.delegate = self;
    self.resultsView.dataSource = self;
    self.resultsView.backgroundColor = [UIColor whiteColor];
    self.resultsView.rowHeight = SEARCH_CELL_HEIGHT;
    [self.resultsView registerClass:[SuggestionTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self addSubview:self.resultsView];
    
}

#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SuggestionTableViewCell *cell = (SuggestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSDictionary *result = self.searchResults[indexPath.row];
    TPLRestaurant *restaurant = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:result error:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell populateRestaurantInfo:restaurant];
    
    return cell;
}


#pragma mark UITableViewDelegate methods

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 70.0;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *result = self.searchResults[indexPath.row];
    TPLRestaurant *selectedRestaurant = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:result error:nil];
    [self.delegate didSelectResult:selectedRestaurant];
    
    //Animate/show something here to show selection
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResults.count;
}

#pragma mark - Helper methods

#warning Expand all the way when user is typing/loading and show spinner

- (void)changeResultsHeight{
    CGFloat tableHeight = SEARCH_CELL_HEIGHT;
    if(self.searchResults.count <= MAX_RESULT_COUNT){//TODO: This condition should be its own check based on phone screen height (always put it above the keyboard) and just let user scroll instead.
        tableHeight *= self.searchResults.count;
    }else{
        tableHeight *= MAX_RESULT_COUNT;
    }
    
    //Add extra height to search field's height since it's the same as our default frame height.
    CGFloat frameHeight = self.searchField.frame.size.height + tableHeight;
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:4.0 initialSpringVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
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
        [self.restaurantManager searchRestaurantsWithQuery:textField.text atLocation:self.currentReview.reviewLocation completionHandler:^(id suggestions) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchResults removeAllObjects];
                self.searchResults = [[self.searchResults arrayByAddingObjectsFromArray:suggestions]mutableCopy];
                [self.resultsView reloadData];
                [self changeResultsHeight];
            });
        } failureHandler:^(id error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Error searching for restaurants");
                [self.searchResults removeAllObjects];
                [self changeResultsHeight];
            });
        }];
    }else{
        [self.searchResults removeAllObjects];
        [self changeResultsHeight];
    }
}

- (void)dismissKeyboard{
    [self.searchField resignFirstResponder];
}

//- (void)addObservers{
//    
//}
//
//- (void)removeObservers{
//    
//}
@end
