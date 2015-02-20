//
//  TTSession.h
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TTUser.h"

@class TTUser;

// A utility class to handle the management of the User's session.
@interface TTSession : NSObject

// Getter for the singleton instance of this class.
+ (TTSession *)sharedSession;

// Returns whether the User is logged in.
- (BOOL)isUserLoggedIn;

// Prompts the user to authenticate through Facebook, then
- (void)login:(void (^)(BOOL isNewUser, NSError *error))completion;

// Logs the user out.
- (void)logout:(void (^)(void))completion;

@end

@interface TTSession (FBSync)

// Syncs the User's profile data to that on Facebook.
- (void)syncProfileData:(void (^)(NSError *error))completion;

// Syncs the User's friends list to that on Facebook.
- (void)syncFriends:(void (^)(NSError *error))completion;

// Syncs the User's profile picture to that on Facebook.
- (void)syncProfilePicture:(void (^)(NSError *error))completion;

@end
