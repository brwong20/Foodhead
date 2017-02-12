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
//#define KEYCHAIN_ACCOUNT @"com.Brwong.Foodwise"
//#define INSTAGRAM_SERVICE @"InstagramService"

//Instagram Auth API
#define INSTAGRAM_CLIENT_ID @"eef6297b1cb846c3ba14a2bce8bec446"
#define INSTAGRAM_CLIENT_SECRET @"bbe0b3fa31f8418a97b67810da295c56"
#define INSTAGRAM_AUTH_URL @"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token&scope=public_content+likes"

#define REDIRECT_URI @"http://tapletfoodwise.com/giveMeToken/"

//Foursquare API
#define FOURSQ_CLIENT_ID @"V2K0BSBPNB2VLLTG33NSYRJGJ3ANDGBJQSH2ZNRVEJZ1AW5S"
#define FOURSQ_SECRET @"N321F5ZABWPKKUSCZ00K1ZXHXD1UMVJX3BZQ4EDYKORQ2O5Y"


#endif /* FoodWiseDefines_h */
