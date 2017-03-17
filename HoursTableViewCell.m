//
//  HoursTableViewCell.m
//  FoodWise
//
//  Created by Brian Wong on 2/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "HoursTableViewCell.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

@interface HoursTableViewCell ()

@property (nonatomic, strong) UIImageView *hoursIcon;
@property (nonatomic, strong) UILabel *hoursTitle;
@property (nonatomic, assign) CGFloat dynamicHeight;


@end

@implementation HoursTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = APPLICATION_BACKGROUND_COLOR;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.hoursIcon = [[UIImageView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.02, RESTAURANT_HOURS_CELL_HEIGHT * 0.08, APPLICATION_FRAME.size.width * 0.04, APPLICATION_FRAME.size.width * 0.04)];
    self.hoursIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.hoursIcon.backgroundColor = [UIColor clearColor];
    [self.hoursIcon setImage:[UIImage imageNamed:@"hours_icon"]];
    [self.contentView addSubview:self.hoursIcon];
    
    self.hoursTitle = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width * 0.1, RESTAURANT_HOURS_CELL_HEIGHT * 0.17, APPLICATION_FRAME.size.width * 0.2, RESTAURANT_HOURS_CELL_HEIGHT * 0.24)];
    [self.hoursTitle setText:@"Hours"];
    [self.hoursTitle setTextColor:[UIColor blackColor]];
    [self.hoursTitle setFont:[UIFont nun_fontWithSize:RESTAURANT_HOURS_CELL_HEIGHT * 0.23]];
    [self.hoursTitle setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.hoursTitle];
}

//Dynamically space UI based on number of days
- (void)populateHours:(TPLRestaurant *)restaurant{
    if (!restaurant) {
        return;
    }
    
    if (restaurant.hours.count > 0) {
        if ((restaurant.hours.count - 1) == 1) {
            self.dynamicHeight = RESTAURANT_HOURS_CELL_HEIGHT;//One line of hours should still have same default height
        }else{
            self.dynamicHeight = RESTAURANT_HOURS_CELL_HEIGHT * (restaurant.hours.count * HOUR_CELL_SPACING);
        }
        
        NSArray *weeklyHours = restaurant.hours;
        
        NSMutableArray *dayArr = [NSMutableArray array];
        NSMutableArray *hrArr = [NSMutableArray array];
        
        for (NSDictionary *hrsForDay in weeklyHours) {
            if ([hrsForDay objectForKey:@"Today"]) {
                continue;
            }
            [dayArr addObject:[[hrsForDay allKeys]firstObject]];
            [hrArr addObject:[[hrsForDay allValues]firstObject]];
        }
        
        CGRect anchor = self.hoursTitle.frame;
        for (int i = 0; i < dayArr.count; ++i) {
            //Account for first spacing by checking for 0 and assigning a val
            CGFloat spacer = 0.12;
            if (i == 0) {
                spacer = 0.1;
            }
            
            UILabel *dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.hoursTitle.frame), CGRectGetMaxY(anchor) + (self.dynamicHeight * spacer), APPLICATION_FRAME.size.width * 0.35, RESTAURANT_HOURS_CELL_HEIGHT * 0.2)];
            dayLabel.backgroundColor = [UIColor clearColor];
            dayLabel.textColor = UIColorFromRGB(0x505254);
            [dayLabel setFont:[UIFont nun_fontWithSize:RESTAURANT_HOURS_CELL_HEIGHT * 0.19]];
            [dayLabel setText:dayArr[i]];
            [self.contentView addSubview:dayLabel];
            
            if (anchor.origin.y != dayLabel.frame.origin.y) {
                anchor = dayLabel.frame;
            }
            
            //In case there are multiple hours... Need to resize cell as well
            NSArray *hours = [hrArr[i] componentsSeparatedByString:@","];
            CGRect prevHrFrame = CGRectZero;
            for (int j = 0; j < hours.count; ++j) {
                UILabel *hourLabel;
                NSString *hrString = hours[j];
                if (j == 0) {
                    hourLabel = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width - APPLICATION_FRAME.size.width * 0.4, CGRectGetMinY(dayLabel.frame), APPLICATION_FRAME.size.width * 0.4, RESTAURANT_HOURS_CELL_HEIGHT * 0.2)];
                    hourLabel.backgroundColor = [UIColor clearColor];
                    hourLabel.textColor = UIColorFromRGB(0x505254);
                    [hourLabel setFont:[UIFont nun_fontWithSize:RESTAURANT_HOURS_CELL_HEIGHT * 0.19]];
                    [hourLabel setText:hrString];
                    [self.contentView addSubview:hourLabel];
                }else if (j == 1){
                    hrString = [hrString stringByReplacingOccurrencesOfString:@" " withString:@""];
                    hourLabel = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width - APPLICATION_FRAME.size.width * 0.4, CGRectGetMaxY(prevHrFrame) + 0.5, APPLICATION_FRAME.size.width * 0.4, RESTAURANT_HOURS_CELL_HEIGHT * 0.2)];
                    hourLabel.backgroundColor = [UIColor clearColor];
                    hourLabel.textColor = UIColorFromRGB(0x505254);
                    [hourLabel setFont:[UIFont nun_fontWithSize:RESTAURANT_HOURS_CELL_HEIGHT * 0.19]];
                    [hourLabel setText:hrString];
                    [self.contentView addSubview:hourLabel];
                }
                prevHrFrame = hourLabel.frame;//Just like for day, get last hour as an anchor
            }
        }
    }else{
        //No hours available
        self.dynamicHeight = RESTAURANT_HOURS_CELL_HEIGHT;
        
        UILabel *noHoursLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.hoursTitle.frame), self.dynamicHeight/1.6 - self.dynamicHeight * 0.1, APPLICATION_FRAME.size.width * 0.35, self.dynamicHeight * 0.2)];
        noHoursLabel.backgroundColor = [UIColor clearColor];
        [noHoursLabel setFont:[UIFont nun_fontWithSize:self.dynamicHeight * 0.2]];
        [noHoursLabel setText:@"Unavailable"];
        [noHoursLabel setTextColor:UIColorFromRGB(0x505254)];
        [self.contentView addSubview:noHoursLabel];
    }
    //[LayoutBounds drawBoundsForAllLayers:self];
}

@end
