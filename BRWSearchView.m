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
#import "NSString+IsEmpty.h"
#import "LayoutBounds.h"

@interface BRWSearchView () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) TPLRestaurantManager *restaurantManager;

@property (nonatomic, strong) UITextField *searchField;

@property (nonatomic, strong) UITableView *resultsView;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, assign) CGFloat maxResultHeight;

@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIView *errorSepLine;

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
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = frame.size.height * 0.12;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.alpha = 0.9;
    self.clipsToBounds = YES;
    
    self.searchField = [[UITextField alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.width * 0.475, 0, frame.size.width * 0.95, frame.size.height * 0.95)];
    self.searchField.placeholder = @"Find Restaurant";
    self.searchField.delegate = self;
    self.searchField.backgroundColor = [UIColor clearColor];
    self.searchField.font = [UIFont nun_lightFontWithSize:18.0];
    self.searchField.textColor = UIColorFromRGB(0x7A7A7B);
    self.searchField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    self.searchField.tintColor = [UIColor blackColor];
    [self.searchField addTarget:self action:@selector(userDidType:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.searchField];
    
    self.resultsView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchField.frame), frame.size.width, 0.0)];
    self.resultsView.delegate = self;
    self.resultsView.dataSource = self;
    self.resultsView.backgroundColor = [UIColor clearColor];
    self.resultsView.rowHeight = SEARCH_CELL_HEIGHT;
    [self.resultsView registerClass:[SuggestionTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self addSubview:self.resultsView];
    
    [self addObservers];
}

- (void)dealloc{
    [self removeObservers];
}

- (void)addObservers{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *result = self.searchResults[indexPath.row];
    TPLRestaurant *selectedRestaurant = [MTLJSONAdapter modelOfClass:[TPLRestaurant class] fromJSONDictionary:result error:nil];
    [self selectedResult:selectedRestaurant];
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
    
    if((tableHeight * self.searchResults.count) <= self.maxResultHeight){
        tableHeight *= self.searchResults.count;
    }else{
        tableHeight = self.maxResultHeight;
    }

    //Add extra height to search field's height since it's the same as our default frame height.
    CGFloat frameHeight = self.searchField.frame.size.height + tableHeight;
    
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:4.0 initialSpringVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect tableFrame = self.resultsView.frame;
        CGRect frame = self.frame;
        frame.size.height = frameHeight;
        tableFrame.size.height = tableHeight;
        self.frame = frame;
        self.resultsView.frame = tableFrame;
    } completion:nil];
}

//Close results no matter what when user selects a restaurant
- (void)closeResults{
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:4.0 initialSpringVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect tableFrame = self.resultsView.frame;
        CGRect frame = self.frame;
        frame.size.height = self.searchField.frame.size.height;
        tableFrame.size.height = 0.0;
        self.frame = frame;
        self.resultsView.frame = tableFrame;
    } completion:nil];
}

- (void)userDidType:(UITextField *)textField{
    //Shouldn't query if user has selected a restaurant or  didn't input anything
    if (![NSString isEmpty:textField.text]) {
        [self.restaurantManager searchRestaurantsWithQuery:textField.text atLocation:self.currentReview.reviewLocation completionHandler:^(id suggestions) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.errorView superview]) {
                    [self removeErrorView];
                }
                [self.searchResults removeAllObjects];
                self.searchResults = [[self.searchResults arrayByAddingObjectsFromArray:suggestions]mutableCopy];
                
                //Must check here for empty text since this is an asynchronous request (data could return even after user deletes all text)
                if (![NSString isEmpty:textField.text]) {
                    [self.resultsView reloadData];
                    [self changeResultsHeight];
                }
            });
        } failureHandler:^(id error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self.errorView superview]) {
                    [self showErrorView];
                }
            });
        }];
    }
    else if([NSString isEmpty:textField.text]){
        if ([self.errorView superview]) {
            [self removeErrorView];
        }
        [self.searchResults removeAllObjects];
        [self changeResultsHeight];
    }
}

- (void)showErrorView{
    self.errorView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchField.frame) - SEARCH_CELL_HEIGHT * 0.4, self.frame.size.width, SEARCH_CELL_HEIGHT * 0.4)];
    self.errorView.backgroundColor = [UIColor clearColor];
    [self insertSubview:self.errorView belowSubview:self.searchField];
    
    self.errorSepLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.searchField.frame.size.width, 1.0)];
    self.errorSepLine.center = CGPointMake(self.errorView.frame.size.width/2, 0.0);
    self.errorSepLine.backgroundColor = [UIColor grayColor];
    self.errorSepLine.alpha = 0.3;
    [self.errorView addSubview:self.errorSepLine];
    
    self.errorLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.errorSepLine.frame) + 1.0, self.errorView.frame.size.height/2 - self.errorView.frame.size.height * 0.4, self.errorView.frame.size.width * 0.9, self.errorView.frame.size.height * 0.8)];
    self.errorLabel.backgroundColor = [UIColor clearColor];
    self.errorLabel.font = [UIFont nun_fontWithSize:self.errorLabel.frame.size.height * 0.6];
    self.errorLabel.textColor = [UIColor lightGrayColor];
    [self.errorLabel setText:@"Could not get results - please check your connection!"];
    [self.errorView addSubview:self.errorLabel];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        CGRect errorFrame = self.errorView.frame;
        
        frame.size.height += self.errorView.frame.size.height;
        errorFrame.origin.y += self.errorView.frame.size.height;
        
        self.frame = frame;
        self.errorView.frame = errorFrame;
    }];
}

- (void)removeErrorView{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        CGRect errorFrame = self.errorView.frame;
        
        frame.size.height -= self.errorView.frame.size.height;
        errorFrame.origin.y -= self.errorView.frame.size.height;
        
        self.frame = frame;
        self.errorView.frame = errorFrame;
    }completion:^(BOOL finished) {
        [self.errorView removeFromSuperview];
    }];
}

- (void)selectedResult:(TPLRestaurant *)restaurant{
    self.searchField.text = restaurant.name;
    self.searchField.textColor = [UIColor blackColor];
    [self closeResults];
    [self.delegate didSelectResult:restaurant];
}

- (void)showKeyboard{
    [self.searchField becomeFirstResponder];
}

- (void)dismissKeyboard{
    [self.searchField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notif{
    CGRect padFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    //Get the space between keyboard and search box so each result is always visible to the user
    self.maxResultHeight = (CGRectGetMinY(padFrame) - CGRectGetMaxY(self.searchField.frame)) * 0.67;
}

@end
