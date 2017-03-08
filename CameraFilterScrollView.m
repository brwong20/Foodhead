//
//  CameraFilterScrollView.m
//  FoodWise
//
//  Created by Brian Wong on 2/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "CameraFilterScrollView.h"

@interface CameraFilterScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) GPUImageStillCamera *stillCamera;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *filters;

@property (nonatomic, strong) GPUImagePicture *lookup;//Must retain these lookup tables in order to use them to create GPUImageLookupFilters

@end

static int startingIndex = 0;
static int numFilters = 3;

@implementation CameraFilterScrollView

- (instancetype)initWithFrame:(CGRect)frame andStillCamera:(GPUImageStillCamera *)stillCamera{
    self = [super initWithFrame:frame];
    if (self) {
        self.stillCamera = stillCamera;
        self.filters = [NSMutableArray array];
        [self setupScrollView:frame];
    }
    return self;
}

- (void)setupScrollView:(CGRect)frame{
    self.scrollView = [[UIScrollView alloc]initWithFrame:frame];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    
    [self addSubview:self.scrollView];
}

- (void)setupFilters{
    [self clearFilterData];
    [self loadFilterData];
    [self presentFilters];
}

- (void)clearFilterData
{
    for (id filter in self.subviews) {
        if ([filter isKindOfClass:[CameraScrollFilter class]]) {//Make sure to not remove the scrollview
            [filter removeFromSuperview];
        }
    }
    [self.filters removeAllObjects];
}

- (void)loadFilterData{
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * (numFilters + 2), self.frame.size.height);
    
    //Custom filter
    CameraScrollFilter *sweetDum = [[CameraScrollFilter alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withCamera:self.stillCamera andLookupImage:[UIImage imageNamed:@"sweet3"]];
    sweetDum.lookupFilter.intensity = 1.0;
    [self.filters addObject:sweetDum];
    
    CameraScrollFilter *origin = [[CameraScrollFilter alloc]initWithFrame:self.frame withCamera:self.stillCamera andGPUFilter:[[GPUImageSepiaFilter alloc]init]];
    [self.filters addObject:origin];
    
    CameraScrollFilter *yum = [[CameraScrollFilter alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withCamera:self.stillCamera andLookupImage:[UIImage imageNamed:@"yum4"]];
    [self.filters addObject:yum];
    
    CameraScrollFilter *sweet = [[CameraScrollFilter alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withCamera:self.stillCamera andLookupImage:[UIImage imageNamed:@"sweet3"]];
    sweet.lookupFilter.intensity = 1.0;
    [self.filters addObject:sweet];

    CameraScrollFilter *originDum = [[CameraScrollFilter alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withCamera:self.stillCamera andGPUFilter:[[GPUImageSepiaFilter alloc]init]];
    [self.filters addObject:originDum];
    
    /*
        GPUImageView *fil3 = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        fil1.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        GPUImageLookupFilter *lookupFil = [[GPUImageLookupFilter alloc] init];
        lookupFilter.intensity = 1.0;
    
        [self.stillCamera addTarget:lookupFil atTextureLocation:0];
        [self.lookup addTarget:lookupFil atTextureLocation:1];
        [self.lookup processImage];
        [lookupFilter addTarget:fil3];
        [lookupFilter useNextFrameForImageCapture];
    
        GPUImageView *dum2 = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        dum2.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        GPUImageSepiaFilter *gam = [[GPUImageSepiaFilter alloc]init];
        gam.intensity = 0.0;
        [self.stillCamera addTarget:gam];
        [gam addTarget:dum2];
     */
    
    
    //Scroll to starting index
    [self.scrollView scrollRectToVisible:CGRectMake([self positionOfPageAtIndex:startingIndex], 0, self.frame.size.width, self.frame.size.height) animated:NO];
}

- (void)presentFilters{
    for (int i = 0; i < self.filters.count; ++i) {
        CameraScrollFilter *filter = [self.filters objectAtIndex:i];
        [self applyMask:filter];
        [self updateMask:filter newXPosition:[self positionOfPageAtIndex:i - startingIndex - 2]];
        [self insertSubview:filter belowSubview:self.scrollView];
    }
    
}

- (CGFloat)positionOfPageAtIndex:(int)index{
    return self.frame.size.width * (CGFloat)index + self.frame.size.width;
}

- (void)applyMask:(CameraScrollFilter *)filter{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect maskRect = filter.frame;
    CGPathAddRect(path, nil, maskRect);
    maskLayer.path = path;
    filter.layer.mask = maskLayer;
    
    CGPathRelease(path);
}

- (void)updateMask:(CameraScrollFilter *)filter newXPosition:(CGFloat)xPos{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect maskRect = filter.frame;
    maskRect.origin.x = xPos;
    CGPathAddRect(path, nil, maskRect);
    maskLayer.path = path;
    filter.layer.mask = maskLayer;
    
    CGPathRelease(path);
}


- (void)updateCurrentFilter{
    CGFloat index = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    self.currentFilter = self.filters[(int)index];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    for (int i = 0; i < self.filters.count; ++i) {
        CameraScrollFilter *filter = self.filters[i];
        [self updateMask:filter newXPosition:[self positionOfPageAtIndex:(i - 1)] - scrollView.contentOffset.x];
    }
}

//Infinite scroll behavior - if we reach the first or last filter, then scroll to the respective beginning or end of the filters
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == [self positionOfPageAtIndex:-1]) {
        [self.scrollView scrollRectToVisible:CGRectMake([self positionOfPageAtIndex:numFilters - 1], 0, self.frame.size.width, self.frame.size.height) animated:NO];
    }else if (scrollView.contentOffset.x == [self positionOfPageAtIndex:numFilters]){
        [self.scrollView scrollRectToVisible:CGRectMake([self positionOfPageAtIndex:0], 0, self.frame.size.width, self.frame.size.height) animated:NO];
    }
    [self updateCurrentFilter];
}


@end
