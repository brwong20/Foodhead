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

@interface TPLFilterScrollView() <UIScrollViewDelegate, TasteFilterDelegate, PriceFilterDelegate, HealthFilterDelegate>

//When scaling this should eventually return from the db all the filter category, name, rating scheme, etc.
@property (nonatomic, strong) NSMutableArray *filterArr;
@property (nonatomic, strong) FilterView *visibleFilter;

@end

const static int startingIndex = 1;
const static int NUM_FILTERS = 3;

@implementation TPLFilterScrollView

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image{
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
    }
    return self;
}

- (void)loadFilters{
    [self setContentSize:CGSizeMake(self.frame.size.width * (NUM_FILTERS + 2), self.frame.size.height)];
    
    //Setup filter 'roulette' then place them into their respective positions
    self.filterArr = [NSMutableArray array];

    HealthFilterView *healthFake = [HealthFilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewTypeHealth];
    //healthFake.backgroundColor = [UIColor lightGrayColor];
    [self.filterArr addObject:healthFake];
    
    PriceFilterView *priceFilter = [FilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewTypePrice];
    priceFilter.delegate = self;
    [self.filterArr addObject:priceFilter];
    
    TasteFilterView *tasteFilter = [FilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewTypeTaste];
    tasteFilter.delegate = self;
    [self.filterArr addObject:tasteFilter];
    
    HealthFilterView *healthFilter = [HealthFilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewTypeHealth];
    healthFilter.delegate = self;
    [self.filterArr addObject:healthFilter];
    
    PriceFilterView *priceFake = [FilterView createFilterWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewTypePrice];
    //priceFake.backgroundColor = [UIColor lightGrayColor];
    [self.filterArr addObject:priceFake];
    
    for (int i = 0; i < self.filterArr.count; ++i) {
        FilterView *filter = self.filterArr[i];
        CGRect filtFrame = filter.frame;
        filtFrame.origin.x = [self positionOfPageAtIndex:(i-1)];
        filter.frame = filtFrame;
        [self addSubview:filter];
    }
    
    [self setContentOffset:CGPointMake([self positionOfPageAtIndex:startingIndex], 0.0)];
}

#warning Need better cutoff or some other logic to make infinite scroll less choppy at ends
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x < self.frame.size.width/INT_MAX) {
        [self scrollRectToVisible:CGRectMake([self positionOfPageAtIndex:NUM_FILTERS - 1], 0, self.frame.size.width, self.frame.size.height) animated:NO];
    }else if (scrollView.contentOffset.x > (NUM_FILTERS + 1) * scrollView.frame.size.width - 10.0){
        [self scrollRectToVisible:CGRectMake([self positionOfPageAtIndex:0], 0, self.frame.size.width, self.frame.size.height) animated:NO];
    }
    [self updateCurrentFilter];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (![self.visibleFilter isKindOfClass:[PriceFilterView class]]) {
        PriceFilterView *priceFilter = self.filterArr[1];
        [priceFilter dismissKeypad];
    }
}

- (CGFloat)positionOfPageAtIndex:(int)index{
    return self.frame.size.width * (CGFloat)index + self.frame.size.width;
}

- (void)updateCurrentFilter{
    CGFloat index = self.contentOffset.x / self.frame.size.width;
    self.visibleFilter = self.filterArr[(int)index];
}

//Important we make these unanimated so user doesn't notice the trick
//- (void)scrollToFirstRealImage{
//    [self setContentOffset:CGPointMake(self.frame.size.width, self.contentOffset.y) animated:NO];
//}
//
//- (void)scrollToLastRealImage{
//    [self setContentOffset:CGPointMake(self.contentOffset.x + (self.frame.size.width * NUM_FILTERS + 1), self.contentOffset.y) animated:NO];
//}


#pragma mark - TasteFilterDelegate methods

- (void)didRateOverall:(NSNumber *)overall{
    if ([self.scrollDelegate respondsToSelector:@selector(didUpdateOverall:)]) {
        [self.scrollDelegate didUpdateOverall:overall];
    }
}

#pragma mark - PriceFilterDelegate methods

- (void)priceWasUpdated:(NSNumber *)price{
    //Get fake price and update so our fake filter matches with real price input
    PriceFilterView *priceFake = [self.filterArr lastObject];
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
    NSLog(@"HEALTH: %@", healthiness);
    if ([self.scrollDelegate respondsToSelector:@selector(didUpdateHealthiness:)]) {
        [self.scrollDelegate didUpdateHealthiness:healthiness];
    }
}

@end
