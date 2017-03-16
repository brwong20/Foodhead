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

//Gets index path of collection view cell embedded in a the a table view row.
- (void)collectionView:(UICollectionView *)collectionView didSelectTabledCollectionCellAtIndexPath:(NSIndexPath *)indexPath withItem:(id)item;

//When user selects section arrow (nested delegate method which is called from TPLChartSectionView)
- (void)tableView:(UITableView *)tableView didSelectSectionWithChart:(NSDictionary *)chartInfo;

@end

//This class is a modularization of the main page's tableview's datasource/delegate AS WELL as handling the collection view embedded in each row.
@interface TabledCollectionManager : NSObject <UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<TabledCollectionDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableview
                cellIdentifier:(NSString *)cellId;

- (void)getRestaurantsAtLocation:(CLLocationCoordinate2D)coordinate;

- (void)getChartsAtLocation:(CLLocationCoordinate2D)coordinate;

@end
