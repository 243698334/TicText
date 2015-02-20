//
//  TTSession.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTSession.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@implementation TTSession

@synthesize currentUser = _currentUser;

+ (TTSession *)sharedSession {
    static TTSession *_sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TTSession alloc] init];
    });
     
    return _sharedInstance;
}

- (TTUser *)currentUser {
    if ([_currentUser pfUser] != [PFUser currentUser]) {
        _currentUser = [TTUser wrap:[PFUser currentUser]];
    }
    return _currentUser;
}

- (BOOL)isUserLoggedIn {
    return [self currentUser] != nil;
}

- (BOOL)fblogInWithId:(NSString *)userId
          accessToken:(NSString *)token
       expirationDate:(NSDate *)expirationDate {
    return NO; // @stub
}

- (BOOL)logout {
    return NO; // @stub
}

- (BOOL)syncFriends {
    return NO; // @stub
}

- (BOOL)syncProfilePicture {
    return NO; // @stub
}

- (BOOL)syncUserData {
    NSError *error;
    [[PFUser currentUser] fetch:&error];
    if (error) {
        NSLog(@"ERROR: Unable to fetch currentUser from server.");
    }
/*    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self refreshDataForExistingUser:(PFUser *)object error:error completion:nil];
    }];*/
    return NO; // @stub
}

@end
