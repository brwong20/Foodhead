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
    
    self.hoursIcon = [[UIImageView alloc]initWithFrame:CGRectMake(REST_PAGE_ICON_PADDING * 1.26, RESTAURANT_HOURS_CELL_HEIGHT * 0.15, APPLICATION_FRAME.size.width * 0.05, APPLICATION_FRAME.size.width * 0.05)];
    self.hoursIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.hoursIcon.backgroundColor = [UIColor clearColor];
    [self.hoursIcon setImage:[UIImage imageNamed:@"hours_icon"]];
    [self.contentView addSubview:self.hoursIcon];
    
    self.hoursTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.hoursIcon.frame) + APPLICATION_FRAME.size.width * 0.04, RESTAURANT_HOURS_CELL_HEIGHT * 0.15, APPLICATION_FRAME.size.width * 0.4, RESTAURANT_HOURS_CELL_HEIGHT * 0.28)];
    [self.hoursTitle setTextColor:[UIColor blackColor]];
    [self.hoursTitle setFont:[UIFont nun_mediumFontWithSize:REST_PAGE_HEADER_FONT_SIZE]];
    [self.hoursTitle setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.hoursTitle];

}

//Dynamically space UI based on number of days
- (void)populateHours:(TPLRestaurant *)restaurant{
    
    if (restaurant.hours.count > 0) {
        if (restaurant.openNow.boolValue) {
            [self.hoursTitle setText:@"Open now"];
        }else{
            [self.hoursTitle setText:@"Closed"];
        }
    }else{
        [self.hoursTitle setText:@"Hours unavailable"];
    }
    
    if (restaurant.hours.count > 0) {
        NSArray *weeklyHours = restaurant.hours;
        
        NSMutableArray *dayArr = [NSMutableArray array];
        NSMutableArray *hrArr = [NSMutableArray array];
        
        int dayCount = 0;
        for (NSDictionary *hrsForDay in weeklyHours) {
            if ([hrsForDay objectForKey:@"Today"]) {
                continue;
            }
            
            //Get day and hours for each day
            [dayArr addObject:[[hrsForDay allKeys]firstObject]];
            [hrArr addObject:[[hrsForDay allValues]firstObject]];
            ++dayCount;
        }
        
        CGRect anchor = self.hoursTitle.frame;
        for (int i = 0; i < dayArr.count; ++i) {
            CGFloat spacer = 0.1;
            NSArray *hours = [NSArray new];
            hours = [hrArr[i] componentsSeparatedByString:@","];
            if (i == 0) {
                //First day and its hours have constant spacing based on default height (since icon and title not based on dynamic height)
                spacer = RESTAURANT_HOURS_CELL_HEIGHT * 0.15;
            }else{
                //If day before had multiple hours, need more spacing
                spacer = self.dynamicHeight * 0.1;
            }
            
            UILabel *dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.hoursTitle.frame), CGRectGetMaxY(anchor) + spacer, APPLICATION_FRAME.size.width * 0.45, RESTAURANT_HOURS_CELL_HEIGHT * 0.2)];
            dayLabel.backgroundColor = [UIColor clearColor];
            dayLabel.textColor = UIColorFromRGB(0x505254);
            [dayLabel setFont:[UIFont nun_fontWithSize:REST_PAGE_DETAIL_FONT_SIZE]];
            [dayLabel setText:dayArr[i]];
            [self.contentView addSubview:dayLabel];
            
            for (int j = 0; j < hours.count; ++j) {
                UILabel *hourLabel;
                NSString *hrString = hours[j];
                
                //First line of hours must align with day
                if (j == 0) {
                    hourLabel = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width - APPLICATION_FRAME.size.width * 0.4, CGRectGetMinY(dayLabel.frame), APPLICATION_FRAME.size.width * 0.4, RESTAURANT_HOURS_CELL_HEIGHT * 0.2)];
                    hourLabel.backgroundColor = [UIColor clearColor];
                    hourLabel.textColor = UIColorFromRGB(0x505254);
                    [hourLabel setFont:[UIFont nun_fontWithSize:REST_PAGE_DETAIL_FONT_SIZE]];
                    [hourLabel setText:hrString];
                    [self.contentView addSubview:hourLabel];
                }
                else//Anchor the rest of the hours on the same day with first line
                {
                    hrString = [hrString stringByReplacingOccurrencesOfString:@" " withString:@""];
                    hourLabel = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width - APPLICATION_FRAME.size.width * 0.4, CGRectGetMaxY(anchor) + 0.5, APPLICATION_FRAME.size.width * 0.4, RESTAURANT_HOURS_CELL_HEIGHT * 0.2)];
                    hourLabel.backgroundColor = [UIColor clearColor];
                    hourLabel.textColor = UIColorFromRGB(0x505254);
                    [hourLabel setFont:[UIFont nun_fontWithSize:REST_PAGE_DETAIL_FONT_SIZE]];
                    [hourLabel setText:hrString];
                    [self.contentView addSubview:hourLabel];
                }
                anchor = hourLabel.frame;//Anchor should now always be the last hour line
            }
        }
    }else{
        //No hours available
//        UILabel *noHoursLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.hoursTitle.frame), self.dynamicHeight/1.5 - self.dynamicHeight * 0.1, APPLICATION_FRAME.size.width * 0.35, self.dynamicHeight * 0.2)];
//        noHoursLabel.backgroundColor = [UIColor clearColor];
//        [noHoursLabel setFont:[UIFont nun_fontWithSize:REST_PAGE_HEADER_FONT_SIZE]];
//        //[noHoursLabel setText:@"Unavailable"];
//        [noHoursLabel setTextColor:UIColorFromRGB(0x505254)];
//        [self.contentView addSubview:noHoursLabel];
    }
}

@end
