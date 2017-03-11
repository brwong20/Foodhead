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
#define CHART_ROW_HEIGHT 230.0
#define CHART_SECTION_HEIGHT 70.0
#define CATEGORY_RESTAURANT_CELL_HEIGHT 100.0
#define SLIDED_PANEL_WIDTH 44.0

//Restaurant Pages
#define RESTAURANT_PAGE_CELL_COUNT 6
#define RESTAURANT_INFO_PADDING 10.0
#define METRIC_CELL_HEIGHT 60.0
#define RESTAURANT_INFO_CELL_HEIGHT 130.0
#define RESTAURANT_PHOTO_COLLECTION_HEIGHT 200.0
#define RESTAURANT_HOURS_CELL_HEIGHT 150.0

/*Helper Macros
 -------------*/
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define NAV_BAR_FONT_NAME @"Nunito-Bold"

#define APPLICATION_BACKGROUND_COLOR [UIColor whiteColor];
#define APPLICATION_FONT_COLOR   UIColorFromRGB(0x274B64)
#define APPLICATION_BLUE_COLOR   UIColorFromRGB(0x17A1FF)
#define APPLICATION_GREEN_COLOR  UIColorFromRGB(0x7AD313)

#endif /* FoodWiseDefines_h */
