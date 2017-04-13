//
//  SearchViewController.m
//  Foodhead
//
//  Created by Brian Wong on 4/6/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "SearchViewController.h"
#import "FoodWiseDefines.h"
#import "ExpandedChartTableViewCell.h"
#import "TPLRestaurantManager.h"
#import "SuggestionTableViewCell.h"
#import "SearchTableViewCell.h"
#import "NSString+IsEmpty.h"
#import "UIFont+Extension.h"
#import "TPLRestaurant.h"
#import "TPLRestaurantPageViewController.h"
#import "CategoryCollectionViewCell.h"
#import "LayoutBounds.h"
#import "ResultTableViewCell.h"
#import "NSString+IsEmpty.h"
#import "LocationManager.h"

#import "SearchFilterView.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, SearchFilterViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) TPLRestaurantManager *restManager;

@property (nonatomic, strong) UITableView *resultsTableView;
@property (nonatomic, strong) UICollectionView *categoryCollectionView;
@property (nonatomic, strong) NSArray *categoryTitles;
@property (nonatomic, strong) NSArray *categoryValues;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) NSMutableArray *searchResults;

//Search indicator
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) BOOL showCategories;//Show category suggestions
@property (nonatomic, assign) BOOL showSuggestions;//Show restaurant & category suggestions based on query. If false, shows actual results

//Filter View
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) SearchFilterView *filterView;

@end

static NSString *searchCellId = @"searchCell";
static NSString *categoryCellId = @"categoryCell";
static NSString *exploreCellId = @"exploreCell";

#define NUM_COLUMNS 3

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentLocation = [[LocationManager sharedLocationInstance]currentLocation];
    self.restManager = [[TPLRestaurantManager alloc]init];
    self.searchResults = [NSMutableArray array];
    
    self.categoryTitles = @[@"Coffee", @"Salad", @"Juice", @"Mexican", @"Breakfast", @"Asian", @"Sushi", @"Burgers", @"Noodle Soup", @"Drinks", @"Dessert", @"Fancy", @"Vegetarian" , @"Pizza", @"Steakhouse"];
    self.categoryValues = @[ @"Coffee Shop", @"Salad", @"Juice Bar", @"Mexican", @"Breakfast", @"Asian Restaurant", @"Sushi", @"Burgers", @"Noodle soup", @"Nightlife Spot", @"Dessert Shop", @"Fancy", @"Vegetarian / Vegan Restaurant", @"Pizza Place", @"Steakhouse"];
    
    self.showCategories = YES;
    self.showSuggestions = YES;
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.tintColor = APPLICATION_BLUE_COLOR;
    self.searchController.searchBar.placeholder = @"Search restaurants & food";
    [self.searchController.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setDefaultTextAttributes:@{NSFontAttributeName : [UIFont nun_fontWithSize:16.0]}];
    self.navigationItem.titleView = self.searchController.searchBar;
    
//    self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(navBarFrame.size.width/2 - navBarFrame.size.width * 0.35, navBarFrame.size.height/2 - navBarFrame.size.height * 0.35, navBarFrame.size.width * 0.7, navBarFrame.size.height * 0.7)];
//    self.searchField.backgroundColor = [UIColor whiteColor];
//    self.searchField.layer.cornerRadius = 5.0;
//    self.searchField.placeholder = @"Search Restaurants...";
//    self.searchField.clipsToBounds = YES;
//    self.searchField.font = [UIFont nun_fontWithSize:16.0];
//    self.searchField.delegate = self;
//    self.searchField.textColor = [UIColor blackColor];
//    self.searchField.clearButtonMode = UITextFieldViewModeAlways;
//    self.searchField.keyboardType = UIKeyboardTypeDefault;
//    self.searchField.returnKeyType = UIReturnKeySearch;
//    [self.searchField addTarget:self action:@selector(textViewDidType) forControlEvents:UIControlEventEditingChanged];
//    [self.navigationController.navigationBar addSubview:self.searchField];
    
    //Adjust for tab bar height covering views
    UIEdgeInsets adjustForBarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame) + (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.frame.size.height), 0);
    
    self.resultsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.resultsTableView.delegate = self;
    self.resultsTableView.dataSource = self;
    self.resultsTableView.contentInset = adjustForBarInsets;
    self.resultsTableView.scrollIndicatorInsets = adjustForBarInsets;
    self.resultsTableView.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.resultsTableView.separatorStyle = UITableViewCellEditingStyleNone;
    self.resultsTableView.showsVerticalScrollIndicator = NO;
    self.resultsTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //self.resultsTableView.tableHeaderView = self.searchController.searchBar;
    [self.resultsTableView registerClass:[SearchTableViewCell class] forCellReuseIdentifier:searchCellId];
    [self.resultsTableView registerClass:[ResultTableViewCell class] forCellReuseIdentifier:exploreCellId];
    [self.view addSubview:self.resultsTableView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 1.0;
    flowLayout.minimumLineSpacing = 1.0;
    CGFloat itemWidth = (CGRectGetWidth(self.view.frame) - (NUM_COLUMNS - 1.0)) / NUM_COLUMNS;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.categoryCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:flowLayout];
    self.categoryCollectionView.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.categoryCollectionView.delegate = self;
    self.categoryCollectionView.dataSource = self;
    self.categoryCollectionView.contentInset = adjustForBarInsets;
    self.categoryCollectionView.scrollIndicatorInsets = adjustForBarInsets;
    self.categoryCollectionView.showsVerticalScrollIndicator = NO;
    [self.categoryCollectionView registerClass:[CategoryCollectionViewCell class] forCellWithReuseIdentifier:categoryCellId];
    [self.view addSubview:self.categoryCollectionView];
    
    self.filterView = [[SearchFilterView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.filterView.delegate = self;
    
    self.filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.filterButton setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [self.filterButton addTarget:self action:@selector(showFilterView) forControlEvents:UIControlEventTouchUpInside];
    self.filterButton.frame = CGRectOffset(self.filterButton.frame, -self.filterButton.frame.size.width, 0.0);
    self.filterButton.frame = CGRectMake(0.0, 0, 22.0, 22.0);
    self.filterButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -9.0, 0.0, 9.0);
    
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = CGPointMake(self.resultsTableView.center.x, self.resultsTableView.center.y - CGRectGetHeight(self.tabBarController.tabBar.frame));
    [self.resultsTableView addSubview:self.indicatorView];
    
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setupNavBar];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    if ([self.searchField isFirstResponder]) {
        [self.searchField resignFirstResponder];
    }
    [super viewWillDisappear:animated];
}

- (void)setupNavBar{
    self.navigationController.extendedLayoutIncludesOpaqueBars = YES;//Must set this or search bar goes off-screen when presented

    self.navigationController.navigationBar.translucent = NO;
}

- (void)resetNavBar{
    self.navigationController.navigationBar.translucent = YES;
}

- (void)showFilterBarButton{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.filterButton];
//    [UIView animateWithDuration:0.15 animations:^{
//        self.filterButton.frame = CGRectOffset(self.filterButton.frame, self.filterButton.frame.size.width, 0.0);
//    }];
//
}

- (void)hideFilterButton{
    self.navigationItem.leftBarButtonItem = nil;
//    [UIView animateWithDuration:0.2 animations:^{
//        self.filterButton.frame = CGRectOffset(self.filterButton.frame, -self.filterButton.frame.size.width * 1.5, 0.0);
//    }completion:^(BOOL finished) {
//        self.navigationItem.leftBarButtonItem = nil;
//    }];
}

- (void)dealloc{
    [self removeObservers];
}

- (void)exitSearch{
    [self resetNavBar];
    [self.searchField removeFromSuperview];//Is this the best way to embed?
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)showFilterView{
    if (![self.filterView superview]) {
        [self.view addSubview:self.filterView];
        //[self.view addSubview:self.filterView];
//        [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:10.0 initialSpringVelocity:10.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            CGRect filterFrame = self.filterView.frame;
//            filterFrame.origin.y += (self.view.bounds.size.height + (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.frame.size.height));
//            self.filterView.frame = filterFrame;
//        } completion:nil];
    }
//    else{
//        [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:10.0 initialSpringVelocity:10.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            CGRect filterFrame = self.filterView.frame;
//            filterFrame.origin.y -= (self.view.bounds.size.height + (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.frame.size.height));
//            self.filterView.frame = filterFrame;
//        } completion:^(BOOL finished) {
//            [self.filterView removeFromSuperview];
//        }];
//    }
}

- (void)addObservers{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.showSuggestions){
        //Have to check if category object or restaurant
        id suggestion = self.searchResults[indexPath.row];
        if ([suggestion isKindOfClass:[TPLRestaurant class]]) {
            //Must dismiss to avoid view controller UI glitch
            if ([self.searchController.searchBar isFirstResponder]) {
                [self.searchController.searchBar resignFirstResponder];
            }
            TPLRestaurant *restaurant = suggestion;
            TPLRestaurantPageViewController *restPageVC = [[TPLRestaurantPageViewController alloc]init];
            restPageVC.currentLocation = self.currentLocation;
            restPageVC.selectedRestaurant = restaurant;
            [self.navigationController pushViewController:restPageVC animated:YES];
        }else if([suggestion isKindOfClass:[Category class]]){
            //Search based on category
            Category *category = suggestion;
            self.searchController.searchBar.text = category.categoryShortName;
            [self searchBarSearchButtonClicked:self.searchController.searchBar];
        }
    }else{
        TPLRestaurant *restaurant = self.searchResults[indexPath.row];
        TPLRestaurantPageViewController *restPageVC = [[TPLRestaurantPageViewController alloc]init];
        restPageVC.currentLocation = self.currentLocation;
        restPageVC.selectedRestaurant = restaurant;
        [self.navigationController pushViewController:restPageVC animated:YES];
    }
}

#pragma mark - UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight;
    if (self.showSuggestions) {
        cellHeight = SEARCH_CONTROLLER_CELL_HEIGHT;
    }else{
        cellHeight = RESULT_CELL_HEIGHT;
    }
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResults.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
    //If user doesn't perform explore search
    if (self.showSuggestions) {
        //Check if search result or category
        SearchTableViewCell *searchCell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:searchCellId];
        id suggestion = self.searchResults[indexPath.row];
        if ([suggestion isKindOfClass:[TPLRestaurant class]]) {
            TPLRestaurant *restaurant = suggestion;
            [searchCell populateRestaurant:restaurant];
        }else if([suggestion isKindOfClass:[Category class]]){
            Category *category = suggestion;
            [searchCell populateCategory:category];
        }
        cell = searchCell;
    }else{
        TPLRestaurant *restaurant = self.searchResults[indexPath.row];
        ResultTableViewCell *resultCell = (ResultTableViewCell *)[tableView dequeueReusableCellWithIdentifier:exploreCellId];
        [resultCell populateRestaurant:restaurant];
        cell = resultCell;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.searchController.searchBar.text = self.categoryTitles[indexPath.row];
    self.showCategories = NO;
    [self toggleCategories];
    [self searchBarSearchButtonClicked:self.searchController.searchBar];
}

#pragma mark - UICollectionViewDataSource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CategoryCollectionViewCell *catCell = [collectionView dequeueReusableCellWithReuseIdentifier:categoryCellId forIndexPath:indexPath];
    NSString *catName = self.categoryTitles[indexPath.row];
    catCell.categoryName.text = catName;
    catCell.category = self.categoryValues[indexPath.row];
    [catCell.categoryImgView setImage:[UIImage imageNamed:catName]];
    return catCell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.categoryValues.count;
}

#pragma mark - UISearchControllerDelegate methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    //Must implement to use search controller
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (![NSString isEmpty:searchText]) {
        self.showCategories = NO;
        self.showSuggestions = YES;
        [self toggleCategories];
        [self.restManager fullRestaurantSearchWithQuery:searchText atLocation:self.currentLocation
                                      completionHandler:^(id suggestions) {
            [self.searchResults removeAllObjects];
            [self.searchResults addObjectsFromArray:suggestions];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.resultsTableView reloadData];
            });
        } failureHandler:^(id error) {
            //No connection
        }];
    }else{
        self.showCategories = YES;
        [self hideFilterButton];
        [self toggleCategories];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self hideFilterButton];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchResults removeAllObjects];
    [self.resultsTableView reloadData];
    [self.searchController.searchBar resignFirstResponder];
    [self.indicatorView startAnimating];
    if (![NSString isEmpty:searchBar.text]) {
        [self.restManager getRestaurantsWithQuery:searchBar.text atLocation:self.currentLocation filters:nil completionHandler:^(id restaurants) {
            [self.searchResults removeAllObjects];
            [self.searchResults addObjectsFromArray:restaurants];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showSuggestions = NO;
                [self showFilterBarButton];
                [self.indicatorView stopAnimating];
                [self.resultsTableView reloadData];
            });
        } failureHandler:^(id error) {
            self.showSuggestions = YES;
        }];
    }
}

#pragma mark - SearchFilterViewDelegate methods

- (void)didSelectFilters:(NSDictionary *)filters{
    NSLog(@"%@", filters);
    if (![NSString isEmpty:self.searchController.searchBar.text]) {
        [self.searchResults removeAllObjects];
        [self.resultsTableView reloadData];
        [self.searchController.searchBar resignFirstResponder];
        [self.indicatorView startAnimating];
        if (![NSString isEmpty:self.searchController.searchBar.text]) {
            [self.restManager getRestaurantsWithQuery:self.searchController.searchBar.text atLocation:self.currentLocation filters:filters completionHandler:^(id restaurants) {
                [self.searchResults removeAllObjects];
                [self.searchResults addObjectsFromArray:restaurants];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.showSuggestions = NO;
                    [self showFilterBarButton];
                    [self.indicatorView stopAnimating];
                    [self.resultsTableView reloadData];
                });
            } failureHandler:^(id error) {
                self.showSuggestions = YES;
            }];
        }
    }
    
}

- (void)didDismissFilterView{
    if ([self.filterView superview]) {
        [self.filterView removeFromSuperview];
    }
}


#pragma mark - Helper methods

- (void)toggleCategories{
    if (self.showCategories) {
        self.categoryCollectionView.alpha = 1.0;
        [self.view bringSubviewToFront:self.categoryCollectionView];
        [self.searchResults removeAllObjects];
        [self.resultsTableView reloadData];
    }else{
        self.categoryCollectionView.alpha = 0.0;
        [self.view sendSubviewToBack:self.categoryCollectionView];
    }
}

#pragma mark - Keyboard Handling

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchField resignFirstResponder];
}


- (void)keyboardWillShow:(NSNotification *)notif{
    CGRect keyboardFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat animDuration = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey]floatValue];
    
    UIEdgeInsets keyboardInset = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.size.height + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.frame.size.height, 0.0);
    [UIView animateWithDuration:animDuration animations:^{
        self.resultsTableView.contentInset = keyboardInset;
        self.resultsTableView.scrollIndicatorInsets = keyboardInset;
    }];    
}

- (void)keyboardWillHide:(NSNotification *)notif{
    CGFloat animDuration = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey]floatValue];
    
    UIEdgeInsets adjustForBarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame) + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.frame.size.height, 0);
    [UIView animateWithDuration:animDuration animations:^{
        self.resultsTableView.contentInset = adjustForBarInsets;
        self.resultsTableView.scrollIndicatorInsets = adjustForBarInsets;
    }];
}

@end
