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

// Returns the currently logged in user, or nil if not logged in.
@property (nonatomic, strong, readonly) TTUser *currentUser;

// Getter for the singleton instance of this class.
+ (TTSession *)sharedSession;

// Returns whether the User is logged in.
- (BOOL)isUserLoggedIn;

// Attempts to log the user in with their Facebook credentials and returns whether it succeeded.
- (BOOL)fblogInWithId:(NSString *)userId
          accessToken:(NSString *)token
       expirationDate:(NSDate *)expirationDate;

// Logs the user out.
- (BOOL)logout;

// Syncs the User's friends list to that on Facebook.
- (BOOL)syncFriends;

// Syncs the User's profile picture to that on Facebook.
- (BOOL)syncProfilePicture;

// Syncs multiple data to that on Facebook.
- (BOOL)syncUserData;

@end
