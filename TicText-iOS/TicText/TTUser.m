//
//  TTUser.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTUser.h"

#import "TTSession.h"
#import <Parse/PFObject+Subclass.h>

@implementation TTUser

@dynamic displayName, facebookId, friends, profilePicture, activeDeviceIdentifier;

- (BOOL)isLinkedWithFacebook {
    return self[kTTUserFacebookIDKey] != nil;
}

- (void)setFacebookId:(NSString *)facebookId {
    self[kTTUserFacebookIDKey] = facebookId;
}

- (NSString *)facebookId {
    return self[kTTUserFacebookIDKey];
}

- (void)setDisplayName:(NSString *)displayName {
    self[kTTUserDisplayNameKey] = displayName;
}

- (NSString *)displayName {
    return [self objectForKey:kTTUserDisplayNameKey];
}

- (void)setProfilePicture:(NSData *)data {
    PFFile *file = [PFFile fileWithData:data];
    self[kTTUserProfilePictureKey] = file;
}

- (NSData *)profilePicture {
    return [(PFFile *)[self objectForKey:kTTUserProfilePictureKey] getData];
}

- (void)setFriends:(NSArray *)friends {
    self[kTTUserTicTextFriendsKey] = friends;
}

- (NSArray *)friends {
    return [self objectForKey:kTTUserTicTextFriendsKey];
}

- (void)setActiveDeviceIdentifier:(NSString *)activeDeviceIdentifier {
    self[kTTUserActiveDeviceIdentifier] = activeDeviceIdentifier;
}

- (NSArray *)activeDeviceIdentifier {
    return [self objectForKey:kTTUserActiveDeviceIdentifier];
}

@end
