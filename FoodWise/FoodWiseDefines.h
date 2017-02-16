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
#define YUM_SERVICE @"InstagramService"

//YumDrop API
#define YUM_PROVIDER_AUTH @"http://yumdrop-dev.scrij.com/api/auth/%@/callback"
#define YUM_CHECK_SESSION @"http://yumdrop-dev.scrij.com/api/sessions"
#define YUM_GET_USER_INFO @"http://yumdrop-dev.scrij.com/api/users"


//Foursquare API
#define FOURSQ_CLIENT_ID @"V2K0BSBPNB2VLLTG33NSYRJGJ3ANDGBJQSH2ZNRVEJZ1AW5S"
#define FOURSQ_SECRET @"N321F5ZABWPKKUSCZ00K1ZXHXD1UMVJX3BZQ4EDYKORQ2O5Y"

//UI
#define CHART_SECTION_HEIGHT 70.0
#define CATEGORY_RESTAURANT_CELL_HEIGHT 100.0


#endif /* FoodWiseDefines_h */
