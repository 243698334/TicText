//
//  TTHelper.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTTestHelper.h"

#import "TTUser.h"

@implementation TTTestHelper

+ (TTUser *)fakeUser {
    TTUser *user = [[TTUser alloc] init];
    user.objectId = @"fakeUserId";
    user.facebookId = @"fakeFacebookId";
    user.displayName = @"tkatzenbaer";
    user.profilePicture = [NSData data]; // @TODO - replace with actual data
    
    TTUserPrivateData *privateData = [TTUserPrivateData object];
    privateData.objectId = @"fakeUserPrivateDataId";
    privateData.facebookFriends = @[@"fakeFriend1", @"fakeFriend2"];
    privateData.activeDeviceIdentifier = @"fakeDeviceIdentifier";
    
    user.privateData = privateData;
    
    return user;
}

@end
