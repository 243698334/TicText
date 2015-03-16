//
//  TTSession.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTSession.h"

@interface TTSession ()

@property (nonatomic, strong) Reachability *internetReachability;

@end

@implementation TTSession

+ (TTSession *)sharedSession {
    static TTSession *_sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TTSession alloc] init];
    });
     
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
    }
    return self;
}

- (void)reachabilityDidChange:(NSNotification *)notification {
    Reachability *internetReachability = [notification object];
    NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
    if (networkStatus != NotReachable && ![internetReachability connectionRequired]) {
        [self validateSessionInBackground];
    }
}

- (BOOL)isValidLastChecked {
    BOOL isParseSessionValid = [[NSUserDefaults standardUserDefaults] boolForKey:kTTParseSessionIsValidLastCheckedKey];
    BOOL isFacebookSessionValid = [[NSUserDefaults standardUserDefaults] boolForKey:kTTFacebookSessionIsValidLastCheckedKey];
    NSLog(@"TTSession: Parse session %@ last checked", isParseSessionValid ? @"VALID" : @"INVALID");
    NSLog(@"TTSession: Facebook session %@ last checked", isFacebookSessionValid ? @"VALID" : @"INVALID");
    return isParseSessionValid && isFacebookSessionValid;
}

- (BOOL)isParseServerReachable {
    Reachability *parseReachability = [Reachability reachabilityWithHostName:@"api.parse.com"];
    NetworkStatus parseNetworkStatus = [parseReachability currentReachabilityStatus];
    return parseNetworkStatus == NotReachable;
}

- (void)validateSessionInBackground {
    // Skip validate when Parse server is not reachable
    if ([self isParseServerReachable]) {
        return;
    }
    
    // Validate Parse local session
    if (![TTUser currentUser]) {
        NSLog(@"TTSession: Parse local session INVALID (user logged out). ");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:nil];
        return;
    }
    
    // Validate Parse remote session
    [[TTUser currentUser].privateData fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"TTSession: Parse remote session INVALID. ");
            NSError *error = [NSError errorWithDomain:kTTSessionErrorDomain code:kTTSessionErrorParseSessionFetchFailureCode userInfo:nil];
            if ([self isParseServerReachable]) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:kTTNotificationUserInfoErrorKey]];
            }
            return;
        } else {
            if ([[[TTUser currentUser].privateData activeDeviceIdentifier] isEqualToString:[UIDevice currentDevice].identifierForVendor.UUIDString]) {
                NSLog(@"TTSession: Parse remote session VALID. ");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTParseSessionIsValidLastCheckedKey];
            } else {
                NSLog(@"TTSession: Parse remote session INVALID. (invalid UUID)");
                NSLog(@"Remote UUID: [%@]", [TTUser currentUser].privateData.activeDeviceIdentifier);
                NSLog(@"Local UUID: [%@]", [UIDevice currentDevice].identifierForVendor.UUIDString);
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Invalid Session",
                                           NSLocalizedFailureReasonErrorKey: @"Your account has been logged in with another device. ",
                                           NSLocalizedRecoverySuggestionErrorKey: @"Consider turn on 2-step verification or TicText password. "};
                NSError *error = [NSError errorWithDomain:kTTSessionErrorDomain code:kTTSessionErrorParseSessionInvalidUUIDCode userInfo:userInfo];
                if ([self isParseServerReachable]) {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:kTTNotificationUserInfoErrorKey]];
                }
                return;
            }
        }
    }];
    
    // Validate Facebook session
    [[PFFacebookUtils session] refreshPermissionsWithCompletionHandler:^(FBSession *session, NSError *error) {
        if (error) {
            NSLog(@"TTSession: Facebook session INVALID. ");
            if ([self isParseServerReachable]) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTFacebookSessionIsValidLastCheckedKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTFacebookSessionDidBecomeInvalidNotification object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:kTTNotificationUserInfoErrorKey]];
            }
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
            NSString *facebookId = result[@"id"];
            NSArray *facebookFriendsDataArray = result[@"friends"][@"data"];
            NSMutableArray *facebookFriends = [[NSMutableArray alloc] initWithCapacity:[facebookFriendsDataArray count]];
            for (NSDictionary *currentFacebookFriendEntry in facebookFriendsDataArray) {
                [facebookFriends addObject:[currentFacebookFriendEntry objectForKey:@"id"]];
            }
            NSURL *profilePictureURL = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
            NSLog(@"Name: [%@], FacebookID: [%@], Friends: [%@], Profile picture URL: [%@]", displayName, facebookId, facebookFriends, profilePictureURL);
            
            [TTUser currentUser].facebookId = facebookId;
            [TTUser currentUser].displayName = displayName;
            [TTUser currentUser].privateData = [TTUserPrivateData object];
            [TTUser currentUser].privateData.userId = [TTUser currentUser].objectId;
            [TTUser currentUser].privateData.ACL = [PFACL ACLWithUser:[TTUser currentUser]];
            [TTUser currentUser].privateData.facebookFriends = facebookFriends;
            [TTUser currentUser].privateData.activeDeviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;

            NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL];
            [NSURLConnection sendAsynchronousRequest:profilePictureURLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                 if (connectionError == nil && data != nil) {
                     [[TTUser currentUser] setProfilePicture:data];
                     [[TTUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (succeeded) {
                             [self fetchAndPinAllFriendsInBackground];
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
    [TTUser currentUser].privateData.activeDeviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    // Friend list
    FBRequest *request = [FBRequest requestForMyFriends];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSArray *facebookFriendsDataArray = [result objectForKey:@"data"];
            NSMutableArray *facebookFriends = [[NSMutableArray alloc] initWithCapacity:[facebookFriendsDataArray count]];
            for (NSDictionary *currentFacebookFriendEntry in facebookFriendsDataArray) {
                [facebookFriends addObject:[currentFacebookFriendEntry objectForKey:@"id"]];
            }
            [TTUser currentUser].privateData.facebookFriends = [NSArray arrayWithArray:facebookFriends];
            [[TTUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self fetchAndPinAllFriendsInBackground];
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

- (void)fetchAndPinAllFriendsInBackground {
    NSLog(@"Fetching all friends' public data. ");
    [[TTUser currentUser].privateData fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        TTUserPrivateData *fetchedPrivateData = (TTUserPrivateData *)object;
        [TTUser fetchAllInBackground:fetchedPrivateData.friends block:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            } else {
                [TTUser pinAllInBackground:objects];
            }
        }];
    }];
}

- (void)syncActiveDeviceIdentifier:(void (^)(NSError *))completion {
    [TTUser currentUser].privateData.activeDeviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [[TTUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

@end
