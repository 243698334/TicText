//
//  TTSession.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTSession.h"

@implementation TTSession

+ (TTSession *)sharedSession {
    static TTSession *_sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TTSession alloc] init];
    });
     
    return _sharedInstance;
}

- (BOOL)isValidLastChecked {
    BOOL isParseSessionValid = [[NSUserDefaults standardUserDefaults] boolForKey:kTTParseSessionIsValidLastCheckedKey];
    BOOL isFacebookSessionValid = [[NSUserDefaults standardUserDefaults] boolForKey:kTTFacebookSessionIsValidLastCheckedKey];
    NSLog(@"TTSession: Parse session %@ last checked", isParseSessionValid ? @"VALID" : @"INVALID");
    NSLog(@"TTSession: Facebook session %@ last checked", isFacebookSessionValid ? @"VALID" : @"INVALID");
    return isParseSessionValid && isFacebookSessionValid;
}

- (void)validateSessionInBackground {
//    // Skip validate when no Internet connection
//    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
//    if ([internetReachability currentReachabilityStatus] == NotReachable) {
//        NSLog(@"TTSession: No Internet connection. Skip validation. ");
//        return;
//    }
    
    // Validate Parse local session
    if (![TTUser currentUser]) {
        NSLog(@"TTSession: Parse local session INVALID (user logged out). ");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:nil];
        return;
    }
    
    // Validate Parse remote session
    [[TTUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"TTSession: Parse remote session INVALID. ");
            NSError *error = [NSError errorWithDomain:kTTSessionErrorDomain code:kTTSessionErrorParseSessionFetchFailureCode userInfo:nil];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:kTTNotificationUserInfoErrorKey]];
            return;
        } else {
            if ([[[TTUser currentUser] activeDeviceIdentifier] isEqualToString:[UIDevice currentDevice].identifierForVendor.UUIDString]) {
                NSLog(@"TTSession: Parse remote session VALID. ");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTParseSessionIsValidLastCheckedKey];
            } else {
                NSLog(@"TTSession: Parse remote session INVALID. (invalid UUID)");
                NSLog(@"Remote UUID: [%@]", [[TTUser currentUser] activeDeviceIdentifier]);
                NSLog(@"Local UUID: [%@]", [UIDevice currentDevice].identifierForVendor.UUIDString);
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Invalid Session",
                                           NSLocalizedFailureReasonErrorKey: @"Your account has been logged in with another device. ",
                                           NSLocalizedRecoverySuggestionErrorKey: @"Consider turn on 2-step verification or TicText password. "};
                NSError *error = [NSError errorWithDomain:kTTSessionErrorDomain code:kTTSessionErrorParseSessionInvalidUUIDCode userInfo:userInfo];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:kTTNotificationUserInfoErrorKey]];
                return;
            }
        }
    }];
    
    // Validate Facebook session
    [[PFFacebookUtils session] refreshPermissionsWithCompletionHandler:^(FBSession *session, NSError *error) {
        if (error) {
            NSLog(@"TTSession: Facebook session INVALID. ");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTFacebookSessionIsValidLastCheckedKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTFacebookSessionDidBecomeInvalidNotification object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:kTTNotificationUserInfoErrorKey]];
            return;
        } else {
            NSLog(@"TTSession: Facebook session VALID. ");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTFacebookSessionIsValidLastCheckedKey];
        }
    }];
}

- (void)logIn:(void (^)(BOOL isNewUser, NSError *error))completion {
    // Login PFUser using Facebook
    NSLog(@"TTSession: Logging in. ");
    [PFFacebookUtils logInWithPermissions:kTTFacebookPermissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (completion) {
                completion(NO, error);
            }
        } else {
            if (completion) {
                NSLog(@"Logged in with permissions: %@", kTTFacebookPermissions);
                NSLog(@"Name: [%@], FacebookID: [%@], Friends: [%@]", [(TTUser *)user displayName], [(TTUser *)user facebookID], [(TTUser *)user facebookFriends]);
                completion(user.isNew, error);
            }
        }
    }];
}

- (void)logOut:(void (^)(void))completion {
    NSLog(@"TTSession: Logging out. ");
    
    [TTUser logOut];
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTFacebookSessionIsValidLastCheckedKey];
    
    [[PFInstallation currentInstallation] removeObjectForKey:kTTInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    [PFQuery clearAllCachedResults];
    
    if (completion) {
        completion();
    }
}


#pragma mark - FBSync

- (void)syncForNewUser:(void (^)(NSError *error))completion {
    NSLog(@"Sync for new user. ");
    FBRequestConnection *facebookRequestConnection = [[FBRequestConnection alloc] init];
    [facebookRequestConnection addRequest:[FBRequest requestWithGraphPath:@"me" parameters:@{@"fields": @"name,id,friends,picture.height(640).width(640)"} HTTPMethod:@"GET"] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error == nil) {
            NSString *displayName = result[@"name"];
            NSString *facebookID = result[@"id"];
            NSArray *facebookFriendsDataArray = result[@"friends"][@"data"];
            NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:[facebookFriendsDataArray count]];
            for (NSDictionary *currentFacebookFriendEntry in facebookFriendsDataArray) {
                [friends addObject:[currentFacebookFriendEntry objectForKey:@"id"]];
            }
            NSURL *profilePictureURL = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
            NSLog(@"Name: [%@], FacebookID: [%@], Friends: [%@], Profile picture URL: [%@]", displayName, facebookID, friends, profilePictureURL);
            
            [TTUser currentUser].displayName = displayName;
            [TTUser currentUser].facebookID = facebookID;
            [TTUser currentUser].facebookFriends = friends;
            [TTUser currentUser].activeDeviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
            NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL];
            [NSURLConnection sendAsynchronousRequest:profilePictureURLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                 if (connectionError == nil && data != nil) {
                     [[TTUser currentUser] setProfilePicture:data];
                     [[TTUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (succeeded) {
                             [[TTActivity activityWithType:kTTActivityTypeNewUserJoin] saveInBackground];
                         } else {
                             [self logOut:nil];
                         }
                         if (completion) {
                             completion(error);
                         }
                     }];
                 } else {
                     if (completion) {
                         completion(connectionError);
                     }
                 }
             }];
        } else {
            if (completion) {
                completion(error);
            }
        }
    }];
    [facebookRequestConnection start];
}

- (void)syncForExistingUser:(void (^)(NSError *error))completion {
    NSLog(@"Sync for existing user. ");
    // Active device identifier
    [[TTUser currentUser] setActiveDeviceIdentifier:[UIDevice currentDevice].identifierForVendor.UUIDString];
    
    // Friend list
    FBRequest *request = [FBRequest requestForMyFriends];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSMutableArray *friendIds = [NSMutableArray array];
            
            NSArray *friends = [result objectForKey:@"data"];
            for (NSDictionary *friend in friends) {
                [friendIds addObject:friend[@"id"]];
            }
            
            [TTUser currentUser].facebookFriends = [NSArray arrayWithArray:friendIds];
            [[TTUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (completion) {
                    completion(error);
                }
            }];
        }
        if (completion) {
            completion(error);
        }
    }];
}

- (void)syncActiveDeviceIdentifier:(void (^)(NSError *))completion {
    [[TTUser currentUser] setActiveDeviceIdentifier:[UIDevice currentDevice].identifierForVendor.UUIDString];
    [[TTUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

@end
