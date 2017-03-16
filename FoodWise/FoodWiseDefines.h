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

/*YumDrop API
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


//Foursquare API
#define FOURSQ_CLIENT_ID @"V2K0BSBPNB2VLLTG33NSYRJGJ3ANDGBJQSH2ZNRVEJZ1AW5S"
#define FOURSQ_SECRET @"N321F5ZABWPKKUSCZ00K1ZXHXD1UMVJX3BZQ4EDYKORQ2O5Y"

//UI
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

#endif /* FoodWiseDefines_h */
