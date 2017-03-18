//
//  FoodWiseDefines.h
//  FoodWise
//
//  Created by Brian Wong on 1/23/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#ifndef FoodWiseDefines_h
#define FoodWiseDefines_h

//Login Flow
typedef NS_ENUM(NSInteger, RootViewType) {
    RootViewTypeLogin,
    RootViewTypeCharts,
};

//SAMKeychain
#define KEYCHAIN_ACCOUNT @"com.Brwong.Foodwise"
#define YUM_SERVICE @"YUM_API_SERVICE"
#define LAST_USER_DEFAULT @"last_user"

/*YumDrop API - Staging Server
 ------------*/
#define STAGING_BASE_URL @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com"

//Users
#define API_USER @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/users"

//Sessions
#define API_SESSION_STATUS @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/sessions"
#define API_SERVER_STATUS @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/sessions/health"
#define API_SESSION_AUTHORIZE @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/auth/%@/callback"

//Reviews
#define API_REVIEW @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/places/%@/reviews"

//Places
#define API_PLACES @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/places"
#define API_PLACE_DETAIL @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/places/%@"
#define API_PLACE_SUGGESTIONS @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/places/suggestions"
#define API_PLACE_MEDIA @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/places/%@/images"

//Charts
#define API_CHARTS @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/charts"

//Categories
#define API_CATEGORIES @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/categories"


//Workers
#define API_WORKER_PLACES @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/workers/%@/explorer"
#define API_WORKER_DETAILS @"http://yumdrop-stage.us-west-1.elasticbeanstalk.com/api/workers/%@/details"

/*YumDrop API - Development Server
------------*/

//Authentication & Sessions
#define YUM_PROVIDER_AUTH @"http://yumdrop-dev.scrij.com/api/auth/%@/callback"
#define YUM_CHECK_SESSION @"http://yumdrop-dev.scrij.com/api/sessions"
#define FB_PROVIDER_PATH @"facebook"
#define AUTH_TOKEN_PARAM @"AUTHTOKEN"


#define BASE_URL @"http://yumdrop-dev.scrij.com/api/"

//Users
#define YUM_GET_USER_INFO @"http://yumdrop-dev.scrij.com/api/users"

//Places
#define YUM_PLACES_GENERAL @"http://yumdrop-dev.scrij.com/api/places"
#define YUM_PLACES_DETAILS @"http://yumdrop-dev.scrij.com/api/places/%@"


//Charts
#define YUM_CHARTS @"http://yumdrop-dev.scrij.com/api/charts"

//Reviews
#define YUM_PLACES_REVIEWS @"http://yumdrop-dev.scrij.com/api/places/%@/reviews"

//Workers
#define YUM_WORKER_GENERAL @"http://yumdrop-dev.scrij.com/api/workers/%@/explorer"
#define YUM_WORKER_DETAILS @"http://yumdrop-dev.scrij.com/api/workers/%@/details"

/*UI Constants
--------------*/

//Charts
#define CHART_ROW_HEIGHT [[UIScreen mainScreen]bounds].size.height * 0.32
#define CHART_ITEM_SIZE [[UIScreen mainScreen]bounds].size.height * 0.28
#define CHART_SECTION_HEIGHT [[UIScreen mainScreen]bounds].size.height * 0.07

#define CATEGORY_RESTAURANT_CELL_HEIGHT 100.0
#define CHART_PADDING_PERCENTAGE 0.04
#define CHART_SPACING 0.05

//Restaurant Pages
#define RESTAURANT_PAGE_CELL_COUNT 6
#define RESTAURANT_INFO_CELL_HEIGHT [[UIScreen mainScreen]bounds].size.height * 0.15
#define METRIC_CELL_HEIGHT 60.0
#define RESTAURANT_LOCATION_CELL_HEIGHT 140.0
#define RESTAURANT_HOURS_CELL_HEIGHT 70.0
#define HOUR_CELL_SPACING 0.55


//Search
#define SEARCH_CELL_HEIGHT [[UIScreen mainScreen]bounds].size.height * 0.11
#define MAX_RESULT_COUNT 3

/*Helper Macros
 -------------*/
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define CHART_TAB_TAG 1
#define CAMERA_TAB_TAG 2
#define PROFILE_TAB_TAG 3

#define APPLICATION_BACKGROUND_COLOR [UIColor whiteColor];
#define APPLICATION_FONT_COLOR   UIColorFromRGB(0x274B64)
#define APPLICATION_BLUE_COLOR   UIColorFromRGB(0x17A1FF)
#define APPLICATION_ORANGE_COLOR  UIColorFromRGB(0xFF9484)

#define APPLICATION_FRAME   [UIScreen mainScreen].bounds

#endif /* FoodWiseDefines_h */
