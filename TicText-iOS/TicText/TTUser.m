//
//  TTUser.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTUser.h"
#import <Parse/Parse.h>

#import "TTSession.h"

@implementation TTUserFacebookAuthData

@end

@implementation TTUser

@synthesize displayName = _displayName;
@synthesize profilePicture = _profilePicture;
@synthesize friends = _friends;

- (id)initWithPFUser:(PFUser *)user {
    if (self = [super init]) {
        _pfUser = user;
        
        _displayName = user[kTTUserDisplayNameKey];
        _profilePicture = user[kTTUserProfilePictureKey];
        _friends = user[kTTUserTicTextFriendsKey];
    }
    return self;
}

+ (TTUser *)currentUser {
    return [[TTSession sharedSession] currentUser];
}

+ (TTUser *)wrap:(PFUser *)user {
    return [[TTUser alloc] initWithPFUser:user];
}

- (void)setDisplayName:(NSString *)displayName {
    _displayName = displayName;
    
    [self.pfUser setObject:displayName forKey:kTTUserDisplayNameKey];
}

- (NSString *)displayName {
    return _displayName;
}

- (void)setProfilePicture:(NSData *)data {
    _profilePicture = data;
    
    PFFile *file = [PFFile fileWithData:data];
    [self.pfUser setObject:file forKey:kTTUserProfilePictureKey];
}

- (NSData *)profilePicture {
    return _profilePicture;
}

- (void)setFriends:(NSArray *)friends {
    _friends = friends;
    
    [self.pfUser setObject:friends forKey:kTTUserTicTextFriendsKey];
}

- (NSArray *)friends {
    return _friends;
}

@end
