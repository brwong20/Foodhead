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

//Error Types
typedef NS_ENUM(NSInteger, ServiceErrorType) {
    ServiceErrorTypeLocation,
    ServiceErrorTypeData,
};

//Onboarding Flow
typedef NS_ENUM(NSInteger, OnboardingPage) {
    OnboardingPageHome,
    OnboardingPageFavorite,
    OnboardingPageBrowse
};

//SAMKeychain
#define KEYCHAIN_ACCOUNT @"com.Brwong.Foodwise"
#define YUM_SERVICE @"YUM_API_SERVICE"
#define LAST_USER_DEFAULT @"last_user"

//Onboarding
#define CAMERA_CAPTURE_TOOLTIP @"com.gotaplet.Foodhead.cameraCapture"
#define CAMERA_RATING_TOOLTIP @"com.gotaplet.Foodhead.cameraRating"

#define MAIN_PAGE_TOOLTIP @"com.gotaplet.Foodhead.homePage"
#define FAVORITE_TOOLTIP @"com.gotaplet.Foodhead.favorite"
#define BROWSE_TOOLTIP @"com.gotaplet.Foodhead.browse"
#define HOOTSCORE_TOOLTIP @"com.gotaplet.Foodhead.hootscore"

//Privacy/Terms
#define FOODHEAD_TERMS_URL @"https://www.foodheadapp.com/terms-of-use/"
#define FOODHEAD_PRIVACY_URL @"https://www.foodheadapp.com/privacy-policy/"


//Flurry Analytics
#define FLURRY_API_KEY @"TW3F2PWHGQYK585VK759"

//ANALYTICS - Event Logs//

//Login/Singup
#define USER_SKIP_LOGIN
#define USER_FB_LOGIN

//Restaurant Page
#define OPEN_RESTAURANT_PAGE @"openRestPage"
#define OPEN_RESTAURANT_ALBUM @"openRestAlbum"
#define ALBUM_SWIPE_COUNT @"albumSwipeCount"
#define OPEN_RESTAURANT_MENU @"openRestMenu"
#define OPEN_RESTAURANT_ADDRESS @"openRestAddress"
#define OPEN_RESTAURANT_WEBSITE @"openRestSite"
#define CALL_RESTAURANT @"callRestaurant"
#define SHARE_RESTAUARNT @"shareRestaurant"

//Profile
#define PROFILE_TAB_CLICK @"profileTabClick"
#define PROFILE_PHOTO_OPEN @"showAvatarClick"

//Charts
#define EXPANDED_CHART_PAGE @"openSeeAllRestaurants"
#define END_OF_CHART_PAGE @"chartFeedEnd"
#define END_OF_CHART @"endOfChart"//Checks if a user scrolls to end of aa specific chart.

#define END_OF_DISCOVER @"discoverFeedEnd"
#define DISCOVER_TAB_CLICK @"homeTabClick"

//Camera
#define CAMERA_CAPTURE @"photoCapture"
#define CAMERA_FLASH_ENABLED @"photoFlashEnabled"
#define USER_SAVE_PHOTO @"savePhoto"

//Reviews
#define FILTER_SWIPE @"filterSwipe"
#define OVERALL_SUBMIT @"didSubmitOverall"
#define HEALTHINESS_SUBMIT @"didSubmitHealth"
#define PRICE_SUBMIT @"didSubmitPrice"
#define REVIEW_FLOW_NEXT @"reviewFlowNext"
#define REVIEW_SUBMIT @"reviewSubmit"

//Search
#define SEARCH_TAB_CLICK @"searchTabClick"
#define SEARCH_FOUND_CATEGORY @"searchFoundCategory"
#define SEARCH_FOUND_RESTAURANT @"searchFoundRestaurant" //Measures 2 things: User found restaurant on search + they want to look at the restaurants page
#define SEARCH_CUSTOM_CATEGORY @"didClickCustomCategory"
#define SEARCH_BUTTON_CLICK @"didClickSearchButton"
#define SEARCH_BAR_CLICK @"didClickSearchBar"

//Search Filters
#define SEARCH_FILTER_APPLY @"didApplySearchFilters"

//Browse
#define BROWSE_TAB_CLICK @"browseTabClick"
#define USER_FAVORITED_VIDEO @"userFavoritedVideo"
#define USER_UNFAVORITED_VIDEO @"userUnfavoritedVideo"
#define USER_WATCHED_VIDEO @"userWatchedFullVideo"
#define END_OF_BROWSE @"browseFeedEnd"

//Favorite
#define USER_FAVORITED_RESTAURANT @"userFavoritedRestaurant"
#define USER_UNFAVORITED_RESTAURANT @"userUnfavoritedRestaurant"

//Timed Analytics
#define TIME_SPENT_HOME @"userTimeSpentHome"
#define TIME_SPENT_BROWSE @"userTimeSpentBrowse"

//Push Notifications
#define USER_CLICKED_PUSH @"userClickedPush"

//STATUS CODES
#define STATUS_CODE_OK @"200"
#define STATUS_CODE_UNAUTHORIZED @"401"
#define STATUS_CODE_NO_INTERNET @"500"
#define STATUS_CODE_CONFLICT @"409"
#define STATUS_NO_INTERNET @"The Internet connection appears to be offline."


/* Foodhead API - API_BASE_URL defined in Prefix.pch file based on scheme */

//Authentication Constants
#define FB_PROVIDER_PATH @"facebook"
#define AUTH_TOKEN_PARAM @"AUTHTOKEN"

//Users
#define API_USER [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"users"]
#define API_USER_PUSH_NOTIFICATION [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"devices"]
#define ANON_USER @"anon"
#define SIGNUP_NOTIFICATION @"signup"

//Sessions
#define API_SESSION_STATUS [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"sessions"]
#define API_SERVER_STATUS [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"sessions/health"]
#define API_SESSION_AUTHORIZE [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"auth/%@/callback"]

//Reviews
#define API_REVIEW [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"places/%@/reviews"]
#define API_USER_REVIEWS [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"users/reviews"]

//Places
#define API_PLACES [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"places"]
#define API_PLACE_DETAIL [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"places/%@"]
#define API_PLACE_SUGGESTIONS [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"places/suggestions"]
#define API_PLACE_MEDIA [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"places/%@/images"]
#define API_PLACE_SEARCH [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"places/search"]
#define API_PLACE_BLOGS [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"places/instagram_places"]

//Browse
#define API_PLACES_BROWSE_POSTS [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"posts"]

//Charts
#define API_CHARTS [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"charts"]

//Categories
#define API_CATEGORIES [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"categories"]


//Workers
#define API_WORKER_PLACES [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"workers/%@/explorer"]
#define API_WORKER_DETAILS [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"workers/%@/details"]

//User Feedback
#define API_FEEDBACK [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"feedbacks"]

//Images Types
#define IMG_TYPE_FOURSQ @"foursquare_photo"
#define IMG_TYPE_INSTA_MOBILE @"instagram_location"
//#define IMG_TYPE_INSTA WEB

/*UI Constants
--------------*/

//Charts
#define CHART_ROW_HEIGHT [[UIScreen mainScreen]bounds].size.height * 0.72
#define CHART_ITEM_SIZE [[UIScreen mainScreen]bounds].size.height * 0.3
#define CHART_SECTION_HEIGHT [[UIScreen mainScreen]bounds].size.height * 0.07

#define CATEGORY_RESTAURANT_CELL_HEIGHT 100.0
#define CHART_PADDING_PERCENTAGE 0.04
#define CHART_SPACING 0.025

#define DISCOVER_NODE_SPACING 25.0

#define ASSET_KEY @"asset"
#define ASSET_LINK_KEY @"assetLink"

//Restaurant Pages
#define RESTAURANT_PAGE_CELL_COUNT 6
#define RESTAURANT_INFO_CELL_HEIGHT [[UIScreen mainScreen]bounds].size.height * 0.18
#define METRIC_CELL_HEIGHT 65.0
#define RESTAURANT_LOCATION_CELL_HEIGHT 120.0
#define RESTAURANT_SCORE_CELL_HEIGHT 70.0
#define RESTAURANT_HOURS_CELL_HEIGHT [[UIScreen mainScreen]bounds].size.height * 0.1
#define ATTRIBUTION_CELL_HEIGHT 55.0
#define HOUR_CELL_SPACING 0.55

#define REST_PAGE_HEADER_FONT_SIZE APPLICATION_FRAME.size.width * 0.042
#define REST_PAGE_DETAIL_FONT_SIZE APPLICATION_FRAME.size.width * 0.037
#define REST_PAGE_ICON_PADDING APPLICATION_FRAME.size.width * 0.025

#define PRICE_CONVERSION_COUNT 10
#define OVERALL_CONVERSION_COUNT 10
#define HEALTH_CONVERSION_COUNT 5

//Search
#define SEARCH_CONTROLLER_CELL_HEIGHT 55.0
#define SEARCH_CELL_HEIGHT [[UIScreen mainScreen]bounds].size.height * 0.1
#define MAX_RESULT_COUNT 3
#define RESULT_CELL_HEIGHT 163.0

//Settings
#define SETTINGS_CELL_HEIGHT 80.0

//Photos
#define USER_REVIEW_PHOTO @"review_image"


/*Helper Macros
 -------------*/

#define CHART_TAB_TAG 1
#define CAMERA_TAB_TAG 2
#define PROFILE_TAB_TAG 3
#define SEARCH_TAB_TAG 4
#define BROWSE_TAB_TAG 5

#define APPLICATION_BACKGROUND_COLOR [UIColor whiteColor];
#define APPLICATION_FONT_COLOR   UIColorFromRGB(0x274B64)
#define APPLICATION_BLUE_COLOR   UIColorFromRGB(0x8BBFF9)
#define APPLICATION_PURPLE_COLOR UIColorFromRGB(0xBA9AC1)

#define APPLICATION_FRAME   [UIScreen mainScreen].bounds


#define ASSET_PADDING           5
#define ASSET_FRAME             CGRectMake(0, 0, CGRectGetWidth(APPLICATION_FRAME), CGRectGetHeight(APPLICATION_FRAME))
#define ASSET_FRAME_LANDSCAPE   CGRectMake(0, 0, CGRectGetHeight(APPLICATION_FRAME), CGRectGetWidth(APPLICATION_FRAME))

#define PREVIEW_FRAME  CGRectMake(0, APPLICATION_FRAME.size.height/2 - APPLICATION_FRAME.size.width/2, APPLICATION_FRAME.size.width, APPLICATION_FRAME.size.width)


#define METERS_TO_MILES 0.000621371

//Simple separator line for cells
#define SEP_LINE_RECT CGRectMake(0.0, 0, APPLICATION_FRAME.size.width, 1.0)

#endif /* FoodWiseDefines_h */
