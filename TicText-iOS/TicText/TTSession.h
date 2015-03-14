//
//  TTSession.h
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Reachability.h"
#import "TTUser.h"
#import "TTActivity.h"

@class TTUser;

// A utility class to handle the management of the User's session.
@interface TTSession : NSObject

// Getter for the singleton instance of this class.
+ (TTSession *)sharedSession;

// The result of the latest session validation, cached in NSUserDefaults
- (BOOL)isValidLastChecked;

// Asynchronously validates the current session. Post Parse/Facebook SessionDidBecomeInvalid notification if invalid.
- (void)validateSessionInBackground;

// Prompts the user to authenticate through Facebook, then
- (void)logIn:(void (^)(BOOL isNewUser, NSError *error))completion;

// Logs the user out.
- (void)logOut:(void (^)(void))completion;

@end

@interface TTSession (FBSync)

// Syncs the User's profile, friend list, and profile picture with a single save call.
- (void)syncForNewUser:(void (^)(NSError *error))completion;

// Syncs the User's friend list and upload the current active device's identifier
- (void)syncForExistingUser:(void (^)(NSError *error))completion;

// Syncs the User's profile data to that on Facebook.
- (void)syncProfileData:(void (^)(NSError *error))completion;

// Syncs the User's friends list to that on Facebook.
- (void)syncFriends:(void (^)(NSError *error))completion;

// Syncs the User's profile picture to that on Facebook.
- (void)syncProfilePicture:(void (^)(NSError *error))completion;

// Syncs the User's current active device's identifier
- (void)syncActiveDeviceIdentifier:(void (^)(NSError *))completion;

@end
