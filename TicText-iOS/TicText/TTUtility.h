//
//  TTUtility.h
//  TicText
//
//  Created by Terrence K on 2/21/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

// An assortment of miscellaneous tools that are not big enough to merit their own class.
@interface TTUtility : NSObject

// Prompts the user to register their device for push notifications.
+ (void)setupPushNotifications;

// Fetch all friend and pin them to local datastore as cache.
+ (void)fetchAndPinAllFriends;

// Refresh all friend's public data (display name, profile picture).
+ (void)refreshAllFriends;

// Remove all friends from local datastore.
+ (void)unpinAllFriends;

@end
