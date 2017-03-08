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

@interface TPLFilterScrollView() <UIScrollViewDelegate, TasteFilterDelegate>

//When scaling this should eventually return from the db all the filter category, name, rating scheme, etc.
@property (nonatomic, strong) NSArray *filterArr;
@property (nonatomic, strong) UIImage *selectedImage;

@end

const static int NUM_FILTERS = 4;

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
        self.selectedImage = image;
        [self loadFilters];
    }
    return self;
}

- (void)loadFilters{
    for ( int i = 1; i <= NUM_FILTERS + 2 ; i ++) {
        TasteFilterView *tasteFilter = [TasteFilterView createFilterWithFrame:CGRectMake((i - 1) * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) ofType:FilterViewTypeTaste];
        tasteFilter.delegate = self;
        tasteFilter.backgroundColor = [UIColor clearColor];
        if ( i  % NUM_FILTERS == 1){
            [tasteFilter.filterTitle setText:@"Taste"];
        }
        else if (i % NUM_FILTERS == 2) {
            [tasteFilter.filterTitle setText:@"Origin"];
        }
        else if(i % NUM_FILTERS == 3){
            [tasteFilter.filterTitle setText:@"Price"];
        }
        else{
            [tasteFilter.filterTitle setText:@"Healthiness"];
        }
        [self addSubview:tasteFilter];
    }
    [self setContentOffset:CGPointMake(self.frame.size.width, 0)];//Default start position
    //Always have 5 screens (2 + number screens we want) so we have fake beginning + end frames on each side. Resize content size here to fit all frames
    [self setContentSize:CGSizeMake(self.frame.size.width * (NUM_FILTERS + 2), self.frame.size.height)];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self) {
        if (scrollView.contentOffset.x < self.frame.size.width/INT_MAX){//If user scrolls before first "real image"
            
            /*BUG: Scrolls to last real(then auto scrolls to first real) when we're supposed to be on first real if they don't scroll all the way...
             
             One Solution: If user scrolls more than halfway backward (will show last pic), set to last real pic. Else if they scroll less than half, do NOTHING.
             
             ->  This is why I divided by INT_MAX in order to make the halfway scroll boundary super small (makes it seem like user has scrolled to the full image). When they hit this boundary, we will perform our shift trick.
             */
            
            [self scrollToLastRealImage];
        }
        else if (scrollView.contentOffset.x > (NUM_FILTERS + 1) * scrollView.frame.size.width){
            [self scrollToFirstRealImage];
        }
    }
}

//Important we make these unanimated so user doesn't notice the trick
- (void)scrollToFirstRealImage{
    [self setContentOffset:CGPointMake(self.frame.size.width, self.contentOffset.y) animated:NO];
}

- (void)scrollToLastRealImage{
    [self setContentOffset:CGPointMake(self.contentOffset.x + (self.frame.size.width * NUM_FILTERS), self.contentOffset.y) animated:NO];
}


#pragma mark - TasteFilterDelegate methods

- (void)didRateTaste:(NSNumber *)tasteAmount{
    NSLog(@"%@", tasteAmount);
}

@end
