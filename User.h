//
//  User.h
//  FoodWise
//
//  Created by Brian Wong on 2/16/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <UIKit/UIKit.h>

@interface User : MTLModel<MTLJSONSerializing>

//Copy doesn't create a reference to these fields since we don't want these changing in the app unless the user does so explicity (through db methods)

@property (nonatomic, copy, readonly) NSNumber *userId;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, copy) NSString *location;

@property (nonatomic, copy) UIImage *avatarImg;

@property (nonatomic, copy) NSArray *badges;

@end
