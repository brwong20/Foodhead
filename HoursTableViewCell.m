//
//  HoursTableViewCell.m
//  FoodWise
//
//  Created by Brian Wong on 2/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "HoursTableViewCell.h"
#import "FoodWiseDefines.h"

@interface HoursTableViewCell ()

@property (nonatomic, strong) UILabel *hoursTitle;


@end

@implementation HoursTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //Based on number of days, we have to dyanamically create labels and resize height
        self.backgroundColor = APPLICATION_BACKGROUND_COLOR;
        [self populateHoursForDays];
        
    }
    return self;
}

- (void)populateHoursForDays{
    
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    
    self.hoursTitle = [[UILabel alloc]initWithFrame:CGRectMake(screenBounds.size.width * 0.05, RESTAURANT_HOURS_CELL_HEIGHT * 0.1, screenBounds.size.width * 0.3, RESTAURANT_HOURS_CELL_HEIGHT * 0.2)];
    [self.hoursTitle setText:@"Hours"];
    [self.hoursTitle setTextColor:[UIColor whiteColor]];
    [self.hoursTitle setFont:[UIFont systemFontOfSize:16.0]];
    [self.hoursTitle setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.hoursTitle];
    
    UILabel *monFri = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.hoursTitle.frame), CGRectGetMaxY(self.hoursTitle.frame), screenBounds.size.width * 0.2, RESTAURANT_HOURS_CELL_HEIGHT * 0.3)];
    monFri.backgroundColor = [UIColor clearColor];
    monFri.text = @"Mon - Fri";
    monFri.textColor = [UIColor whiteColor];
    monFri.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:monFri];
                                                            
}

- (void)convertHoursToLabels:(NSDictionary *)hours{
    
}

@end
