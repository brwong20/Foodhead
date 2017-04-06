//
//  TPLFilterScrollView.m
//  FoodWise
//
//  Created by Brian Wong on 2/5/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "TPLFilterScrollView.h"
#import "FilterView.h"
#import "TasteFilterView.h"
#import "PriceFilterView.h"
#import "HealthFilterView.h"
#import "FoodheadAnalytics.h"

@interface TPLFilterScrollView() <UIScrollViewDelegate, TasteFilterDelegate, PriceFilterDelegate, HealthFilterDelegate>

//When scaling this should eventually return from the db all the filter category, name, rating scheme, etc.
@property (nonatomic, strong) NSMutableArray *filterArr;
@property (nonatomic, strong) FilterView *visibleFilter;
@property (nonatomic, strong) NSNumber *numSwipes;

@end

const static int STARTING_INDEX = 0;
const static int NUM_FILTERS = 4;

@implementation TPLFilterScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.scrollsToTop = NO;
        self.delegate = self;
        self.delaysContentTouches = NO;
        self.decelerationRate = 30.0;
        self.numSwipes = @(0);
    }
    return self;
}

- (void)removeFromSuperview{
    [FoodheadAnalytics logEvent:FILTER_SWIPE withParameters:@{@"numFilterSwipes" : self.numSwipes}];
}

- (void)loadFilters{
    [self setContentSize:CGSizeMake(self.frame.size.width * (NUM_FILTERS + 2), self.frame.size.height)];
    
    //Setup filter 'roulette' then place them into their respective positions
    self.filterArr = [NSMutableArray array];
    
    PriceFilterView *priceFake = [FilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewTypePrice];
    [self.filterArr addObject:priceFake];
    
    FilterView *blankFilter = [FilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewBlank];
    blankFilter.backgroundColor = [UIColor clearColor];
    [self.filterArr addObject:blankFilter];
    
    TasteFilterView *tasteFilter = [FilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewTypeTaste];
    tasteFilter.delegate = self;
    [self.filterArr addObject:tasteFilter];
    
    HealthFilterView *healthFilter = [HealthFilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewTypeHealth];
    healthFilter.delegate = self;
    [self.filterArr addObject:healthFilter];
    
    PriceFilterView *priceFilter = [FilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewTypePrice];
    priceFilter.delegate = self;
    [self.filterArr addObject:priceFilter];
    
    FilterView *blankFilterFake = [FilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewBlank];
    blankFilter.backgroundColor = [UIColor clearColor];
    [self.filterArr addObject:blankFilterFake];
    
    for (int i = 0; i < self.filterArr.count; ++i) {
        FilterView *filter = self.filterArr[i];
        CGRect filtFrame = filter.frame;
        filtFrame.origin.x = [self positionOfPageAtIndex:(i-1)];
        filter.frame = filtFrame;
        [self addSubview:filter];
    }
    
    [self setContentOffset:CGPointMake([self positionOfPageAtIndex:STARTING_INDEX], 0.0)];
}

#warning Need better cutoff or some other logic to make infinite scroll less choppy at ends
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x < self.frame.size.width/INT_MAX) {
        [self scrollRectToVisible:CGRectMake([self positionOfPageAtIndex:NUM_FILTERS - 1], 0, self.frame.size.width, self.frame.size.height) animated:NO];
    }else if (scrollView.contentOffset.x > (NUM_FILTERS + 1) * scrollView.frame.size.width){
        [self scrollRectToVisible:CGRectMake([self positionOfPageAtIndex:0], 0, self.frame.size.width, self.frame.size.height) animated:NO];
    }
    if ([self.scrollDelegate respondsToSelector:@selector(filterViewDidScroll:)]) {
        [self.scrollDelegate filterViewDidScroll:self];
    }
    [self updateCurrentFilter];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    //Page did change
    if (previousPage != page) {
        previousPage = page;
        self.numSwipes = @(self.numSwipes.intValue + 1);
    }
    
    if (self.visibleFilter.filterType != FilterViewTypePrice) {
        [self dismissPriceKeypad];
    }
}

- (void)dismissPriceKeypad{
    PriceFilterView *priceFilter = [self.filterArr objectAtIndex:4];
    [priceFilter dismissKeypad];
}

- (CGFloat)positionOfPageAtIndex:(int)index{
    return self.frame.size.width * (CGFloat)index + self.frame.size.width;
}

//Important: if we set a cutoff, need to make it's accounted for here (since we dont scroll to end with cutoff)
- (void)updateCurrentFilter{
    CGFloat index = self.contentOffset.x / self.frame.size.width;
    self.visibleFilter = self.filterArr[(int)index];
}

#pragma mark - TasteFilterDelegate methods

- (void)didRateOverall:(NSNumber *)overall{
    if ([self.scrollDelegate respondsToSelector:@selector(didUpdateOverall:)]) {
        [self.scrollDelegate didUpdateOverall:overall];
    }
}

#pragma mark - PriceFilterDelegate methods

- (void)priceWasUpdated:(NSNumber *)price{
    //Get fake price and update so our fake filter matches with real price input
    PriceFilterView *priceFake = [self.filterArr firstObject];
    [priceFake setPrice:price];
    if ([self.scrollDelegate respondsToSelector:@selector(didUpdatePrice:)]) {
        [self.scrollDelegate didUpdatePrice:price];
    }
}

- (void)keypadWillShow:(NSNotification *)notif{
    if ([self.scrollDelegate respondsToSelector:@selector(pricePadWillShow:)]) {
        [self.scrollDelegate pricePadWillShow:notif];
    }
}

- (void)keypadWillHide:(NSNotification *)notif{
    if ([self.scrollDelegate respondsToSelector:@selector(pricePadWillHide:)]) {
        [self.scrollDelegate pricePadWillHide:notif];
    }
}

#pragma mark - HealthFilterDelegate methods

- (void)didRateHealth:(NSNumber *)healthiness{
//    HealthFilterView *healthFilter = [self.filterArr firstObject];
//    [healthFilter setHealth:healthiness];
    if ([self.scrollDelegate respondsToSelector:@selector(didUpdateHealthiness:)]) {
        [self.scrollDelegate didUpdateHealthiness:healthiness];
    }
}

@end
