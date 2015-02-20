//
//  TTHelper.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTHelper.h"

#import <Parse/Parse.h>

@implementation TTHelper

+ (PFUser *)fakeUser {
    PFUser *user = [[PFUser alloc] init];
    user[kTTUserDisplayNameKey] = @"tkatzenbaer";
    user[kTTUserFacebookIDKey] = @"1234567890";
    user[kTTUserProfilePictureKey] = [NSData data]; // @TODO - replace with actual data
    user[kTTUserProfilePictureSmallKey] = [NSData data]; // @TODO - replace with actual data
    
    NSArray *friends = @[
                         @"1111111111",
                         @"2222222222"
                         ];
    user[kTTUserTicTextFriendsKey] = friends;
    
    return user;
}

@end
