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

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, SearchFilterViewDelegate>

@property (nonatomic, strong) TPLRestaurantManager *restManager;

//Search UI
@property (nonatomic, strong) UITableView *resultsTableView;
@property (nonatomic, strong) UICollectionView *categoryCollectionView;
@property (nonatomic, strong) UISearchBar *searchBar;

//Categories + Results
@property (nonatomic, strong) NSArray *categoryTitles;
@property (nonatomic, strong) NSArray *categoryValues;
@property (nonatomic, strong) NSMutableArray *searchResults;

//Search indicator
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL showCategories;//Show category suggestions
@property (nonatomic, assign) BOOL showSuggestions;//Show restaurant & category suggestions based on query. If false, shows actual results
@property (nonatomic, strong) UILabel *errorLabel;

//Filter View
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) SearchFilterView *filterView;

//Paging
@property (nonatomic, strong) NSString *nextPage;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreIndicator;
@property (nonatomic, strong) UILabel *loadMoreLabel;

@end

static NSString *searchCellId = @"searchCell";
static NSString *categoryCellId = @"categoryCell";
static NSString *exploreCellId = @"exploreCell";

#define NUM_COLUMNS 3
#define NUM_ROWS 5

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.currentLocation = [[LocationManager sharedLocationInstance]currentLocation];
    self.restManager = [[TPLRestaurantManager alloc]init];
    self.searchResults = [NSMutableArray array];
    self.nextPage = @"";
    
    [self addObservers];
    
    self.categoryTitles = @[@"Coffee", @"Salad", @"Juice", @"Mexican", @"Breakfast", @"Sushi", @"Asian", @"Burgers", @"Noodle Soup", @"Drinks", @"Dessert", @"Fancy", @"Vegetarian" , @"Pizza", @"Steakhouse"];
    self.categoryValues = @[ @"Coffee Shop", @"Salad", @"Juice Bar", @"Mexican", @"Breakfast", @"Sushi", @"Asian Restaurant", @"Burgers", @"Noodle soup", @"Nightlife Spot", @"Dessert Shop", @"Fancy", @"Vegetarian / Vegan Restaurant", @"Pizza Place", @"Steakhouse"];
    
    CGSize adjustedFrame = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - (CGRectGetHeight(self.tabBarController.tabBar.frame) + (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.frame.size.height)));
    
    self.showCategories = YES;
    self.showSuggestions = YES;
    
    self.searchBar  = [[ UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.7, 40.0)];
    self.searchBar.barStyle = UIBarStyleDefault;
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = @"Search restaurants & food";
    self.searchBar.tintColor = [UIColor blackColor];
    self.searchBar.backgroundColor = [UIColor clearColor];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setDefaultTextAttributes:@{NSFontAttributeName : [UIFont nun_fontWithSize:16.0] , NSForegroundColorAttributeName : [UIColor blackColor]}];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setBackgroundColor:UIColorFromRGB(0xDBDBDB)];
    self.navigationItem.titleView = self.searchBar;
    
    //Adjust for tab bar height covering views
    UIEdgeInsets adjustForBarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame) + (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.frame.size.height), 0);
    
    self.resultsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.resultsTableView.delegate = self;
    self.resultsTableView.dataSource = self;
    self.resultsTableView.contentInset = adjustForBarInsets;
    self.resultsTableView.scrollIndicatorInsets = adjustForBarInsets;
    self.resultsTableView.backgroundColor = UIColorFromRGB(0xDBDBDB);
    self.resultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.resultsTableView.showsVerticalScrollIndicator = NO;
    [self.resultsTableView registerClass:[SearchTableViewCell class] forCellReuseIdentifier:searchCellId];
    [self.resultsTableView registerClass:[ResultTableViewCell class] forCellReuseIdentifier:exploreCellId];
    [self.view addSubview:self.resultsTableView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 1.0;
    flowLayout.minimumLineSpacing = 1.0;
    CGFloat itemWidth = (CGRectGetWidth(self.view.bounds) - (NUM_COLUMNS - 1.0)) / NUM_COLUMNS;
    CGFloat itemHeight = ((adjustedFrame.height) - (NUM_ROWS - 1.0))/NUM_ROWS;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.categoryCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, adjustedFrame.height) collectionViewLayout:flowLayout];
    self.categoryCollectionView.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.categoryCollectionView.delegate = self;
    self.categoryCollectionView.dataSource = self;
    self.categoryCollectionView.contentInset = adjustForBarInsets;
    self.categoryCollectionView.scrollIndicatorInsets = adjustForBarInsets;
    self.categoryCollectionView.showsVerticalScrollIndicator = NO;
    self.categoryCollectionView.scrollEnabled = NO;
    [self.categoryCollectionView registerClass:[CategoryCollectionViewCell class] forCellWithReuseIdentifier:categoryCellId];
    [self.view addSubview:self.categoryCollectionView];
    
    self.filterView = [[SearchFilterView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, adjustedFrame.height)];
    self.filterView.delegate = self;
    
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = CGPointMake(self.resultsTableView.center.x, self.resultsTableView.center.y - CGRectGetHeight(self.tabBarController.tabBar.frame));
    [self.resultsTableView addSubview:self.indicatorView];
    
    self.errorLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2 - self.view.bounds.size.width * 0.3, self.view.bounds.size.height * 0.2, self.view.bounds.size.width * 0.6, self.view.bounds.size.height * 0.15)];
    self.errorLabel.numberOfLines = 2;
    self.errorLabel.backgroundColor = [UIColor clearColor];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.font = [UIFont nun_fontWithSize:16.0];
    self.errorLabel.textColor = [UIColor grayColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNavBar];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[[self navigationController] interactivePopGestureRecognizer] setEnabled:NO];//Just like with charts, this makes sure we don't have any problems with swipe back gesture.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self dismissKeyboard];
    [self resetNavBar];
}

- (void)setupNavBar{
    self.navigationController.extendedLayoutIncludesOpaqueBars = YES;//Must set this or search bar goes off-screen when presented
    self.navigationController.navigationBar.translucent = NO;
}

- (void)resetNavBar{
    self.navigationController.navigationBar.translucent = YES;
    [[[self navigationController] interactivePopGestureRecognizer] setEnabled:YES];

}

- (void)showFilterBarButton{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"filter"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(showFilterView)];

}

- (void)hideFilterButton{
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)dealloc{
    [self removeObservers];
}

- (void)showFilterView{
    if (![self.filterView superview]) {
        [self dismissKeyboard];
        [self.view addSubview:self.filterView];
    }
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
        id suggestion = self.searchResults[indexPath.row];
        if ([suggestion isKindOfClass:[TPLRestaurant class]]) {
            //Must dismiss to avoid view controller UI glitch
            [self dismissKeyboard];
            TPLRestaurant *restaurant = suggestion;
            TPLRestaurantPageViewController *restPageVC = [[TPLRestaurantPageViewController alloc]init];
            restPageVC.currentLocation = self.currentLocation;
            restPageVC.selectedRestaurant = restaurant;
            [self.navigationController pushViewController:restPageVC animated:YES];
        }else if([suggestion isKindOfClass:[Category class]]){
            //Search based on category
            Category *category = suggestion;
            self.searchBar.text = category.categoryShortName;
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    }else{
        //Opening rest page from ResultTableViewCell
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
        if (indexPath.row == self.searchResults.count && ![NSString isEmpty:self.nextPage]) {
            cellHeight = SEARCH_CONTROLLER_CELL_HEIGHT;//Loading cell height
        }else{
            cellHeight = RESULT_CELL_HEIGHT;
        }
    }
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numCells;
    //Should not show load cell if no more pages OR when the search has just begun (last condition)
    if (!self.showSuggestions  && ![NSString isEmpty:self.nextPage] && self.searchResults.count > 0) {
        numCells = self.searchResults.count + 1;
    }else{
        numCells = self.searchResults.count;
    }
    return numCells;
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
        if (indexPath.row < self.searchResults.count) {
            TPLRestaurant *restaurant = self.searchResults[indexPath.row];
            ResultTableViewCell *resultCell = (ResultTableViewCell *)[tableView dequeueReusableCellWithIdentifier:exploreCellId];
            [resultCell populateRestaurant:restaurant];
            cell = resultCell;
        }else{
            cell = [self getLoadingCell];
        }
    }
    return cell;
}

#pragma mark - UITableView paging methods

- (UITableViewCell *)getLoadingCell{
    UITableViewCell *loadCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    loadCell.backgroundColor = [UIColor clearColor];
    
    UIView *loadView = [[UIView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width/2 - APPLICATION_FRAME.size.width * 0.44, SEARCH_CONTROLLER_CELL_HEIGHT/2 - SEARCH_CONTROLLER_CELL_HEIGHT * 0.43, APPLICATION_FRAME.size.width * 0.88, SEARCH_CONTROLLER_CELL_HEIGHT * 0.86)];
    loadView.backgroundColor = [UIColor whiteColor];
    loadView.layer.cornerRadius = 7.0;
    [loadCell.contentView addSubview:loadView];
    
    self.loadMoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(loadView.bounds.size.width/2 - loadView.bounds.size.width * 0.35, loadView.bounds.size.height/2 - loadView.bounds.size.height * 0.17, loadView.bounds.size.width * 0.7, loadView.bounds.size.height * 0.34)];
    self.loadMoreLabel.text = @"Tap to load more restaurants";
    self.loadMoreLabel.textAlignment = NSTextAlignmentCenter;
    self.loadMoreLabel.backgroundColor = [UIColor clearColor];
    self.loadMoreLabel.font = [UIFont nun_fontWithSize:16.0];
    [loadView addSubview:self.loadMoreLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadMoreResults)];
    tapGesture.numberOfTapsRequired = 1;
    [loadView addGestureRecognizer:tapGesture];
    
    //When tapped, show this and load more
    self.loadMoreIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadMoreIndicator.tintColor = [UIColor lightGrayColor];
    self.loadMoreIndicator.center = CGPointMake(loadView.bounds.size.width/2, loadView.bounds.size.height/2);
    [loadView addSubview:self.loadMoreIndicator];
    
    return loadCell;
}

- (void)loadMoreResults{
    if (!self.loadMoreIndicator.isAnimating) {//Make sure user doesn't run this request multiple times
        self.loadMoreLabel.alpha = 0.0;
        [self.loadMoreIndicator startAnimating];
        if ([self.errorLabel superview]) [self.errorLabel removeFromSuperview];
        if (![NSString isEmpty:self.searchBar.text] && ![NSString isEmpty:self.nextPage]) {
            [self.restManager getRestaurantsWithQuery:self.searchBar.text atLocation:self.currentLocation filters:nil page:self.nextPage completionHandler:^(NSDictionary *restaurants) {
                self.nextPage = restaurants[@"nextPage"];
                [self.searchResults addObjectsFromArray:restaurants[@"results"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.showSuggestions = NO;
                    self.loadMoreLabel.alpha = 1.0;
                    [self.loadMoreIndicator stopAnimating];
                    [self showFilterBarButton];
                    [self.indicatorView stopAnimating];
                    [self.resultsTableView reloadData];
                });
            } failureHandler:^(id error) {
                [self clearResults];
                [self.indicatorView stopAnimating];
                [self showError];
                self.showSuggestions = YES;
            }];
        }else{
            //Change load more label here to tell user about error?
            self.loadMoreLabel.alpha = 1.0;
            [self.loadMoreIndicator stopAnimating];
        }
    }
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.searchBar.text = self.categoryTitles[indexPath.row];
    self.showCategories = NO;
    [self toggleCategories];
    [self searchBarSearchButtonClicked:self.searchBar];
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

#pragma mark - UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (![NSString isEmpty:searchText]) {
        self.showCategories = NO;
        self.showSuggestions = YES;
        [self toggleCategories];
        if ([self.errorLabel superview]) [self.errorLabel removeFromSuperview];
        [self.restManager fullRestaurantSearchWithQuery:searchText atLocation:self.currentLocation
                                      completionHandler:^(id suggestions) {
            [self.searchResults removeAllObjects];
            [self.searchResults addObjectsFromArray:suggestions];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.resultsTableView reloadData];
            });
        } failureHandler:^(id error) {
            [self clearResults];
            [self.indicatorView stopAnimating];
            [self showError];
        }];
    }else{
        self.showCategories = YES;
        self.showSuggestions = YES;
        [self clearResults];
        [self hideFilterButton];
        [self toggleCategories];
    }
}

//Should reset everything
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self clearResults];
    [self hideFilterButton];
    if ([self.filterView superview]) {
        [self.filterView removeFromSuperview];
    }
    self.showCategories = YES;
    self.showSuggestions = YES;
    [self dismissKeyboard];
    [self toggleCategories];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self clearResults];
    [self dismissKeyboard];
    [self.indicatorView startAnimating];
    if ([self.errorLabel superview]) [self.errorLabel removeFromSuperview];
    if (![NSString isEmpty:searchBar.text]) {
        [self.restManager getRestaurantsWithQuery:self.searchBar.text atLocation:self.currentLocation filters:nil page:nil completionHandler:^(NSDictionary *restaurants) {
            self.nextPage = restaurants[@"nextPage"];
            [self.searchResults removeAllObjects];
            [self.searchResults addObjectsFromArray:restaurants[@"results"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showSuggestions = NO;
                [self showFilterBarButton];
                [self.indicatorView stopAnimating];
                [self.resultsTableView reloadData];
            });
        } failureHandler:^(id error) {
            [self clearResults];
            [self.indicatorView stopAnimating];
            [self showError];
            self.showSuggestions = YES;
        }];
    }
}

//Animate the cancel button like UISearchController does
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:NO];
}


-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:NO];
}

#pragma mark - SearchFilterViewDelegate methods

- (void)didSelectFilters:(NSDictionary *)filters{
    NSLog(@"%@", filters);
    if ([self.filterView superview]) [self.filterView removeFromSuperview];
    if ([self.errorLabel superview]) [self.errorLabel removeFromSuperview];
    if (![NSString isEmpty:self.searchBar.text]) {
        [self clearResults];
        [self dismissKeyboard];
        [self.indicatorView startAnimating];
        if (![NSString isEmpty:self.searchBar.text]) {
            [self.restManager getRestaurantsWithQuery:self.searchBar.text atLocation:self.currentLocation filters:filters page:nil completionHandler:^(NSDictionary *restaurants) {
                self.nextPage = restaurants[@"nextPage"];
                [self.searchResults removeAllObjects];
                [self.searchResults addObjectsFromArray:restaurants[@"results"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.showSuggestions = NO;
                    [self showFilterBarButton];
                    [self.indicatorView stopAnimating];
                    [self.resultsTableView reloadData];
                });
            } failureHandler:^(id error) {
                [self clearResults];
                [self.indicatorView stopAnimating];
                [self showError];
                self.showSuggestions = YES;
            }];
        }
    }
    
}

#pragma mark - Helper methods

- (void)toggleCategories{
    if (self.showCategories) {
        [self.categoryCollectionView setHidden:NO];
        [self clearResults];
    }else{
        [self.categoryCollectionView setHidden:YES];
    }
}

- (void)showError{
    if (![self.errorLabel superview]) {
        self.errorLabel.text = @"No search results. Please check your connection and try again!";
        [self.resultsTableView addSubview:self.errorLabel];
    }
}

- (void)clearResults{
    self.nextPage = @"";
    [self.searchResults removeAllObjects];
    [self.resultsTableView reloadData];
}

#pragma mark - Keyboard Handling

- (void)dismissKeyboard{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self dismissKeyboard];
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
