//
//  ChartsTableDataSource.h
//  FoodWise
//
//  Created by Brian Wong on 1/24/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;

//Using a delegate so we can modularize all datasource & delegate methods into this class
@protocol TabledCollectionDelegate <NSObject>

- (void)collectionView:(UICollectionView*)collectionView didSelectTabledCollectionCellAtIndexPath:(NSIndexPath*)indexPath withItem:(id)item;

@end

//This class is a modularization of the main page's tableview's datasource/delegate AS WELL as handling the collection view embedded in each row.
@interface TabledCollectionManager : NSObject <UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, weak) id<TabledCollectionDelegate> delegate;

- (instancetype)initWithTableView:(UITableView*)tableview
                cellIdentifier:(NSString*)cellId;

- (void)getRestaurants;
- (void)collectionViewReloadDataWith:(NSMutableArray*)data;

@end
